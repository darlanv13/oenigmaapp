import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/location_service.dart';
import '../../game_core/presentation/controllers/solve_enigma_controller.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  final String?
  enigmaId; // Precisamos saber qual enigma ele está tentando resolver

  const ScannerScreen({super.key, this.enigmaId});

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

    await _enviarCodigo(qrCodeLido);
  }

  Future<void> _enviarCodigo(String codigoLido) async {
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
            enigmaId: widget.enigmaId ?? 'generic_scan',
            qrCode: codigoLido,
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

  void _mostrarDialogoEntradaManual() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Digitar Código'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Digite o código encontrado',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final codigo = textController.text.trim();
              if (codigo.isNotEmpty) {
                Navigator.of(ctx).pop();
                _enviarCodigo(codigo);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
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

          // Botão para digitar o código manualmente
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.keyboard),
                label: const Text('Digitar Código Manualmente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                onPressed: _mostrarDialogoEntradaManual,
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
