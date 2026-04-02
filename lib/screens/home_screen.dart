import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:navigo/providers/shortcuts_provider.dart';
import 'package:navigo/services/navigation_service.dart';
import 'package:navigo/services/widget_service.dart';
import 'package:navigo/widgets/shortcut_button.dart';
import 'package:navigo/widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check if we should prompt the user to add the widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWidgetPrompt();
    });
  }

  Future<void> _checkWidgetPrompt() async {
    final box = await Hive.openBox('settings');
    final hasPrompted = box.get('widget_prompt_shown', defaultValue: false) as bool;

    if (hasPrompted || !mounted) return;

    // Check if widget is already on the home screen
    final isPinned = await WidgetService.isWidgetPinned();
    if (isPinned || !mounted) return;

    // Mark as prompted so we don't ask again
    await box.put('widget_prompt_shown', true);

    // Show the prompt
    _showWidgetPromptDialog();
  }

  void _showWidgetPromptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add widget to home screen?'),
        content: const Text(
          'Get one-tap navigation right from your home screen. '
          'The NaviGo widget shows your saved places for instant access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              WidgetService.requestPinWidget();
            },
            icon: const Icon(Icons.widgets_rounded, size: 20),
            label: const Text('Add Widget'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = ref.watch(shortcutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NaviGo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: shortcuts.isEmpty
          ? const EmptyState()
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: shortcuts.length,
                itemBuilder: (context, index) {
                  final shortcut = shortcuts[index];
                  return ShortcutButton(
                    shortcut: shortcut,
                    onEdit: () => context.push('/edit/${shortcut.id}'),
                    onNavigate: () => _navigateToPlace(context, shortcut),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add_location, size: 28),
        label: const Text('Add Place'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _navigateToPlace(BuildContext context, shortcut) async {
    final success = await NavigationService.navigateTo(shortcut);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open Google Maps. Is it installed?',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
  }
}
