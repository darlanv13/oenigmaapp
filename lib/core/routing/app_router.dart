// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oenigma/features/auth/presentation/login_screen.dart';
import 'package:oenigma/features/auth/presentation/register_screen.dart';
import 'package:oenigma/features/game_core/presentation/ranking_screen.dart';
import 'package:oenigma/features/home/presentation/home_screen.dart';
import 'package:oenigma/features/scanner_and_map/presentation/map_screen.dart';
import 'package:oenigma/features/scanner_and_map/presentation/scanner_screen.dart';
import 'package:oenigma/features/wallet/presentation/wallet_screen.dart';

// Criamos um Provider para o roteador. Isso é ótimo porque
// permite injetar lógicas de autenticação depois (ex: se não logou, vai pra tela de login)
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/mapa',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/ranking',
        builder: (context, state) => const RankingScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
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
