import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stream que ouve os últimos prêmios encontrados
final victoryFeedProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('victories') // Coleção de histórico de saques e tesouros achados
      .orderBy('timestamp', descending: true)
      .limit(10) // Pega os 10 mais recentes
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) {
      // Mensagens padrão caso o banco esteja vazio
      return [
        "🏆 O próximo prêmio pode ser o seu!",
        "🔥 Ache os códigos escondidos pela cidade.",
        "💸 Saques instantâneos via PIX no seu App!",
      ];
    }

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final jogador = data['jogador'] ?? 'Alguém';
      final valor = data['valor'] ?? '0.00';
      final local = data['local'] ?? 'na cidade';

      return "🏆 $jogador acabou de achar R\$ $valor $local!";
    }).toList();
  });
});
