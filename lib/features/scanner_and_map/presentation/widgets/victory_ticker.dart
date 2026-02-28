import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/victory_feed_provider.dart';

class VictoryTicker extends ConsumerStatefulWidget {
  const VictoryTicker({super.key});

  @override
  ConsumerState<VictoryTicker> createState() => _VictoryTickerState();
}

class _VictoryTickerState extends ConsumerState<VictoryTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Alterna a mensagem a cada 4 segundos
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex++;
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
    // Escuta os feeds reais vindos do banco de dados (Firestore)
    final feedAsync = ref.watch(victoryFeedProvider);

    // Lista padrão garantida enquanto carrega ou em caso de erro
    final List<String> mensagens = feedAsync.when(
      data: (lista) => lista.isEmpty ? ["Nenhum prêmio recente."] : lista,
      loading: () => ["Buscando vencedores recentes..."],
      error: (e, stack) => ["🏆 Continue procurando tesouros!"],
    );

    // Calcula o índice atual seguro baseado no tamanho da lista disponível
    final int safeIndex = mensagens.isEmpty ? 0 : _currentIndex % mensagens.length;
    final String mensagemAtual = mensagens.isEmpty ? "" : mensagens[safeIndex];

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
          mensagemAtual,
          key: ValueKey<int>(
            safeIndex,
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
