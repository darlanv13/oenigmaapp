import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Comando'),
        backgroundColor: Colors
            .deepPurple
            .shade900, // Cor diferente para você saber que está no Admin
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAdminCard(
            context,
            title: 'Novo Enigma',
            icon: FontAwesomeIcons.locationDot,
            color: Colors.green,
            onTap: () => context.push('/admin/create_enigma'),
          ),
          _buildAdminCard(
            context,
            title: 'Aprovar Saques (PIX)',
            icon: Icons.payments,
            color: Colors.amber.shade700,
            onTap: () {
              // context.push('/admin/withdrawals');
            },
          ),
          _buildAdminCard(
            context,
            title: 'Gerenciar Eventos',
            icon: Icons.emoji_events,
            color: Colors.blue.shade800,
            onTap: () {
              // context.push('/admin/events');
            },
          ),
          _buildAdminCard(
            context,
            title: 'Monitor de Fraudes',
            icon: FontAwesomeIcons.shieldHalved,
            color: Colors.red.shade800,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: color,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
