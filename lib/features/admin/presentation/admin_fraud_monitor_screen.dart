import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Escuta os últimos 50 alertas de fraude gerados pelo backend
final fraudAlertsProvider =
    StreamProvider.autoDispose<List<QueryDocumentSnapshot>>((ref) {
      return FirebaseFirestore.instance
          .collection('fraud_alerts')
          .orderBy('dataHora', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    });

class AdminFraudMonitorScreen extends ConsumerWidget {
  const AdminFraudMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(fraudAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Fraudes'),
        backgroundColor: Colors.red.shade900,
      ),
      body: alertsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar monitor: $err')),
        data: (alertas) {
          if (alertas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 80, color: Colors.green.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Jogo Limpo! Nenhum alerta recente.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: alertas.length,
            itemBuilder: (context, index) {
              final alerta = alertas[index].data() as Map<String, dynamic>;

              // Exemplo de dados: tipo ("FAKE_GPS", "MULTIPLE_SCANS"), uid do usuário, mensagem.
              final String tipo = alerta['tipo'] ?? 'ALERTA';
              final String mensagem =
                  alerta['mensagem'] ?? 'Atividade suspeita detectada.';
              final String uid = alerta['uid'] ?? 'Desconhecido';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                  title: Text(
                    tipo.replaceAll('_', ' '),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(mensagem),
                      const SizedBox(height: 4),
                      Text(
                        'Usuário ID: $uid',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.block, color: Colors.red),
                    tooltip: 'Banir Usuário',
                    onPressed: () {
                      // Aqui você chamaria uma Cloud Function para alterar o status do usuário para "banido: true"
                      _confirmarBanimento(context, uid);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarBanimento(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Banir Jogador?'),
        content: const Text(
          'Isso impedirá o jogador de fazer login e zerará sua carteira. Tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Lógica de banimento
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuário banido com sucesso.')),
              );
            },
            child: const Text('Sim, Banir'),
          ),
        ],
      ),
    );
  }
}
