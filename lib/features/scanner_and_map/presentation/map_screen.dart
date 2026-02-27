import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/map_repository.dart';
import '../data/location_service.dart';
import 'widgets/victory_ticker.dart'; // Importamos o nosso novo widget

// Adicionamos o TickerProviderStateMixin para gerenciar animações nativas
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  LatLng? _initialPosition;
  bool _isLoadingLocation = true;

  // Variáveis da Animação
  late AnimationController _pulseController;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();

    // Configuração do "Coração" pulsante do mapa
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Tempo de cada pulso
    )..repeat(reverse: true); // Vai e volta infinitamente

    // O raio vai variar de 100% (1.0) até 120% (1.2) do tamanho original
    _radiusAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // A opacidade vai de 30% a 10% (fica mais transparente quando cresce)
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _getUserLocation() async {
    // ... (mesmo código que já tínhamos para pegar o GPS) ...
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _initialPosition = const LatLng(-14.2350, -51.9253);
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose(); // Muito importante limpar a animação!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation || _initialPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final enigmasAsyncValue = ref.watch(activeEnigmasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar de Enigmas'),
        backgroundColor: Colors.black87,
      ),
      body: enigmasAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar radar: $err')),
        data: (enigmas) {
          return Stack(
            children: [
              // 1. O MAPA (Envolvido pelo AnimatedBuilder para redesenhar a cada pulso)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  // Recalcula os círculos a cada frame da animação
                  Set<Circle> searchZones = enigmas.map((enigma) {
                    return Circle(
                      circleId: CircleId(enigma.id),
                      center: LatLng(enigma.lat, enigma.lon),
                      // Multiplica o raio original pelo valor da animação (ex: cresce 20%)
                      radius: enigma.raioMetros * _radiusAnimation.value,
                      // Aplica a opacidade animada na cor de preenchimento
                      // ignore: deprecated_member_use
                      fillColor: Colors.greenAccent.withOpacity(
                        _opacityAnimation.value,
                      ),
                      strokeColor: Colors.greenAccent,
                      strokeWidth: 2,
                      consumeTapEvents: true,
                      onTap: () {
                        // _showEnigmaDetails(enigma); (Método que já criamos antes)
                      },
                    );
                  }).toSet();

                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition!,
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    // Desligamos os botões nativos do Google Maps para limpar a interface
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    circles: searchZones, // Passa os círculos animados
                    onMapCreated: (GoogleMapController controller) {
                      // _mapController = controller;
                    },
                  );
                },
              ),

              // 2. O FEED DE VITÓRIAS (Sobreposto no topo do mapa)
              const Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: SafeArea(
                  // Garante que não fique embaixo do relógio do celular
                  child: VictoryTicker(),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/scanner');
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear Local'),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
