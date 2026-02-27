import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo simples para o Enigma no Mapa
class EnigmaMapMarker {
  final String id;
  final double lat;
  final double lon;
  final double raioMetros;
  final double premio;

  EnigmaMapMarker({
    required this.id,
    required this.lat,
    required this.lon,
    required this.raioMetros,
    required this.premio,
  });

  factory EnigmaMapMarker.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EnigmaMapMarker(
      id: doc.id,
      lat: data['lat'],
      lon: data['lon'],
      raioMetros:
          data['raio_metros']?.toDouble() ?? 150.0, // Ex: Área de busca de 150m
      premio: data['premio_dinheiro']?.toDouble() ?? 0.0,
    );
  }
}

// O Provider que escuta o Firestore em tempo real
final activeEnigmasProvider = StreamProvider.autoDispose<List<EnigmaMapMarker>>((
  ref,
) {
  final firestore = FirebaseFirestore
      .instance; // Se nomeou o banco, use: FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'oenigma')

  // Busca apenas enigmas do modo Ache e Ganhe que ainda não foram resolvidos (ativo: true)
  return firestore
      .collection('enigmas')
      .where('modo', isEqualTo: 'ACHE_E_GANHE')
      .where('ativo', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => EnigmaMapMarker.fromFirestore(doc))
            .toList();
      });
});
