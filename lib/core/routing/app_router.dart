import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oenigma/features/scanner_and_map/presentation/scanner_screen.dart';

// Criamos um Provider para o roteador. Isso é ótimo porque
// permite injetar lógicas de autenticação depois (ex: se não logou, vai pra tela de login)
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Splash Screen'),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Home do Jogo'),
      ),

      GoRoute(
        path: '/scanner',
        builder: (context, state) {
          final String enigmaId = state.extra as String;
          return ScannerScreen(enigmaId: enigmaId);
        },
      ),
    ],
  );
});

// Tela provisória só para o app não quebrar enquanto construímos o resto
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Construindo a tela: $title')),
    );
  }
}
