import 'package:flutter_test/flutter_test.dart';
import 'package:navigo/models/shortcut.dart';

void main() {
  group('LocationShortcut', () {
    late LocationShortcut shortcut;

    setUp(() {
      shortcut = LocationShortcut(
        id: 'test-id-123',
        label: 'City Hospital',
        address: '123 Main St, Springfield',
        latitude: 28.6139,
        longitude: 77.2090,
        placeId: 'ChIJtest123',
        iconName: 'hospital',
        sortOrder: 0,
        createdAt: DateTime(2026, 1, 1),
      );
    });

    test('toGoogleMapsUrl returns correct navigation URI', () {
      expect(
        shortcut.toGoogleMapsUrl(),
        'google.navigation:q=28.6139,77.209',
      );
    });

    test('toGoogleMapsWebUrl returns correct fallback URL', () {
      expect(
        shortcut.toGoogleMapsWebUrl(),
        'https://www.google.com/maps/dir/?api=1&destination=28.6139,77.209',
      );
    });

    test('toDeepLinkUri produces valid URI with all fields', () {
      final uri = shortcut.toDeepLinkUri();

      expect(uri.scheme, 'navigo');
      expect(uri.host, 'add');
      expect(uri.queryParameters['label'], 'City Hospital');
      expect(uri.queryParameters['lat'], '28.6139');
      expect(uri.queryParameters['lng'], '77.209');
      expect(uri.queryParameters['placeId'], 'ChIJtest123');
      expect(uri.queryParameters['address'], '123 Main St, Springfield');
      expect(uri.queryParameters['icon'], 'hospital');
    });

    test('fromDeepLink parses URI correctly', () {
      final uri = Uri.parse(
        'navigo://add?label=My+Bank&lat=40.7128&lng=-74.006&placeId=ChIJbank&address=Wall+St&icon=bank',
      );

      final parsed = LocationShortcut.fromDeepLink(uri);

      expect(parsed.label, 'My Bank');
      expect(parsed.latitude, 40.7128);
      expect(parsed.longitude, -74.006);
      expect(parsed.placeId, 'ChIJbank');
      expect(parsed.address, 'Wall St');
      expect(parsed.iconName, 'bank');
    });

    test('fromDeepLink handles missing fields with defaults', () {
      final uri = Uri.parse('navigo://add?label=Test');
      final parsed = LocationShortcut.fromDeepLink(uri);

      expect(parsed.label, 'Test');
      expect(parsed.latitude, 0.0);
      expect(parsed.longitude, 0.0);
      expect(parsed.placeId, '');
      expect(parsed.address, '');
      expect(parsed.iconName, 'place');
    });

    test('fromDeepLink handles completely empty URI', () {
      final uri = Uri.parse('navigo://add');
      final parsed = LocationShortcut.fromDeepLink(uri);

      expect(parsed.label, 'Unknown Place');
      expect(parsed.iconName, 'place');
    });

    test('toJson produces correct map', () {
      final json = shortcut.toJson();

      expect(json['id'], 'test-id-123');
      expect(json['label'], 'City Hospital');
      expect(json['latitude'], 28.6139);
      expect(json['longitude'], 77.2090);
      expect(json['iconName'], 'hospital');
      expect(json['sortOrder'], 0);
    });

    test('copyWith creates a modified copy', () {
      final modified = shortcut.copyWith(label: 'New Name', iconName: 'home');

      expect(modified.label, 'New Name');
      expect(modified.iconName, 'home');
      // Unchanged fields
      expect(modified.id, 'test-id-123');
      expect(modified.latitude, 28.6139);
      expect(modified.address, '123 Main St, Springfield');
    });

    test('toDeepLinkUri truncates long addresses', () {
      final longAddress = 'A' * 300;
      final s = shortcut.copyWith(address: longAddress);
      final uri = s.toDeepLinkUri();

      expect(uri.queryParameters['address']!.length, 200);
    });

    test('roundtrip: toDeepLinkUri -> fromDeepLink preserves data', () {
      final uri = shortcut.toDeepLinkUri();
      final roundtripped = LocationShortcut.fromDeepLink(uri);

      expect(roundtripped.label, shortcut.label);
      expect(roundtripped.latitude, shortcut.latitude);
      expect(roundtripped.longitude, shortcut.longitude);
      expect(roundtripped.placeId, shortcut.placeId);
      expect(roundtripped.iconName, shortcut.iconName);
      expect(roundtripped.address, shortcut.address);
    });
  });
}
