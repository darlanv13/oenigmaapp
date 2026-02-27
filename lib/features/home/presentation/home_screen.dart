import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/auth_guard.dart'; // Importe o nosso guardião

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('O Enigma')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão público (Qualquer um pode ver o mapa)
            ElevatedButton(
              onPressed: () => context.push('/mapa'),
              child: const Text('Ver Radar de Enigmas (Ache e Ganhe)'),
            ),

            const SizedBox(height: 20),

            // Botão Protegido (Requer Login)
            ElevatedButton(
              onPressed: () {
                // Usamos o Guardião aqui!
                executeProtectedAction(
                  context: context,
                  ref: ref,
                  action: () {
                    // Isso só roda se ele estiver logado
                    context.push('/ranking');
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text(
                'Ver Ranking do Evento',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
