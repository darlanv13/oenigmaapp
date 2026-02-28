import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> evento;

  const EventDetailsScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    // Cores exatas do design
    const Color bgColor = Color(0xFF121212);
    const Color cardColor = Color(0xFF1E1E1E);
    const Color accentColor = Color(0xFFFFC107);

    // Extração segura de dados
    final titulo = evento['nome'] ?? 'Evento Desconhecido';
    final premio = evento['premio_total']?.toString() ?? '???';
    final local = evento['local'] ?? 'Não definido';
    final dataStr = evento['data_evento'] ?? 'Em breve';
    final fases = evento['fases']?.toString() ?? '0';
    final valorInscricao = (evento['valor_inscricao'] ?? 0.0).toDouble();
    final descricao = evento['descricao'] ?? 'Nenhuma descrição disponível.';

    final textoInscricao = valorInscricao == 0
        ? 'Grátis'
        : 'R\$ ${valorInscricao.toStringAsFixed(2).replaceAll('.', ',')}';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imagem de Topo (Idêntico ao design)
              Center(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  // Onde ficará a imagem real do evento futuramente
                  child: Center(
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Título Gigante
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 3. Troféu e Valor (Usando o Emoji exato da imagem)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  const Text(
                    'Prêmio: ',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  Text(
                    premio,
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 4. Grelha de Informações
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildInfoCard(
                    cardColor,
                    Icons.location_on_outlined,
                    'Local',
                    local,
                  ),
                  _buildInfoCard(
                    cardColor,
                    Icons.calendar_today_outlined,
                    'Data',
                    dataStr,
                  ),
                  _buildInfoCard(
                    cardColor,
                    Icons.filter_alt_outlined,
                    'Fases',
                    fases,
                  ),
                  _buildInfoCard(
                    cardColor,
                    Icons.monetization_on_outlined,
                    'Inscrição',
                    textoInscricao,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 5. Sobre o Evento
              const Text(
                'SOBRE O EVENTO',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                descricao,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: 100,
              ), // Espaço para o botão flutuante não cobrir texto
            ],
          ),
        ),
      ),

      // 6. Botão de Inscrição Fixo (Idêntico à imagem)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 30.0,
          top: 10.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [bgColor, bgColor.withOpacity(0.0)],
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.black, // Cor do texto e ícone
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          onPressed: () {
            // Lógica para chamar o Firebase e inscrever no evento
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 24), // Ícone idêntico ao da imagem
              const SizedBox(width: 8),
              Text(
                'Inscreva-se ($textoInscricao)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Componente interno dos pequenos cartões cinzas
  Widget _buildInfoCard(
    Color bgColor,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
