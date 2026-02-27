import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para a função de "Copiar"
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provedor que escuta apenas os saques que estão aguardando pagamento
final pendingWithdrawalsProvider =
    StreamProvider.autoDispose<List<QueryDocumentSnapshot>>((ref) {
      return FirebaseFirestore.instance
          .collection('withdraw_requests')
          .where('status', isEqualTo: 'PENDENTE')
          .orderBy(
            'solicitadoEm',
            descending: false,
          ) // Os mais antigos primeiro
          .snapshots()
          .map((snapshot) => snapshot.docs);
    });

class AdminWithdrawalsScreen extends ConsumerWidget {
  const AdminWithdrawalsScreen({super.key});

  // Função para atualizar o status no banco de dados
  Future<void> _atualizarStatus(
    BuildContext context,
    String docId,
    String novoStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('withdraw_requests')
          .doc(docId)
          .update({
            'status': novoStatus,
            'processadoEm': FieldValue.serverTimestamp(),
          });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saque marcado como $novoStatus!'),
          backgroundColor: novoStatus == 'PAGO' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalsAsync = ref.watch(pendingWithdrawalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprovar Saques (PIX)'),
        backgroundColor: Colors.amber.shade800,
      ),
      body: withdrawalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar fila: $err')),
        data: (pedidos) {
          if (pedidos.isEmpty) {
            return const Center(
              child: Text(
                'Tudo limpo! Nenhuma pendência de pagamento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index].data() as Map<String, dynamic>;
              final String docId = pedidos[index].id;
              final double valor = pedido['valor'] ?? 0.0;
              final String chavePix = pedido['chavePix'] ?? 'Erro de Chave';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.amber.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Solicitação de Saque',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'R\$ ${valor.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Chave PIX (CPF):',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  chavePix,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.blue),
                              tooltip: 'Copiar Chave',
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: chavePix),
                                ); // Copia para a área de transferência
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Chave PIX copiada!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () =>
                                  _atualizarStatus(context, docId, 'RECUSADO'),
                              child: const Text('Recusar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.check),
                              label: const Text('PIX Enviado'),
                              onPressed: () =>
                                  _atualizarStatus(context, docId, 'PAGO'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
