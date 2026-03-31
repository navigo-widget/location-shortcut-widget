import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';
import 'package:location_shortcut_widget/providers/shortcuts_provider.dart';
import 'package:location_shortcut_widget/utils/shortcut_icons.dart';

/// Shown when the app receives a deep link to add a shared shortcut.
/// Acts as a confirmation gate so links can't silently add shortcuts.
class ConfirmAddScreen extends ConsumerWidget {
  final LocationShortcut shortcut;

  const ConfirmAddScreen({super.key, required this.shortcut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconData = getShortcutIcon(shortcut.iconName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shared Place'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Header
            Text(
              'Someone shared a place with you!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Shortcut preview card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: iconData.color.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData.icon,
                        size: 44,
                        color: iconData.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      shortcut.label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shortcut.address,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Add button
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(shortcutsProvider.notifier)
                    .addShortcut(shortcut);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '"${shortcut.label}" added to your shortcuts!',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                  context.go('/');
                }
              },
              child: const Text('Add to My Shortcuts'),
            ),

            const SizedBox(height: 12),

            // Cancel button
            OutlinedButton(
              onPressed: () => context.go('/'),
              child: const Text('Cancel'),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
