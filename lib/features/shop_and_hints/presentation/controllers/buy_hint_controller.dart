import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/shop_repository.dart';

final buyHintControllerProvider =
    AsyncNotifierProvider.autoDispose<BuyHintController, void>(
      BuyHintController.new,
    );

class BuyHintController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Estado inicial
  }

  Future<void> purchaseHint({
    required String enigmaId,
    required String hintId,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    // Ativa o estado de "Carregando" na tela
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final repository = ref.read(shopRepositoryProvider);

        // Dispara a requisição para o servidor
        final conteudoDesbloqueado = await repository.buyHint(
          enigmaId: enigmaId,
          hintId: hintId,
        );

        // Devolve o conteúdo para a interface exibir
        onSuccess(conteudoDesbloqueado);
      } catch (e) {
        // Formata o erro removendo a palavra "Exception:" padrão do Dart
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        onError(errorMessage);
        throw e; // Mantém o erro no estado do Riverpod
      }
    });
  }
}
