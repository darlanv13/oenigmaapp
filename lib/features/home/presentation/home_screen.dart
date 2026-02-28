import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/utils/auth_guard.dart';
import '../data/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final eventsAsync = ref.watch(homeEventsProvider);
    final rankAsync = ref.watch(userRankingPositionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100], // Fundo leve
      appBar: AppBar(
        title: const Text('O Enigma', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.circleUser),
            onPressed: () {
              executeProtectedAction(
                context: context,
                ref: ref,
                action: () => context.push('/profile'), // Ou qualquer tela de perfil que você tenha
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // TOPO: Info do Usuário
          SliverToBoxAdapter(
            child: userProfileAsync.when(
              data: (user) {
                if (user == null) {
                  return _buildGuestHeader(context, ref);
                }
                final nome = user['nome']?.split(' ').first ?? 'Jogador';
                final customId = user['customId'] ?? '---';
                final saldo = user['saldo_carteira'] ?? 0.0;
                final rank = rankAsync.value ?? 0;

                return _buildUserHeader(
                  context,
                  ref,
                  nome: nome,
                  customId: customId,
                  saldo: saldo,
                  rank: rank,
                );
              },
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => const SizedBox(),
            ),
          ),

          // TÍTULO DA GRADE
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Eventos Disponíveis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // GRADE DE CARDS (Eventos)
          eventsAsync.when(
            data: (enigmas) {
              if (enigmas.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('Nenhum evento ativo no momento.')),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cards por linha
                    childAspectRatio: 0.75, // Altura maior que a largura
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final enigma = enigmas[index];
                      return _buildEventCard(context, enigma);
                    },
                    childCount: enigmas.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Erro ao carregar eventos: $e')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildGuestHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Text(
            'Você está como Visitante',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('Fazer Login / Criar Conta'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(
    BuildContext context,
    WidgetRef ref, {
    required String nome,
    required String customId,
    required dynamic saldo,
    required int rank,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $nome 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ID: $customId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Ranking', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    rank > 0 ? '#$rank' : '-',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/wallet'),
                  icon: const Icon(FontAwesomeIcons.wallet, size: 18),
                  label: Text('R\$ ${saldo.toStringAsFixed(2)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/ranking'),
                  icon: const Icon(FontAwesomeIcons.trophy, size: 18),
                  label: const Text('Top 100'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> enigma) {
    final modo = enigma['modo'] ?? 'ACHE_E_GANHE';
    final premio = enigma['premio_dinheiro'] ?? 0.0;
    // Opcional: imagem de background. Usando um placeholder genérico caso não tenha
    final imageUrl = enigma['imagem_url'] ?? 'https://via.placeholder.com/300x200.png?text=Enigma';
    final players = enigma['jogadores_ativos'] ?? 0; // Quantidade de pessoas buscando

    return GestureDetector(
      onTap: () {
        if (modo == 'ACHE_E_GANHE') {
          context.push('/mapa');
        } else {
          // Se for Super Prêmio, vai pra tela de detalhes do evento
          // context.push('/evento_detalhe', extra: enigma);
          context.push('/mapa'); // Fallback por enquanto
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do Card
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey[300],
                      child: const Icon(FontAwesomeIcons.image, color: Colors.grey, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.users, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            '$players',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Infos
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modo == 'ACHE_E_GANHE' ? 'Caçada no Mapa' : 'Evento Especial',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${premio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(FontAwesomeIcons.locationDot, size: 10, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Na sua cidade',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
