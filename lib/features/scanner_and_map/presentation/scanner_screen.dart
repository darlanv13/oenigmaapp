import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/location_service.dart';
import '../../game_core/presentation/controllers/solve_enigma_controller.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  final String
  enigmaId; // Precisamos saber qual enigma ele está tentando resolver

  const ScannerScreen({super.key, required this.enigmaId});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false; // Evita ler o mesmo QR Code 10 vezes por segundo

  Future<void> _processQrCode(BarcodeCapture capture) async {
    if (isProcessing) {
      return;
    } // Se já está processando, ignora as outras leituras

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final String qrCodeLido = barcodes.first.rawValue!;

    setState(() => isProcessing = true);
    cameraController.stop(); // Pausa a câmera para o app não travar

    try {
      // 1. Pega o GPS exato do jogador agora!
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();

      // 2. Envia para a nossa Cloud Function via Riverpod
      await ref
          .read(solveEnigmaControllerProvider.notifier)
          .submitEnigma(
            enigmaId: widget.enigmaId,
            qrCode: qrCodeLido,
            lat: position.latitude,
            lon: position.longitude,
            onSuccess: (mensagem) {
              _mostrarDialogo(sucesso: true, mensagem: mensagem);
            },
            onError: (erro) {
              _mostrarDialogo(sucesso: false, mensagem: erro);
            },
          );
    } catch (e) {
      _mostrarDialogo(sucesso: false, mensagem: e.toString());
    }
  }

  void _mostrarDialogo({required bool sucesso, required String mensagem}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(sucesso ? '🎉 Parabéns!' : '❌ Ops!'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
              if (sucesso) {
                Navigator.of(
                  context,
                ).pop(); // Volta pra tela anterior (mapa/lista)
              } else {
                // Se errou, liga a câmera de novo
                setState(() => isProcessing = false);
                cameraController.start();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fica escutando o estado para mostrar o Loading sobre a câmera
    final enigmaState = ref.watch(solveEnigmaControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Enigma'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () =>
                cameraController.toggleTorch(), // Botão de lanterna
          ),
        ],
      ),
      body: Stack(
        children: [
          // A câmera lendo em tempo real
          MobileScanner(controller: cameraController, onDetect: _processQrCode),

          // Mira (Overlay) no centro da tela
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Se estiver enviando para o servidor, mostra um Loading gigante na tela
          if (enigmaState.isLoading || isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
