import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/utils/constants.dart';

/// Listens for incoming deep links via a native EventChannel and converts
/// them to [LocationShortcut] objects.
///
/// This replaces the app_links plugin with a direct platform channel for
/// maximum reliability on Android.
class DeepLinkService {
  static const _channel = EventChannel('com.navigo.app/deeplink');
  StreamSubscription<dynamic>? _subscription;

  /// Start listening for deep link URIs from the native side.
  void init({required void Function(LocationShortcut shortcut) onShortcutReceived}) {
    _subscription = _channel.receiveBroadcastStream().listen((dynamic uriString) {
      debugPrint('[DeepLink] received: $uriString');
      if (uriString is! String) return;

      final uri = Uri.tryParse(uriString);
      if (uri == null) return;

      debugPrint('[DeepLink] parsed: scheme=${uri.scheme}, host=${uri.host}, params=${uri.queryParameters}');

      if (uri.scheme == kDeepLinkScheme && uri.host == kDeepLinkHost) {
        final shortcut = LocationShortcut.fromDeepLink(uri);
        onShortcutReceived(shortcut);
        return;
      }

      // Fallback: accept any URI with the expected query params
      if (uri.queryParameters.containsKey('label') &&
          uri.queryParameters.containsKey('lat') &&
          uri.queryParameters.containsKey('lng')) {
        debugPrint('[DeepLink] using fallback param extraction');
        final shortcut = LocationShortcut.fromDeepLink(uri);
        onShortcutReceived(shortcut);
      }
    }, onError: (dynamic error) {
      debugPrint('[DeepLink] error: $error');
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
