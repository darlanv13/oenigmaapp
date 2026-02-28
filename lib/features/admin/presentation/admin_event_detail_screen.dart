import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';

class AdminEventDetailScreen extends StatelessWidget {
  final String eventId;
  final String eventName;

  const AdminEventDetailScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  void _ativarEvento(BuildContext context, bool ativar) {
    FirebaseFirestore.instance.collection('events').doc(eventId).update({
      'ativo': ativar,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ativar ? 'Evento publicado para os jogadores!' : 'Evento pausado.',
        ),
        backgroundColor: ativar ? Colors.green : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        backgroundColor: Colors.deepPurple.shade900,
        actions: [
          // Botão para você colocar o evento "No Ar" quando terminar de cadastrar os 15 enigmas (3 por fase)
          IconButton(
            icon: const Icon(Icons.publish),
            tooltip: 'Publicar Evento',
            onPressed: () => _ativarEvento(context, true),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: const Text(
              'Atenção: Cadastre exatamente 3 enigmas em cada uma das 5 fases. Use o GPS em campo para plantar as charadas.',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            // StreamBuilder nativo para ser rápido (poderia usar Riverpod, mas aqui é direto)
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('phases')
                  .where('id_evento', isEqualTo: eventId)
                  .orderBy('numero_fase')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final fases = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: fases
                      .length, // Sempre será 5, graças ao nosso Batch no arquivo anterior
                  itemBuilder: (context, index) {
                    final fase = fases[index].data() as Map<String, dynamic>;
                    final String faseId = fases[index].id;
                    final int numFase = fase['numero_fase'];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            '$numFase',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          'Fase $numFase',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Toque para ver/adicionar enigmas',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(FontAwesomeIcons.locationDot),
                              label: const Text('Plantar Enigma nesta Fase'),
                              onPressed: () {
                                // Aqui nós abrimos AQUELA TELA de capturar GPS que já construímos,
                                // mas enviando o "faseId" para que o enigma fique amarrado a esta fase do evento!
                                context.push(
                                  '/admin/create_enigma',
                                  extra: {
                                    'modo': 'SUPER_PREMIO',
                                    'faseId': faseId,
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
