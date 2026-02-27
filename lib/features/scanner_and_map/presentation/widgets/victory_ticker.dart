import 'dart:async';
import 'package:flutter/material.dart';

class VictoryTicker extends StatefulWidget {
  const VictoryTicker({super.key});

  @override
  State<VictoryTicker> createState() => _VictoryTickerState();
}

class _VictoryTickerState extends State<VictoryTicker> {
  // Lista simulada (No futuro, virá do Firebase)
  final List<String> _mensagens = [
    "🏆 Marcos_88 acabou de achar R\$ 50,00 no Centro!",
    "🔥 Alguém resolveu o Enigma 3 do Super Prêmio!",
    "💸 Ana_C sacou R\$ 120,00 via PIX agora mesmo!",
    "🏃‍♂️ Faltam 2 horas para o Enigma Oculto sumir!",
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Alterna a mensagem a cada 4 segundos
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _mensagens.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.7), // Fundo escuro translúcido
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          // ignore: deprecated_member_use
          color: Colors.greenAccent.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.greenAccent.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Animação de Fade e leve deslize vertical
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          _mensagens[_currentIndex],
          key: ValueKey<int>(
            _currentIndex,
          ), // Fundamental para o AnimatedSwitcher entender a troca
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
