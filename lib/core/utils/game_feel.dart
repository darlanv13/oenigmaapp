import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class GameFeel {
  // Mantemos uma única instância do player para ser mais rápido
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Chamado quando o jogador acerta um enigma ou ganha dinheiro
  static Future<void> triggerSuccess() async {
    // 1. Vibração dupla (simula o peso de uma moeda a cair na mão)
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();

    // 2. Tocar o som de vitória/moeda
    // Nota: O pacote audioplayers já procura dentro da pasta 'assets/' automaticamente
    await _audioPlayer.play(AssetSource('sounds/coin.mp3'));
  }

  /// Chamado quando o GPS diz que o jogador está longe ou o QR Code é falso
  static Future<void> triggerError() async {
    // Vibração longa e agressiva
    HapticFeedback.vibrate();
    await _audioPlayer.play(AssetSource('sounds/error.mp3'));
  }

  /// Chamado em interações menores, como abrir uma dica ou clicar em botões importantes
  static void triggerLightTap() {
    // Apenas um estalo tátil muito suave, sem som
    HapticFeedback.lightImpact();
  }
}
