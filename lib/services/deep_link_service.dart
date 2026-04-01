import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/utils/constants.dart';

/// Listens for incoming deep links and converts them to LocationShortcut objects.
class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// Initialize deep link handling for both cold start and warm start.
  void init({required void Function(LocationShortcut shortcut) onShortcutReceived}) {
    // Handle cold start: app opened via a deep link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(uri, onShortcutReceived);
      }
    });

    // Handle warm start: deep link received while app is running
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri, onShortcutReceived);
    });
  }

  void _handleUri(
    Uri uri,
    void Function(LocationShortcut shortcut) onShortcutReceived,
  ) {
    if (uri.scheme == kDeepLinkScheme && uri.host == kDeepLinkHost) {
      final shortcut = LocationShortcut.fromDeepLink(uri);
      onShortcutReceived(shortcut);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
