import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/game_functions_repository.dart';

// Este provider vai ser escutado pela tela do Scanner de QR Code
final solveEnigmaControllerProvider =
    AsyncNotifierProvider.autoDispose<SolveEnigmaController, void>(
      SolveEnigmaController.new,
    );

class SolveEnigmaController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Estado inicial é vazio (nenhuma ação rodando)
  }

  /// Método chamado quando o usuário lê o QR Code
  Future<void> submitEnigma({
    required String enigmaId,
    required String qrCode,
    required double lat,
    required double lon,
    required Function(String)
    onSuccess, // Callback para mostrar o prêmio na tela
    required Function(String) onError, // Callback para mostrar o erro na tela
  }) async {
    // 1. Muda o estado para CARREGANDO (faz o botão girar na tela)
    state = const AsyncValue.loading();

    // 2. Tenta executar a função
    state = await AsyncValue.guard(() async {
      try {
        final repository = ref.read(gameFunctionsRepositoryProvider);

        final result = await repository.solveEnigma(
          enigmaId: enigmaId,
          qrCodeScanned: qrCode,
          userLat: lat,
          userLon: lon,
        );

        if (result['success'] == true) {
          onSuccess(result['message']);
        }
      } catch (e) {
        onError(e.toString());
        rethrow; // Repassa o erro para o AsyncValue guardar
      }
    });
  }
}
