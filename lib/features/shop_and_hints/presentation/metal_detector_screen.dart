import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetalDetectorScreen extends ConsumerStatefulWidget {
  final double targetLat;
  final double targetLon;

  const MetalDetectorScreen({
    super.key,
    required this.targetLat,
    required this.targetLon,
  });

  @override
  ConsumerState<MetalDetectorScreen> createState() =>
      _MetalDetectorScreenState();
}

class _MetalDetectorScreenState extends ConsumerState<MetalDetectorScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<Position>? _positionStream;
  double _currentDistance = double.infinity;
  bool _isDetecting = false;
  Timer? _vibrationTimer;

  // Animação do "radar"
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _iniciarBussola() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ligue o GPS primeiro!')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    setState(() {
      _isDetecting = true;
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // Atualiza a cada 1 metro de movimento
      ),
    ).listen((Position position) {
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.targetLat,
        widget.targetLon,
      );

      setState(() {
        _currentDistance = distanceInMeters;
      });

      _ajustarVibracao(distanceInMeters);
    });
  }

  void _ajustarVibracao(double distance) {
    _vibrationTimer?.cancel();

    if (distance > 150) {
      // Fora de alcance
      return;
    }

    // Calcula o intervalo de vibração baseado na distância.
    // Quanto menor a distância, menor o intervalo (mais rápido vibra)
    int intervalMs = 2000;
    if (distance < 10) {
      intervalMs = 200; // Tá muito quente!
      _radarController.duration = const Duration(milliseconds: 300);
    } else if (distance < 30) {
      intervalMs = 500; // Quente
      _radarController.duration = const Duration(milliseconds: 800);
    } else if (distance < 80) {
      intervalMs = 1000; // Esquentando
      _radarController.duration = const Duration(milliseconds: 1500);
    } else {
      intervalMs = 2000; // Frio
      _radarController.duration = const Duration(seconds: 2);
    }
    _radarController.repeat();

    _vibrationTimer = Timer.periodic(Duration(milliseconds: intervalMs), (
      timer,
    ) {
      HapticFeedback.heavyImpact();
    });
  }

  void _pararBussola() {
    _positionStream?.cancel();
    _vibrationTimer?.cancel();
    setState(() {
      _isDetecting = false;
      _currentDistance = double.infinity;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _vibrationTimer?.cancel();
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detector de Enigmas'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // O Radar visual
                AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    return Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.greenAccent.withValues(
                            alpha: 1.0 - _radarController.value,
                          ),
                          width: 4 + (20 * _radarController.value),
                        ),
                      ),
                    );
                  },
                ),
                Icon(
                  Icons.radar,
                  size: 100,
                  color: _isDetecting ? Colors.greenAccent : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 50),
            Text(
              _isDetecting
                  ? (_currentDistance > 150
                      ? 'Nenhum sinal detectado...'
                      : 'Distância aproximada: ${_currentDistance.toStringAsFixed(0)}m')
                  : 'Detector desligado',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(_isDetecting ? Icons.stop : Icons.power_settings_new),
              label: Text(_isDetecting ? 'Desligar' : 'Ligar Detector'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDetecting ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                if (_isDetecting) {
                  _pararBussola();
                } else {
                  _iniciarBussola();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
