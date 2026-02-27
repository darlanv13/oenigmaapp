import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../scanner_and_map/data/location_service.dart';

class CreateEnigmaScreen extends ConsumerStatefulWidget {
  const CreateEnigmaScreen({super.key});

  @override
  ConsumerState<CreateEnigmaScreen> createState() => _CreateEnigmaScreenState();
}

class _CreateEnigmaScreenState extends ConsumerState<CreateEnigmaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores do formulário
  final _charadaController = TextEditingController();
  final _qrCodeController = TextEditingController();
  final _premioController = TextEditingController();
  final _raioController = TextEditingController(
    text: '150',
  ); // Raio padrão de 150m

  // Variáveis de localização
  double? _lat;
  double? _lon;
  bool _isFetchingLocation = false;
  bool _isSaving = false;

  // Modo padrão
  String _modoSelecionado = 'ACHE_E_GANHE';

  Future<void> _pegarGpsAtual() async {
    setState(() => _isFetchingLocation = true);
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentPosition();
      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS Capturado com Sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no GPS: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _salvarEnigma() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa capturar o GPS primeiro!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Salva direto no Firestore
      await FirebaseFirestore.instance.collection('enigmas').add({
        'modo': _modoSelecionado,
        'charada': _charadaController.text,
        'codigo_qr_esperado': _qrCodeController.text,
        'premio_dinheiro': double.tryParse(_premioController.text) ?? 0.0,
        'raio_metros': double.tryParse(_raioController.text) ?? 150.0,
        'lat': _lat,
        'lon': _lon,
        'ativo': true,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enigma Lançado! Já está no mapa!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Volta pro Dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantar Novo Enigma'),
        backgroundColor: Colors.deepPurple.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Captura de Coordenadas em Campo
              Card(
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Localização do Tesouro',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _lat != null
                            ? 'Lat: $_lat \nLon: $_lon'
                            : 'GPS não capturado',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: _isFetchingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.gps_fixed),
                        label: const Text('Capturar Meu GPS Agora'),
                        onPressed: _isFetchingLocation ? null : _pegarGpsAtual,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Dados da Missão
              DropdownButtonFormField<String>(
                value: _modoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Modo de Jogo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'ACHE_E_GANHE',
                    child: Text('Ache e Ganhe (Mapa)'),
                  ),
                  DropdownMenuItem(
                    value: 'SUPER_PREMIO',
                    child: Text('Super Prêmio (Evento)'),
                  ),
                ],
                onChanged: (val) => setState(() => _modoSelecionado = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _charadaController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'A Charada / Texto da Pista',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _qrCodeController,
                decoration: const InputDecoration(
                  labelText: 'Texto que está no QR Code Físico',
                  border: OutlineInputBorder(),
                  helperText: 'Ex: enigma_01_praca_matriz',
                ),
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Campos exclusivos do Ache e Ganhe
              if (_modoSelecionado == 'ACHE_E_GANHE') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _premioController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prêmio (R\$)',
                          border: OutlineInputBorder(),
                          prefixText: 'R\$ ',
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Defina um valor' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _raioController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Raio de Busca (m)',
                          border: OutlineInputBorder(),
                          suffixText: 'm',
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              // Botão de Salvar
              ElevatedButton(
                onPressed: _isSaving ? null : _salvarEnigma,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'PLANTAR ENIGMA NO MAPA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
