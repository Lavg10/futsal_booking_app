import 'package:flutter_test/flutter_test.dart';
import 'package:futsal_app/core/location/geo_utils.dart';

void main() {
  group('GeoUtils', () {
    test('returns zero distance for the same point', () {
      final distance = GeoUtils.haversineDistanceKm(
        latitude1: 23.8103,
        longitude1: 90.4125,
        latitude2: 23.8103,
        longitude2: 90.4125,
      );
      expect(distance, closeTo(0, 0.0001));
    });

    test('computes a known distance between Dhaka and Chittagong', () {
      final distance = GeoUtils.haversineDistanceKm(
        latitude1: 23.8103,
        longitude1: 90.4125,
        latitude2: 22.3569,
        longitude2: 91.7832,
      );
      expect(distance, greaterThan(200));
      expect(distance, lessThan(220));
    });

    test('encodes a stable geohash', () {
      expect(
        GeoUtils.encodeGeohash(23.8103, 90.4125),
        GeoUtils.encodeGeohash(23.8103, 90.4125),
      );
      expect(GeoUtils.encodeGeohash(23.8103, 90.4125).length, 9);
    });
  });
}
