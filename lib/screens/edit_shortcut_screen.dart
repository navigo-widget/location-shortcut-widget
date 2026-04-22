import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigo/providers/shortcuts_provider.dart';
import 'package:navigo/services/sharing_service.dart';
import 'package:navigo/utils/expiry_utils.dart';
import 'package:navigo/widgets/expiry_picker.dart';
import 'package:navigo/widgets/icon_picker.dart' show IconPickerCompact;
import 'package:navigo/widgets/place_search_field.dart';

class EditShortcutScreen extends ConsumerStatefulWidget {
  final String shortcutId;

  const EditShortcutScreen({super.key, required this.shortcutId});

  @override
  ConsumerState<EditShortcutScreen> createState() => _EditShortcutScreenState();
}

class _EditShortcutScreenState extends ConsumerState<EditShortcutScreen> {
  late TextEditingController _labelController;
  late String _selectedIcon;
  late ExpiryOption _selectedExpiry;
  bool _initialized = false;
  // Non-null when the user has picked a new address; null = keep original
  PlaceResult? _newPlace;
  bool _showAddressSearch = false;

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
      _selectedExpiry = inferExpiryOption(shortcut.expiresAt, shortcut.createdAt);
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
            // Address — shows current, with option to change
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Address',
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showAddressSearch = !_showAddressSearch),
                  icon: Icon(
                    _showAddressSearch ? Icons.close : Icons.edit_rounded,
                    size: 18,
                  ),
                  label: Text(_showAddressSearch ? 'Cancel' : 'Change'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Current / newly selected address chip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _newPlace != null
                    ? Colors.green.withAlpha(20)
                    : Colors.grey.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: _newPlace != null
                    ? Border.all(color: Colors.green.withAlpha(80))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    _newPlace != null
                        ? Icons.check_circle_rounded
                        : Icons.place,
                    size: 28,
                    color: _newPlace != null ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _newPlace?.description ?? shortcut.address,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Inline search field — shown only when user taps "Change"
            if (_showAddressSearch) ...[
              const SizedBox(height: 12),
              PlaceSearchField(
                onPlaceSelected: (result) {
                  setState(() {
                    _newPlace = result;
                    _showAddressSearch = false;
                  });
                },
              ),
            ],

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

            const SizedBox(height: 28),

            // Expiry
            Text('Expiry', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ExpiryPicker(
              selected: _selectedExpiry,
              onChanged: (option) => setState(() => _selectedExpiry = option),
            ),

            const SizedBox(height: 40),

            // Save button
            ElevatedButton(
              onPressed: () async {
                final updatedShortcut = shortcut.copyWith(
                  label: _labelController.text.trim(),
                  iconName: _selectedIcon,
                  expiresAt: _selectedExpiry.expiresAt,
                  // Apply new address/coords only if user picked one
                  address: _newPlace?.description,
                  latitude: _newPlace?.latitude,
                  longitude: _newPlace?.longitude,
                  placeId: _newPlace?.placeId,
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
