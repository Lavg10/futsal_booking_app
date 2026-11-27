import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationCoordinates {
  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
    this.name,
  });

  final double latitude;
  final double longitude;
  final String? name;
}

class LocationService {
  const LocationService();

  Future<LocationCoordinates?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LocationCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
      name: await _placeNameFor(position.latitude, position.longitude),
    );
  }

  Future<String?> _placeNameFor(double latitude, double longitude) async {
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[];
      void addPart(String? value) {
        final text = value?.trim();
        if (text != null && text.isNotEmpty && !parts.contains(text)) {
          parts.add(text);
        }
      }

      addPart(place.name);
      addPart(place.thoroughfare);
      addPart(place.locality);
      addPart(place.administrativeArea);
      addPart(place.country);
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }
}
