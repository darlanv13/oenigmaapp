import 'package:flutter/material.dart';

class PhaseEnigmasScreen extends StatelessWidget {
  final int numeroFase;
  // Na prática, você passaria os dados via Riverpod ou construtor
  final List<Map<String, dynamic>> enigmasDaFase;

  const PhaseEnigmasScreen({
    super.key,
    required this.numeroFase,
    required this.enigmasDaFase,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula quantos já foram resolvidos para a barra de progresso
    final resolvidos = enigmasDaFase
        .where((e) => e['resolvido'] == true)
        .length;
    final total = enigmasDaFase.length; // Sempre 3

    return Scaffold(
      appBar: AppBar(
        title: Text('Fase $numeroFase'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: total > 0 ? resolvidos / total : 0,
            backgroundColor: Colors.grey.shade800,
            color: Colors.greenAccent,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso: $resolvidos/$total Enigmas Resolvidos',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: enigmasDaFase.length,
                itemBuilder: (context, index) {
                  final enigma = enigmasDaFase[index];
                  final bool isResolvido = enigma['resolvido'] ?? false;

                  return Card(
                    elevation: isResolvido ? 0 : 4,
                    color: isResolvido ? Colors.green.shade50 : Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isResolvido ? Colors.green : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Enigma ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isResolvido)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Mostra um trecho da charada
                          Text(
                            enigma['charada'] ?? 'Carregando charada...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isResolvido
                                  ? null
                                  : () {
                                      // Abre a tela de Detalhes do Enigma
                                      // context.push('/enigma_detalhe', extra: enigma);
                                    },
                              icon: Icon(
                                isResolvido ? Icons.lock_open : Icons.search,
                              ),
                              label: Text(
                                isResolvido
                                    ? 'Resolvido'
                                    : 'Investigar e Comprar Dicas',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isResolvido
                                    ? Colors.grey.shade300
                                    : Colors.blue.shade900,
                                foregroundColor: isResolvido
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
