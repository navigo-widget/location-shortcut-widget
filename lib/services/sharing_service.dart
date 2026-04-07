import 'package:share_plus/share_plus.dart';
import 'package:navigo/models/shortcut.dart';

/// Shares a shortcut via a clickable HTTPS link.
///
/// The link points to a GitHub Pages redirect page that:
/// 1. Tries to open the NaviGo app via custom scheme
/// 2. Shows a "Open in Google Maps" fallback button
class SharingService {
  static const _baseUrl = 'https://navigo-widget.github.io';

  /// Build a shareable HTTPS URL for the redirect page.
  static String buildShareUrl(LocationShortcut shortcut) {
    final params = {
      'label': shortcut.label,
      'lat': shortcut.latitude.toString(),
      'lng': shortcut.longitude.toString(),
      'icon': shortcut.iconName,
    };
    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    return uri.toString();
  }

  /// Share a shortcut with a friendly message and a single clean link.
  static Future<void> shareShortcutWithFallback(LocationShortcut shortcut) async {
    final shareUrl = buildShareUrl(shortcut);

    final message =
        'Here\'s a location shared via NaviGo!\n'
        '\n'
        'Location: ${shortcut.label}\n'
        '\n'
        'Tap the link to add it to your NaviGo app for one-tap navigation. '
        'If you don\'t have NaviGo yet, the link will let you download it for free.\n'
        '\n'
        '$shareUrl';

    await Share.share(message, subject: 'NaviGo: ${shortcut.label}');
  }
}
