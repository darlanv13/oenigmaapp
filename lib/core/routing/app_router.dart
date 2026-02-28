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
import 'package:oenigma/features/shop_and_hints/presentation/metal_detector_screen.dart';
import 'package:oenigma/features/admin/presentation/admin_events_screen.dart';
import 'package:oenigma/features/admin/presentation/admin_event_detail_screen.dart';
import 'package:oenigma/features/admin/presentation/create_enigma_screen.dart';

// Criamos um Provider para o roteador. Isso é ótimo porque
// permite injetar lógicas de autenticação depois (ex: se não logou, vai pra tela de login)
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
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
          final String? enigmaId = state.extra as String?;
          return ScannerScreen(enigmaId: enigmaId);
        },
      ),
      GoRoute(
        path: '/detector',
        builder: (context, state) {
          final coords = state.extra as Map<String, double>;
          return MetalDetectorScreen(
            targetLat: coords['lat']!,
            targetLon: coords['lon']!,
          );
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminEventsScreen(),
      ),
      GoRoute(
        path: '/admin/events/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          final eventName = state.extra as String? ?? 'Detalhes do Evento';
          return AdminEventDetailScreen(
            eventId: eventId,
            eventName: eventName,
          );
        },
      ),
      GoRoute(
        path: '/admin/create_enigma',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CreateEnigmaScreen(
            modoLock: extra?['modo'] as String?,
            faseId: extra?['faseId'] as String?,
            eventoId: extra?['eventoId'] as String?,
          );
        },
      ),
    ],
  );
});
