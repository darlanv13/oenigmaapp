import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Escuta as alterações no documento do usuário em tempo real
final userWalletStreamProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Usuário não autenticado');

  final firestore = FirebaseFirestore.instance;
  
  return firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
    if (!snapshot.exists) return {'saldo_carteira': 0.0, 'saldo_moedas': 0};
    return snapshot.data() as Map<String, dynamic>;
  });
});