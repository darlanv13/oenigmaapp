import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider para buscar o ranking (Top 20 jogadores por saldo de moedas ou enigmas resolvidos)
final rankingProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final firestore = FirebaseFirestore.instance;
  // Ordena por enigmas resolvidos, depois por saldo de moedas
  return firestore
      .collection('users')
      .orderBy('enigmas_resolvidos_total', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
});

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(rankingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Ranking Global'),
        backgroundColor: Colors.amber.shade700,
      ),
      body: rankingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar ranking: $err')),
        data: (rankingList) {
          if (rankingList.isEmpty) {
            return const Center(child: Text('Nenhum jogador pontuou ainda!'));
          }

          return ListView.builder(
            itemCount: rankingList.length,
            itemBuilder: (context, index) {
              final player = rankingList[index];
              final String email = player['email'] ?? 'Anônimo';
              final String nomeExibicao = email.split('@')[0]; // Esconde o domínio
              final int enigmas = player['enigmas_resolvidos_total'] ?? 0;
              final int coins = player['saldo_moedas'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    foregroundColor: Colors.white,
                    child: Text('#${index + 1}'),
                  ),
                  title: Text(
                    nomeExibicao,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$enigmas enigmas resolvidos'),
                  trailing: Text(
                    '$coins 🪙',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Ouro
      case 1:
        return Colors.grey; // Prata
      case 2:
        return Colors.brown; // Bronze
      default:
        return Colors.blueGrey;
    }
  }
}
