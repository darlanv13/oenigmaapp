import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../scanner_and_map/data/location_service.dart';

class CreateEnigmaScreen extends ConsumerStatefulWidget {
  final String? modoLock;
  final String? faseId;
  final String? eventoId;

  const CreateEnigmaScreen({
    super.key,
    this.modoLock,
    this.faseId,
    this.eventoId,
  });

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
  late String _modoSelecionado;

  @override
  void initState() {
    super.initState();
    _modoSelecionado = widget.modoLock ?? 'ACHE_E_GANHE';
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS Capturado com Sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no GPS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
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
      final enigmaData = {
        'modo': _modoSelecionado,
        'charada': _charadaController.text,
        'codigo_qr_esperado': _qrCodeController.text,
        'lat': _lat,
        'lon': _lon,
        'ativo': true,
        'criadoEm': FieldValue.serverTimestamp(),
      };

      // Adiciona campos dinâmicos dependendo do modo
      if (_modoSelecionado == 'ACHE_E_GANHE') {
        enigmaData['premio_dinheiro'] = double.tryParse(_premioController.text) ?? 0.0;
        enigmaData['raio_metros'] = double.tryParse(_raioController.text) ?? 150.0;
      } else if (_modoSelecionado == 'SUPER_PREMIO') {
        if (widget.faseId != null) enigmaData['faseId'] = widget.faseId;
        if (widget.eventoId != null) enigmaData['eventoId'] = widget.eventoId;
      }

      await FirebaseFirestore.instance.collection('enigmas').add(enigmaData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enigma Lançado! Já está no mapa!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta pro Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
                            : const Icon(FontAwesomeIcons.locationCrosshairs),
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
                // ignore: deprecated_member_use
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
                // Trava o dropdown se o modo foi injetado (ex: SUPER_PREMIO via tela de fase)
                onChanged: widget.modoLock != null
                    ? null
                    : (val) => setState(() => _modoSelecionado = val!),
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

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qrCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Texto que está no QR Code Físico',
                        border: OutlineInputBorder(),
                        helperText: 'Ex: enigma_01_praca_matriz',
                      ),
                      validator: (val) =>
                          val!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.arrowsRotate),
                    tooltip: 'Gerar Hash Seguro',
                    onPressed: () {
                      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                      final rnd = Random();
                      final hash = String.fromCharCodes(
                        Iterable.generate(
                          8,
                          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
                        ),
                      );
                      setState(() {
                        _qrCodeController.text = 'OENIGMA-$hash';
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
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
