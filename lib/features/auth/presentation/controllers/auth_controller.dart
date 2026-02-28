import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';

// Lembra da nova sintaxe do Riverpod que ajustamos? Aqui usamos ela!
final authControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Estado inicial vazio
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String nome,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    // Ativa o loading na tela
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final repository = ref.read(authRepositoryProvider);

        await repository.register(
          email: email,
          password: password,
          cpf: cpf,
          phone: phone,
          nome: nome,
        );

        // Dispara o callback de sucesso
        onSuccess();
      } catch (e) {
        // Limpa a palavra "Exception: " do erro
        final erroLimpo = e.toString().replaceAll('Exception: ', '');
        onError(erroLimpo);
        rethrow;
      }
    });
  }

  Future<void> loginUser({
    required String email,
    required String password,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final repository = ref.read(authRepositoryProvider);
        await repository.login(email: email, password: password);
        onSuccess();
      } catch (e) {
        final erroLimpo = e.toString().replaceAll('Exception: ', '');
        onError(erroLimpo);
        rethrow;
      }
    });
  }
}
