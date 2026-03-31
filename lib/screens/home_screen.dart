import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:location_shortcut_widget/providers/shortcuts_provider.dart';
import 'package:location_shortcut_widget/services/navigation_service.dart';
import 'package:location_shortcut_widget/widgets/shortcut_button.dart';
import 'package:location_shortcut_widget/widgets/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcuts = ref.watch(shortcutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Places'),
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
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: shortcuts.length,
                itemBuilder: (context, index) {
                  final shortcut = shortcuts[index];
                  return ShortcutButton(
                    shortcut: shortcut,
                    onTap: () => _navigateToPlace(context, shortcut),
                    onLongPress: () => context.push('/edit/${shortcut.id}'),
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
