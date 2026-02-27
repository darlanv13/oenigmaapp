import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_provider.dart';

/// Executa a ação se estiver logado. Se não, abre a tela de login.
void executeProtectedAction({
  required BuildContext context,
  required WidgetRef ref,
  required VoidCallback action, // A ação que o usuário queria fazer
}) {
  final isLoggedIn = ref.read(isLoggedInProvider);

  if (isLoggedIn) {
    // Se tem conta, faz o que ele pediu na hora (ex: abrir o ranking)
    action();
  } else {
    // Se é visitante, mostra um BottomSheet amigável pedindo para logar
    _showLoginPrompt(context);
  }
}

void _showLoginPrompt(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_person, size: 64, color: Colors.blueGrey),
            const SizedBox(height: 16),
            const Text(
              'Crie sua conta para jogar!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Para entrar no ranking, participar dos eventos Super Prêmio e sacar seu dinheiro na carteira, você precisa estar logado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Fecha o modal
                  context.push(
                    '/login',
                  ); // Leva para a tela de Login de verdade
                },
                child: const Text('Fazer Login ou Cadastro'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Agora não, quero só olhar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    },
  );
}
