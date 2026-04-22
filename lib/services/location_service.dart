import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Handles GPS access and reverse-geocoding via Nominatim.
class LocationService {
  /// Requests permission if needed and returns the current GPS position.
  /// Returns null if permission is denied or location services are off.
  static Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Reverse-geocodes [lat]/[lng] to a short human-readable address
  /// using the OpenStreetMap Nominatim API (free, no key required).
  static Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lng&format=json&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'NaviGo/1.0 (flutter; contact@navigo.app)',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Build a short "Road, City" style label
          final parts = <String>[];
          for (final key in [
            'road',
            'suburb',
            'city',
            'town',
            'village',
            'county',
          ]) {
            final val = address[key] as String?;
            if (val != null && val.isNotEmpty) {
              parts.add(val);
              if (parts.length == 2) break;
            }
          }
          if (parts.isNotEmpty) return parts.join(', ');
        }

        // Fallback: first two components of display_name
        final display = data['display_name'] as String? ?? '';
        return display.split(',').take(2).join(',').trim();
      }
    } catch (_) {}

    return '$lat, $lng';
  }
}
