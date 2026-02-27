import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider global para injetarmos o repositório onde precisarmos
final gameFunctionsRepositoryProvider = Provider<GameFunctionsRepository>((
  ref,
) {
  return GameFunctionsRepository();
});

class GameFunctionsRepository {
  // Apontando explicitamente para a região de São Paulo!
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  /// Chama a função de resolver o enigma
  Future<Map<String, dynamic>> solveEnigma({
    required String enigmaId,
    required String qrCodeScanned,
    required double userLat,
    required double userLon,
  }) async {
    try {
      // Como exportamos como 'exports.game = { solveEnigma: ... }' no Node.js,
      // o nome da função no Firebase vira 'game-solveEnigma'
      final callable = _functions.httpsCallable('game-solveEnigma');

      final response = await callable.call({
        'enigmaId': enigmaId,
        'qrCodeScanned': qrCodeScanned,
        'userLat': userLat,
        'userLon': userLon,
      });

      // Retorna os dados do servidor (ex: { success: true, message: "Você ganhou..." })
      return Map<String, dynamic>.from(response.data);
    } on FirebaseFunctionsException catch (e) {
      // Captura os erros que programamos no backend (ex: "Você está muito longe")
      throw Exception(e.message ?? 'Erro desconhecido ao validar o enigma.');
    } catch (e) {
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
  }
}
