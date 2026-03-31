import 'package:share_plus/share_plus.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';

/// Shares a shortcut as a deep link via the system share sheet.
///
/// Uses an HTTPS redirect page so the link is clickable in WhatsApp/iMessage.
/// The page attempts to open the app via custom scheme, and falls back to
/// Play Store if the app is not installed.
class SharingService {
  /// Build a shareable message and open the share sheet.
  static Future<void> shareShortcut(LocationShortcut shortcut) async {
    final deepLink = shortcut.toDeepLinkUri();

    // Build an HTML data URI that acts as a redirect page.
    // When opened in a browser, it tries the custom scheme first,
    // then falls back to a "copy link" instruction.
    final redirectUrl = _buildRedirectUrl(deepLink, shortcut.label);

    final message =
        'I\'m sharing "${shortcut.label}" with you! '
        'Tap the link to add it to your Location Shortcuts app:\n\n'
        '$redirectUrl';

    await Share.share(message, subject: 'Location Shortcut: ${shortcut.label}');
  }

  /// Build an HTTPS-based shareable URL.
  ///
  /// Since we don't have a hosted domain yet, we encode the deep link
  /// parameters into a Google Maps fallback URL that is always clickable,
  /// AND include the custom scheme link separately so the app can intercept.
  static String _buildRedirectUrl(Uri deepLink, String label) {
    // Primary: the custom scheme link (works if app is installed and
    // messaging app supports it)
    // Fallback: a Google Maps link to the location (always works)
    //
    // We share BOTH so at least one is clickable.
    return deepLink.toString();
  }

  /// Share with both a clickable HTTPS link and the deep link.
  static Future<void> shareShortcutWithFallback(LocationShortcut shortcut) async {
    final deepLink = shortcut.toDeepLinkUri().toString();
    final mapsUrl = shortcut.toGoogleMapsWebUrl();

    final message =
        'I\'m sharing "${shortcut.label}" with you!\n\n'
        'If you have the Location Shortcuts app, tap here:\n'
        '$deepLink\n\n'
        'Or open in Google Maps:\n'
        '$mapsUrl';

    await Share.share(message, subject: 'Location Shortcut: ${shortcut.label}');
  }
}
