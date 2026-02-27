import 'package:flutter/material.dart';

// Simulação rápida para a interface (Na prática, viria do Riverpod/Firestore)
class SuperPremioScreen extends StatelessWidget {
  final String nomeEvento;
  final int
  faseAtualDoJogador; // Ex: Se ele está na fase 2, as fases 3, 4 e 5 ficam com cadeado.

  const SuperPremioScreen({
    super.key,
    required this.nomeEvento,
    this.faseAtualDoJogador = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nomeEvento),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              // Abre a tela de Ranking (Top 50)
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // São sempre 5 fases por evento
        itemBuilder: (context, index) {
          final int numeroDaFase = index + 1;
          final bool isBloqueada = numeroDaFase > faseAtualDoJogador;
          final bool isConcluida = numeroDaFase < faseAtualDoJogador;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: isBloqueada ? Colors.grey.shade200 : Colors.white,
            elevation: isBloqueada ? 0 : 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: isBloqueada
                    ? Colors.grey
                    : (isConcluida ? Colors.green : Colors.blue),
                child: Icon(
                  isBloqueada
                      ? Icons.lock
                      : (isConcluida ? Icons.check : Icons.play_arrow),
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Fase $numeroDaFase',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBloqueada ? Colors.grey : Colors.black87,
                ),
              ),
              subtitle: Text(
                isBloqueada
                    ? 'Complete a fase anterior para liberar.'
                    : '3 Enigmas aguardando você.',
              ),
              trailing: isBloqueada ? null : const Icon(Icons.chevron_right),
              onTap: isBloqueada
                  ? null
                  : () {
                      // Navega para a lista de 3 enigmas desta fase específica
                      // context.push('/evento/fases/$numeroDaFase/enigmas');
                    },
            ),
          );
        },
      ),
    );
  }
}
