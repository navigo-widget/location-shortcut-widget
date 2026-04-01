import 'package:flutter_test/flutter_test.dart';
import 'package:navigo/models/shortcut.dart';

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
  });
}
