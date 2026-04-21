import 'package:hive_ce/hive.dart';
import 'package:navigo/utils/expiry_utils.dart';

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

  @HiveField(9)
  final DateTime? expiresAt;

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
    this.expiresAt,
  });

  /// Create a shortcut from an incoming deep link URI.
  ///
  /// If an `expiry` param is present (e.g. `expiry=3d`), [expiresAt] is set
  /// to a *fresh* window starting from now — the recipient gets the full
  /// duration, not a truncated slice of the sender's remaining time.
  factory LocationShortcut.fromDeepLink(Uri uri) {
    final now = DateTime.now();
    final expiryOption =
        ExpiryOptionX.fromUrlParam(uri.queryParameters['expiry']);
    return LocationShortcut(
      id: '', // Will be assigned by the provider
      label: uri.queryParameters['label'] ?? 'Unknown Place',
      address: uri.queryParameters['address'] ?? '',
      latitude: double.tryParse(uri.queryParameters['lat'] ?? '') ?? 0.0,
      longitude: double.tryParse(uri.queryParameters['lng'] ?? '') ?? 0.0,
      placeId: uri.queryParameters['placeId'] ?? '',
      iconName: uri.queryParameters['icon'] ?? 'place',
      sortOrder: 0,
      createdAt: now,
      expiresAt: expiryOption?.expiresAt,
    );
  }

  /// Serialize this shortcut into a deep link URI for sharing.
  ///
  /// Expiry is encoded as a duration token (e.g. `expiry=3d`) so recipients
  /// get a fresh window rather than the sender's remaining time.
  Uri toDeepLinkUri() {
    final expiryToken = expiresAt != null
        ? inferExpiryOption(expiresAt, createdAt).toUrlParam
        : null;
    return Uri(
      scheme: 'navigo',
      host: 'add',
      queryParameters: {
        'label': label,
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'placeId': placeId,
        'address': address.length > 200 ? address.substring(0, 200) : address,
        'icon': iconName,
        if (expiryToken != null) 'expiry': expiryToken,
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
    // Use a sentinel so callers can explicitly clear expiresAt to null
    Object? expiresAt = _sentinel,
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
      expiresAt: expiresAt == _sentinel ? this.expiresAt : expiresAt as DateTime?,
    );
  }
}

const Object _sentinel = Object();
