import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este provider vai ler a subcoleção 'unlocked_hints' do utilizador
final unlockedHintsProvider = StreamProvider.autoDispose
    .family<Map<String, String>, String>((ref, enigmaId) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null)
        return Stream.value({}); // Retorna mapa vazio se não estiver logado

      final firestore = FirebaseFirestore.instance;

      return firestore
          .collection('users')
          .doc(user.uid)
          .collection('unlocked_hints')
          .where('enigmaId', isEqualTo: enigmaId)
          .snapshots()
          .map((snapshot) {
            // Converte os documentos num Mapa: { 'hintId': 'conteudo_da_dica' }
            final Map<String, String> dicas = {};
            for (var doc in snapshot.docs) {
              dicas[doc.id] = doc.data()['conteudo'] as String;
            }
            return dicas;
          });
    });
