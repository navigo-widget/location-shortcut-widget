import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigo/providers/shortcuts_provider.dart';
import 'package:navigo/services/sharing_service.dart';
import 'package:navigo/widgets/icon_picker.dart' show IconPickerCompact;

class EditShortcutScreen extends ConsumerStatefulWidget {
  final String shortcutId;

  const EditShortcutScreen({super.key, required this.shortcutId});

  @override
  ConsumerState<EditShortcutScreen> createState() => _EditShortcutScreenState();
}

class _EditShortcutScreenState extends ConsumerState<EditShortcutScreen> {
  late TextEditingController _labelController;
  late String _selectedIcon;
  bool _initialized = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = ref.watch(shortcutsProvider);
    final shortcut = shortcuts.where((s) => s.id == widget.shortcutId).firstOrNull;

    if (shortcut == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Place')),
        body: const Center(
          child: Text('Shortcut not found', style: TextStyle(fontSize: 20)),
        ),
      );
    }

    if (!_initialized) {
      _labelController = TextEditingController(text: shortcut.label);
      _selectedIcon = shortcut.iconName;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Place'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 28),
            tooltip: 'Share this shortcut',
            onPressed: () => SharingService.shareShortcutWithFallback(shortcut),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Address (read-only)
            Text(
              'Address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, size: 28, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      shortcut.address,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Label
            Text(
              'Shortcut Name',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                hintText: 'e.g. City Hospital',
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 28),

            // Icon
            Text(
              'Icon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            IconPickerCompact(
              selectedIconName: _selectedIcon,
              onIconSelected: (iconName) {
                setState(() => _selectedIcon = iconName);
              },
            ),

            const SizedBox(height: 40),

            // Save button
            ElevatedButton(
              onPressed: () async {
                final updatedShortcut = shortcut.copyWith(
                  label: _labelController.text.trim(),
                  iconName: _selectedIcon,
                );
                await ref
                    .read(shortcutsProvider.notifier)
                    .updateShortcut(updatedShortcut);
                if (context.mounted) context.pop();
              },
              child: const Text('Save Changes'),
            ),

            const SizedBox(height: 16),

            // Delete button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
              ),
              onPressed: () => _confirmDelete(context, shortcut.label),
              child: const Text('Delete Shortcut'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "$label"?'),
        content: const Text(
          'You will lose this shortcut. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(shortcutsProvider.notifier)
          .deleteShortcut(widget.shortcutId);
      if (context.mounted) context.pop();
    }
  }
}
