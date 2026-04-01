import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/providers/theme_provider.dart';
import 'package:navigo/screens/home_screen.dart';
import 'package:navigo/screens/add_shortcut_screen.dart';
import 'package:navigo/screens/edit_shortcut_screen.dart';
import 'package:navigo/screens/confirm_add_screen.dart';
import 'package:navigo/screens/settings_screen.dart';
import 'package:navigo/services/deep_link_service.dart';
import 'package:navigo/theme/app_theme.dart';

/// Root GoRouter configuration.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddShortcutScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditShortcutScreen(shortcutId: id);
        },
      ),
      GoRoute(
        path: '/confirm-add',
        builder: (context, state) {
          final shortcut = state.extra as LocationShortcut;
          return ConfirmAddScreen(shortcut: shortcut);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    _deepLinkService = DeepLinkService();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final router = ref.read(routerProvider);

    _deepLinkService.init(
      onShortcutReceived: (shortcut) {
        router.push('/confirm-add', extra: shortcut);
      },
    );
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'NaviGo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
