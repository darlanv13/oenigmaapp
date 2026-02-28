import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../data/admin_events_provider.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  // Função para criar um novo evento e estruturar as 5 fases automaticamente
  Future<void> _criarNovoEvento(
      BuildContext context, String nomeEvento, String descricao, double premioTotal, String local) async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. Cria o documento do Evento
      final eventoRef = await db.collection('events').add({
        'nome': nomeEvento,
        'descricao': descricao,
        'premio_total': premioTotal,
        'local': local,
        'fases': 5,
        'tipo_evento': 'SUPER_PREMIO',
        'valor_inscricao': 0,
        'imagem_url': '',
        'ativo': false, // Nasce inativo até você terminar de cadastrar os enigmas
        'criadoEm': FieldValue.serverTimestamp(),
      });

      // 2. Cria as 5 fases dentro deste evento usando um Batch (Lote) para ser instantâneo
      final batch = db.batch();
      for (int i = 1; i <= 5; i++) {
        final faseRef = db.collection('phases').doc(); // Gera um ID aleatório
        batch.set(faseRef, {'id_evento': eventoRef.id, 'numero_fase': i});
      }
      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento e 5 Fases criados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _abrirDialogNovoEvento(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();
    final descController = TextEditingController();
    final premioController = TextEditingController();
    final localController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Evento Super Prêmio'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome', hintText: 'Ex: Caçada do Centro Histórico'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descrição', hintText: 'Ex: Encontre o QR Code...'),
                ),
                TextFormField(
                  controller: premioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prêmio Total (R\$)', hintText: 'Ex: 50.00'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                TextFormField(
                  controller: localController,
                  decoration: const InputDecoration(labelText: 'Local', hintText: 'Ex: Centro Histórico'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final premio = double.tryParse(premioController.text) ?? 0.0;
                Navigator.pop(ctx);
                _criarNovoEvento(context, nomeController.text, descController.text, premio, localController.text);
              }
            },
            child: const Text('Criar Estrutura'),
          ),
        ],
      ),
    );
  }

  void _abrirMenuCriacao(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.trophy, color: Colors.amber),
                title: const Text('Criar Evento SUPER PRÊMIO'),
                subtitle: const Text('Cria um evento com 5 fases e múltiplos enigmas.'),
                onTap: () {
                  Navigator.pop(ctx);
                  _abrirDialogNovoEvento(context);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.mapLocationDot, color: Colors.green),
                title: const Text('Plantar Enigma ACHE E GANHE'),
                subtitle: const Text('Planta um enigma solto diretamente no mapa.'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/admin/create_enigma', extra: {'modo': 'ACHE_E_GANHE'});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Eventos'),
        backgroundColor: Colors.deepPurple.shade900,
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (eventos) {
          if (eventos.isEmpty) {
            return const Center(child: Text('Nenhum evento criado ainda.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              final bool isAtivo = evento['ativo'] ?? false;
              final premio = evento['premio_total'] ?? 0.0;
              final tipo = evento['tipo_evento'] ?? 'Desconhecido';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isAtivo ? Colors.green : Colors.grey,
                    child: Icon(
                      isAtivo ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    evento['nome'] ?? 'Sem Nome',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    isAtivo
                        ? 'Status: ATIVO (Rodando)\nTipo: $tipo\nPrêmio: R\$ $premio'
                        : 'Status: RASCUNHO (Oculto)\nTipo: $tipo\nPrêmio: R\$ $premio',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navega para a tela de detalhes do evento (para preencher as fases)
                    context.push('/admin/events/${evento['id']}', extra: evento['nome']);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirMenuCriacao(context),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(FontAwesomeIcons.plus),
        label: const Text('Novo Cadastro'),
      ),
    );
  }
}
