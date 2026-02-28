import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para pegar os dados do usuário atual
final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.data());
});

// Provider para buscar a posição no ranking (baseado em enigmas_resolvidos_total ou saldo)
final userRankingPositionProvider = FutureProvider<int>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!userDoc.exists) return 0;

  final userScore = userDoc.data()?['enigmas_resolvidos_total'] ?? 0;

  // Conta quantos usuários têm um score MAIOR que o desse usuário
  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('enigmas_resolvidos_total', isGreaterThan: userScore)
      .get();

  // A posição é a quantidade de pessoas na frente + 1
  return query.docs.length + 1;
});

// Provider para os cards de eventos (Ache e Ganhe, Super Prêmio, etc)
final homeEventsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('enigmas')
      .where('ativo', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  });
});
