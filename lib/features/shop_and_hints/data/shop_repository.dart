import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository();
});

class ShopRepository {
  // Apontando para a mesma região do nosso backend (São Paulo)
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  /// Chama a função de comprar dica e retorna o conteúdo desbloqueado
  Future<String> buyHint({
    required String enigmaId,
    required String hintId,
  }) async {
    try {
      // O nome gerado pelo Firebase para a nossa exportação no Node.js
      final callable = _functions.httpsCallable('shop-buyHint');

      final response = await callable.call({
        'enigmaId': enigmaId,
        'hintId': hintId,
      });

      // Retorna o conteúdo da dica (o texto extra, ou a URL da imagem/áudio)
      return response.data['conteudo'] as String;
    } on FirebaseFunctionsException catch (e) {
      // Exibe os erros que tratamos no backend (ex: "EnigmaCoins insuficientes")
      throw Exception(e.message ?? 'Erro ao processar a compra.');
    } catch (e) {
      throw Exception('Falha de conexão. Verifique sua internet.');
    }
  }
}
