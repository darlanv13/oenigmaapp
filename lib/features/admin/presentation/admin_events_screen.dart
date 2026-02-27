import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:go_router/go_router.dart';
import '../data/admin_events_provider.dart';

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  // Função para criar um novo evento e estruturar as 5 fases automaticamente
  Future<void> _criarNovoEvento(BuildContext context, String nomeEvento) async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. Cria o documento do Evento
      final eventoRef = await db.collection('events').add({
        'nome': nomeEvento,
        'ativo':
            false, // Nasce inativo até você terminar de cadastrar os enigmas
        'criadoEm': FieldValue.serverTimestamp(),
      });

      // 2. Cria as 5 fases dentro deste evento usando um Batch (Lote) para ser instantâneo
      final batch = db.batch();
      for (int i = 1; i <= 5; i++) {
        final faseRef = db.collection('phases').doc(); // Gera um ID aleatório
        batch.set(faseRef, {'id_evento': eventoRef.id, 'numero_fase': i});
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento e 5 Fases criados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _abrirDialogNovoEvento(BuildContext context) {
    final TextEditingController nomeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Evento Super Prêmio'),
        content: TextField(
          controller: nomeController,
          decoration: const InputDecoration(
            hintText: 'Ex: Caçada do Centro Histórico',
            border: OutlineInputBorder(),
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
              if (nomeController.text.isNotEmpty) {
                Navigator.pop(ctx);
                _criarNovoEvento(context, nomeController.text);
              }
            },
            child: const Text('Criar Estrutura'),
          ),
        ],
      ),
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
                        ? 'Status: ATIVO (Rodando)'
                        : 'Status: RASCUNHO (Oculto)',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navega para a tela de detalhes do evento (para preencher as fases)
                    // context.push('/admin/events/${evento['id']}', extra: evento['nome']);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirDialogNovoEvento(context),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Novo Evento'),
      ),
    );
  }
}
