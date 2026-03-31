import 'package:share_plus/share_plus.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';

/// Shares a shortcut as a deep link via the system share sheet.
class SharingService {
  /// Build a shareable message and open the share sheet.
  static Future<void> shareShortcut(LocationShortcut shortcut) async {
    final deepLink = shortcut.toDeepLinkUri().toString();
    final message =
        'Tap to add "${shortcut.label}" to your Location Shortcuts app:\n$deepLink';

    await Share.share(message, subject: 'Share Location Shortcut');
  }
}
