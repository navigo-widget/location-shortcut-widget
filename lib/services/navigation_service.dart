import 'package:url_launcher/url_launcher.dart';
import 'package:navigo/models/shortcut.dart';

/// Opens Google Maps navigation for a given shortcut.
class NavigationService {
  /// Launch navigation to the shortcut's location.
  ///
  /// Resolution order:
  ///   1. Google Maps navigation intent (fastest, turn-by-turn)
  ///   2. geo: URI — the OS routes this to any installed maps app (Waze, OsmAnd…)
  ///   3. Google Maps web URL as a last resort
  static Future<bool> navigateTo(LocationShortcut shortcut) async {
    // 1. Google Maps native intent
    final googleUri = Uri.parse(shortcut.toGoogleMapsUrl());
    if (await canLaunchUrl(googleUri)) {
      return launchUrl(googleUri, mode: LaunchMode.externalApplication);
    }

    // 2. Standard geo: URI — works with any maps app
    final label = Uri.encodeComponent(shortcut.label);
    final geoUri = Uri.parse(
      'geo:${shortcut.latitude},${shortcut.longitude}'
      '?q=${shortcut.latitude},${shortcut.longitude}($label)',
    );
    if (await canLaunchUrl(geoUri)) {
      return launchUrl(geoUri, mode: LaunchMode.externalApplication);
    }

    // 3. Google Maps web URL
    final webUri = Uri.parse(shortcut.toGoogleMapsWebUrl());
    return launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}
