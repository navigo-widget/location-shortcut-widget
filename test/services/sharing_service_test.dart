import 'package:flutter_test/flutter_test.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/services/sharing_service.dart';

void main() {
  group('Sharing deep link construction', () {
    test('deep link contains all required parameters', () {
      final shortcut = LocationShortcut(
        id: 'share-test',
        label: 'My Home',
        address: '789 Pine Rd',
        latitude: 12.9716,
        longitude: 77.5946,
        placeId: 'ChIJshare',
        iconName: 'home',
        sortOrder: 0,
        createdAt: DateTime.now(),
      );

      final uri = shortcut.toDeepLinkUri();

      expect(uri.toString(), contains('navigo://add'));
      expect(uri.queryParameters['label'], 'My Home');
      expect(uri.queryParameters['lat'], '12.9716');
      expect(uri.queryParameters['lng'], '77.5946');
      expect(uri.queryParameters['icon'], 'home');
      expect(uri.queryParameters['placeId'], 'ChIJshare');
    });

    test('deep link encodes special characters in label', () {
      final shortcut = LocationShortcut(
        id: 'special-test',
        label: 'Dr. Smith\'s Clinic & Lab',
        address: '100 Test St',
        latitude: 10.0,
        longitude: 20.0,
        placeId: 'ChIJspecial',
        iconName: 'hospital',
        sortOrder: 0,
        createdAt: DateTime.now(),
      );

      final uri = shortcut.toDeepLinkUri();
      // The URI should be parseable back
      final parsed = LocationShortcut.fromDeepLink(uri);
      expect(parsed.label, 'Dr. Smith\'s Clinic & Lab');
    });

    test('share URL uses HTTPS and contains all parameters', () {
      final shortcut = LocationShortcut(
        id: 'share-url-test',
        label: 'City Hospital',
        address: '100 Medical Rd',
        latitude: 28.6139,
        longitude: 77.2090,
        placeId: 'ChIJhospital',
        iconName: 'hospital',
        sortOrder: 0,
        createdAt: DateTime.now(),
      );

      final url = SharingService.buildShareUrl(shortcut);

      expect(url, startsWith('https://navigo-widget.github.io'));
      expect(url, contains('label=City+Hospital'));
      expect(url, contains('lat=28.6139'));
      expect(url, contains('lng=77.209'));
      expect(url, contains('icon=hospital'));
    });

    test('share URL encodes special characters', () {
      final shortcut = LocationShortcut(
        id: 'encode-test',
        label: 'Dr. Smith\'s Clinic & Lab',
        address: '100 Test St',
        latitude: 10.0,
        longitude: 20.0,
        placeId: 'ChIJspecial',
        iconName: 'doctor',
        sortOrder: 0,
        createdAt: DateTime.now(),
      );

      final url = SharingService.buildShareUrl(shortcut);
      final uri = Uri.parse(url);

      expect(uri.scheme, 'https');
      expect(uri.queryParameters['label'], 'Dr. Smith\'s Clinic & Lab');
    });
  });
}
