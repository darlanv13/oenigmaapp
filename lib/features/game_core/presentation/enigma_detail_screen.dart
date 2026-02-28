import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Importações dos widgets e providers da funcionalidade de dicas
// Ajuste os caminhos relativos de acordo com a estrutura do seu projeto
import '../../shop_and_hints/presentation/widgets/hint_tile_widget.dart';
import '../../shop_and_hints/data/hints_provider.dart';

// Mudamos de StatelessWidget para ConsumerWidget para usar o Riverpod
class EnigmaDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> enigma; // Dados do enigma selecionado
  final String modoJogo; // "ACHE_E_GANHE" ou "SUPER_PREMIO"

  const EnigmaDetailScreen({
    super.key,
    required this.enigma,
    required this.modoJogo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAcheEGanhe = modoJogo == 'ACHE_E_GANHE';
    final String enigmaId = enigma['id'] ?? 'id_desconhecido';

    // O Riverpod escuta em tempo real as dicas que o jogador já comprou para este enigma
    final unlockedHintsAsync = ref.watch(unlockedHintsProvider(enigmaId));

    // Extrai o mapa de dicas desbloqueadas (ou um mapa vazio enquanto carrega)
    final unlockedHints = unlockedHintsAsync.value ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(isAcheEGanhe ? 'Caçada Premiada' : 'Missão Ativa'),
        backgroundColor: isAcheEGanhe
            ? Colors.green.shade900
            : Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com o Prêmio (se for Ache e Ganhe)
            if (isAcheEGanhe)
              Container(
                color: Colors.green.shade800,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Prêmio deste Enigma:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'R\$ ${enigma['premio_dinheiro'] ?? '0,00'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'A Charada:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // A Charada Principal
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      enigma['charada'] ??
                          'Onde a água canta de manhã, mas não tem boca. Vá até lá e encontre o símbolo no ferro frio.',
                      style: const TextStyle(fontSize: 20, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Dicas Disponíveis:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Lista de Dicas agora usa o HintTileWidget reativo
                  HintTileWidget(
                    enigmaId: enigmaId,
                    hintId: 'dica_texto_1', // Exemplo de ID da dica
                    icon: Icons.text_snippet,
                    title: 'Dica de Texto',
                    subtitle: 'Uma pista extra escrita.',
                    priceCoins: 50,
                    // Verifica automaticamente se o jogador já possui essa dica
                    isUnlocked: unlockedHints.containsKey('dica_texto_1'),
                    conteudoDesbloqueado: unlockedHints['dica_texto_1'],
                  ),
                  HintTileWidget(
                    enigmaId: enigmaId,
                    hintId: 'dica_foto_1',
                    icon: Icons.image,
                    title: 'Foto do Local',
                    subtitle: 'Uma foto desfocada ou um detalhe do lugar.',
                    priceCoins: 150,
                    isUnlocked: unlockedHints.containsKey('dica_foto_1'),
                    conteudoDesbloqueado: unlockedHints['dica_foto_1'],
                  ),
                  HintTileWidget(
                    enigmaId: enigmaId,
                    hintId: 'dica_gps_1',
                    icon: Icons.radar,
                    title: 'Aproximação GPS',
                    subtitle: 'Reduz a área de busca no mapa para 20 metros.',
                    priceCoins: 300,
                    isUnlocked: unlockedHints.containsKey('dica_gps_1'),
                    conteudoDesbloqueado: unlockedHints['dica_gps_1'],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Botão do Detector de Metais
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade700, Colors.deepPurple],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.track_changes, color: Colors.white, size: 40),
                      title: const Text(
                        'Usar Detector de Metais',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Acha que está perto? Ligue o radar para encontrar a localização exata.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          // Aqui idealmente checaríamos saldo ou se comprou o item
                          // Navega para a tela do radar
                          final lat = enigma['lat'] is double ? enigma['lat'] : double.tryParse(enigma['lat'].toString()) ?? 0.0;
                          final lon = enigma['lon'] is double ? enigma['lon'] : double.tryParse(enigma['lon'].toString()) ?? 0.0;

                          context.push('/detector', extra: {
                            'lat': lat,
                            'lon': lon,
                          });
                        },
                        child: const Text('LIGAR'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Botão Fixo na base para abrir a Câmera
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner, size: 28),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'ESTOU NO LOCAL - ESCANEAR QR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAcheEGanhe
                  ? Colors.green
                  : Colors.blue.shade900,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Navega para a tela ScannerScreen enviando o ID do enigma
              context.push('/scanner', extra: enigmaId);
            },
          ),
        ),
      ),
    );
  }
}
