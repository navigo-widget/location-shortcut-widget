import 'package:url_launcher/url_launcher.dart';
import 'package:navigo/models/shortcut.dart';

/// Opens Google Maps navigation for a given shortcut.
class NavigationService {
  /// Launch Google Maps turn-by-turn navigation to the shortcut's location.
  static Future<bool> navigateTo(LocationShortcut shortcut) async {
    // Try the Android Google Maps navigation intent first
    final navigationUri = Uri.parse(shortcut.toGoogleMapsUrl());
    if (await canLaunchUrl(navigationUri)) {
      return launchUrl(navigationUri, mode: LaunchMode.externalApplication);
    }

    // Fallback to Google Maps web URL
    final webUri = Uri.parse(shortcut.toGoogleMapsWebUrl());
    return launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}
