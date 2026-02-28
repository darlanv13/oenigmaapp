import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/buy_hint_controller.dart';

class HintTileWidget extends ConsumerWidget {
  final String enigmaId;
  final String hintId;
  final IconData icon;
  final String title;
  final String subtitle;
  final int priceCoins;
  final bool isUnlocked;
  final String? conteudoDesbloqueado;

  const HintTileWidget({
    super.key,
    required this.enigmaId,
    required this.hintId,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.priceCoins,
    required this.isUnlocked,
    this.conteudoDesbloqueado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o estado do controlador de compras (Loading, Success, Error)
    final buyState = ref.watch(buyHintControllerProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnlocked
              // ignore: deprecated_member_use
              ? Colors.blueAccent.withOpacity(0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUnlocked
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          child: Icon(
            icon,
            color: isUnlocked ? Colors.blue.shade900 : Colors.grey,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        // Se estiver desbloqueado, mostra o conteúdo real da dica!
        subtitle: isUnlocked && conteudoDesbloqueado != null
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  conteudoDesbloqueado!,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              )
            : Text(subtitle),
        trailing: isUnlocked
            ? const Icon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 30)
            : buyState.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$priceCoins 🪙',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
        onTap: () {
          // Se já está a carregar ou se a dica já é do jogador, ignora o clique
          if (buyState.isLoading || isUnlocked) return;

          _confirmarCompra(context, ref);
        },
      ),
    );
  }

  void _confirmarCompra(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desbloquear Dica?'),
        content: Text(
          'Deseja gastar $priceCoins EnigmaCoins para revelar esta pista?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx); // Fecha o modal de confirmação

              // Dispara a Cloud Function
              ref
                  .read(buyHintControllerProvider.notifier)
                  .purchaseHint(
                    enigmaId: enigmaId,
                    hintId: hintId,
                    onSuccess: (conteudo) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dica revelada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    onError: (erro) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(erro),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  );
            },
            child: const Text('Confirmar Compra'),
          ),
        ],
      ),
    );
  }
}
