import 'package:flutter_test/flutter_test.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';

void main() {
  group('Deep link URI parsing', () {
    test('valid deep link is parsed into a LocationShortcut', () {
      final uri = Uri.parse(
        'locationshortcut://add?label=Hospital&lat=28.5&lng=77.1&placeId=abc&address=Test+Addr&icon=hospital',
      );

      final shortcut = LocationShortcut.fromDeepLink(uri);

      expect(shortcut.label, 'Hospital');
      expect(shortcut.latitude, 28.5);
      expect(shortcut.longitude, 77.1);
      expect(shortcut.placeId, 'abc');
      expect(shortcut.address, 'Test Addr');
      expect(shortcut.iconName, 'hospital');
    });

    test('invalid lat/lng default to 0.0', () {
      final uri = Uri.parse(
        'locationshortcut://add?label=Bad&lat=notanumber&lng=alsonotanumber',
      );

      final shortcut = LocationShortcut.fromDeepLink(uri);

      expect(shortcut.latitude, 0.0);
      expect(shortcut.longitude, 0.0);
    });

    test('missing label defaults to Unknown Place', () {
      final uri = Uri.parse('locationshortcut://add?lat=10&lng=20');

      final shortcut = LocationShortcut.fromDeepLink(uri);

      expect(shortcut.label, 'Unknown Place');
    });
  });
}
