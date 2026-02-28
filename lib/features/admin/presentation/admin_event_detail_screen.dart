import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

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

  void _excluirEnigma(BuildContext context, String enigmaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Enigma'),
        content: const Text('Tem certeza que deseja apagar este enigma? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance.collection('enigmas').doc(enigmaId).delete();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enigma apagado.'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
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
          IconButton(
            icon: const Icon(Icons.pause),
            tooltip: 'Pausar Evento',
            onPressed: () => _ativarEvento(context, false),
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
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('enigmas')
                                .where('faseId', isEqualTo: faseId)
                                .snapshots(),
                            builder: (ctx, enigmaSnap) {
                              if (!enigmaSnap.hasData) {
                                return const CircularProgressIndicator();
                              }

                              final enigmas = enigmaSnap.data!.docs;
                              final qtd = enigmas.length;

                              return Column(
                                children: [
                                  if (qtd > 0)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: qtd,
                                      itemBuilder: (context, eIndex) {
                                        final enData = enigmas[eIndex].data() as Map<String, dynamic>;
                                        final eid = enigmas[eIndex].id;
                                        return ListTile(
                                          leading: const Icon(FontAwesomeIcons.puzzlePiece, size: 20),
                                          title: Text('Enigma ${eIndex + 1}'),
                                          subtitle: Text(
                                            enData['charada'] ?? 'Sem charada',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _excluirEnigma(context, eid),
                                          ),
                                        );
                                      },
                                    ),
                                  if (qtd == 0)
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('Nenhum enigma cadastrado nesta fase.', style: TextStyle(color: Colors.grey)),
                                    ),
                                  if (qtd < 3)
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        icon: const Icon(FontAwesomeIcons.locationDot),
                                        label: Text('Plantar Enigma nesta Fase (${3 - qtd} restantes)'),
                                        onPressed: () {
                                          // Aqui nós abrimos AQUELA TELA de capturar GPS que já construímos,
                                          // mas enviando o "faseId" para que o enigma fique amarrado a esta fase do evento!
                                          context.push(
                                            '/admin/create_enigma',
                                            extra: {
                                              'modo': 'SUPER_PREMIO',
                                              'faseId': faseId,
                                              'eventoId': eventId,
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  if (qtd >= 3)
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('✨ Fase Completa (3/3 Enigmas) ✨', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              );
                            },
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
