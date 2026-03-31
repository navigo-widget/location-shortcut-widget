import 'package:hive_ce/hive.dart';

part 'shortcut.g.dart';

@HiveType(typeId: 0)
class LocationShortcut extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  String address;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final String placeId;

  @HiveField(6)
  String iconName;

  @HiveField(7)
  int sortOrder;

  @HiveField(8)
  final DateTime createdAt;

  LocationShortcut({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    required this.iconName,
    required this.sortOrder,
    required this.createdAt,
  });

  /// Create a shortcut from an incoming deep link URI.
  factory LocationShortcut.fromDeepLink(Uri uri) {
    return LocationShortcut(
      id: '', // Will be assigned by the provider
      label: uri.queryParameters['label'] ?? 'Unknown Place',
      address: uri.queryParameters['address'] ?? '',
      latitude: double.tryParse(uri.queryParameters['lat'] ?? '') ?? 0.0,
      longitude: double.tryParse(uri.queryParameters['lng'] ?? '') ?? 0.0,
      placeId: uri.queryParameters['placeId'] ?? '',
      iconName: uri.queryParameters['icon'] ?? 'place',
      sortOrder: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Serialize this shortcut into a deep link URI for sharing.
  Uri toDeepLinkUri() {
    return Uri(
      scheme: 'locationshortcut',
      host: 'add',
      queryParameters: {
        'label': label,
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'placeId': placeId,
        'address': address.length > 200 ? address.substring(0, 200) : address,
        'icon': iconName,
      },
    );
  }

  /// Build a Google Maps navigation URL for this shortcut.
  String toGoogleMapsUrl() {
    return 'google.navigation:q=$latitude,$longitude';
  }

  /// Fallback URL if the navigation intent fails.
  String toGoogleMapsWebUrl() {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }

  /// Convert to a JSON map for the Android home screen widget.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
      'iconName': iconName,
      'sortOrder': sortOrder,
    };
  }

  LocationShortcut copyWith({
    String? id,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
    String? iconName,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return LocationShortcut(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
