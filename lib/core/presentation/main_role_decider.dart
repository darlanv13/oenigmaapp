import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importe os provedores e as telas
import '../../features/admin/data/admin_provider.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/scanner_and_map/presentation/map_screen.dart';

class MainRoleDecider extends ConsumerWidget {
  const MainRoleDecider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o provedor que verifica se o usuário logado tem a role 'admin'
    final isAdminAsync = ref.watch(isAdminProvider);

    return isAdminAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.greenAccent),
              SizedBox(height: 16),
              Text(
                'A decifrar credenciais...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Erro de conexão: $err'))),
      data: (isAdmin) {
        // A MÁGICA ACONTECE AQUI:
        if (isAdmin) {
          // Se for o Mestre do Jogo, a aplicação transforma-se no Backoffice
          return const AdminDashboardScreen();
        } else {
          // Se for um jogador normal, a aplicação transforma-se no Radar
          return const MapScreen();
        }
      },
    );
  }
}
