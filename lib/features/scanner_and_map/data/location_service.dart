import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  /// Verifica permissões e retorna a posição atual do jogador
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('O GPS está desativado. Ligue para jogar.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Você precisa permitir a localização para validar o enigma.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de GPS negada permanentemente. Altere nas configurações do celular.',
      );
    }

    // Pega a localização com alta precisão (essencial para o raio de 50 metros)
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    // Proteção Anti-Fraude e Fake GPS
    if (position.isMocked) {
      throw Exception(
        '🚫 ATENÇÃO! Uso de Fake GPS ou Mock Location detectado. Jogue de forma justa para evitar banimento.',
      );
    }

    return position;
  }
}
