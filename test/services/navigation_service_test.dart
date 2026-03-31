import 'package:flutter_test/flutter_test.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';

void main() {
  group('Navigation URL building', () {
    late LocationShortcut shortcut;

    setUp(() {
      shortcut = LocationShortcut(
        id: 'nav-test',
        label: 'Test Place',
        address: '456 Oak Ave',
        latitude: 37.7749,
        longitude: -122.4194,
        placeId: 'ChIJnav',
        iconName: 'place',
        sortOrder: 0,
        createdAt: DateTime.now(),
      );
    });

    test('navigation URL uses google.navigation scheme', () {
      final url = shortcut.toGoogleMapsUrl();
      expect(url, startsWith('google.navigation:'));
      expect(url, contains('37.7749'));
      expect(url, contains('-122.4194'));
    });

    test('web fallback URL uses google.com/maps', () {
      final url = shortcut.toGoogleMapsWebUrl();
      expect(url, startsWith('https://www.google.com/maps/dir/'));
      expect(url, contains('destination=37.7749,-122.4194'));
    });
  });
}
