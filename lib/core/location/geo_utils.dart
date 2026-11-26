import 'dart:math' as math;

import 'package:geohash_plus/geohash_plus.dart';

abstract final class GeoUtils {
  static const double earthRadiusKm = 6371;

  static double haversineDistanceKm({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
  }) {
    final lat1 = _toRadians(latitude1);
    final lat2 = _toRadians(latitude2);
    final deltaLat = _toRadians(latitude2 - latitude1);
    final deltaLng = _toRadians(longitude2 - longitude1);

    final a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(deltaLng / 2), 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadiusKm * c;
  }

  static String encodeGeohash(double latitude, double longitude) {
    return GeoHash.encode(latitude, longitude).hash;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
