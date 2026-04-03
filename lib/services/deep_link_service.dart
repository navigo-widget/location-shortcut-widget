import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
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
        debugPrint('[DeepLink] initial link: $uri');
        _handleUri(uri, onShortcutReceived);
      }
    });

    // Handle warm start: deep link received while app is running
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('[DeepLink] stream link: $uri');
      _handleUri(uri, onShortcutReceived);
    });
  }

  void _handleUri(
    Uri uri,
    void Function(LocationShortcut shortcut) onShortcutReceived,
  ) {
    debugPrint('[DeepLink] handling: scheme=${uri.scheme}, host=${uri.host}, params=${uri.queryParameters}');

    // Accept both navigo://add?... and any URI with the expected query params
    if (uri.scheme == kDeepLinkScheme && uri.host == kDeepLinkHost) {
      final shortcut = LocationShortcut.fromDeepLink(uri);
      onShortcutReceived(shortcut);
      return;
    }

    // Fallback: some Android versions deliver the intent with scheme=intent
    // or mangle the URI. If we have the query params, use them.
    if (uri.queryParameters.containsKey('label') &&
        uri.queryParameters.containsKey('lat') &&
        uri.queryParameters.containsKey('lng')) {
      debugPrint('[DeepLink] using fallback param extraction');
      final shortcut = LocationShortcut.fromDeepLink(uri);
      onShortcutReceived(shortcut);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
