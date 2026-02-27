import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Escuta a coleção 'events' no Firestore em tempo real
final adminEventsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      return FirebaseFirestore.instance
          .collection('events')
          .orderBy('criadoEm', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] =
                  doc.id; // Injetamos o ID do documento no mapa para facilitar
              return data;
            }).toList();
          });
    });
