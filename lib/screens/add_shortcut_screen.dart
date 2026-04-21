import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/providers/shortcuts_provider.dart';
import 'package:navigo/utils/expiry_utils.dart';
import 'package:navigo/utils/shortcut_icons.dart';
import 'package:navigo/widgets/expiry_picker.dart';
import 'package:navigo/widgets/icon_picker.dart' show IconPickerCompact;
import 'package:navigo/widgets/place_search_field.dart';

class AddShortcutScreen extends ConsumerStatefulWidget {
  const AddShortcutScreen({super.key});

  @override
  ConsumerState<AddShortcutScreen> createState() => _AddShortcutScreenState();
}

class _AddShortcutScreenState extends ConsumerState<AddShortcutScreen> {
  final _labelController = TextEditingController();
  PlaceResult? _selectedPlace;
  String _selectedIcon = 'place';
  ExpiryOption _selectedExpiry = ExpiryOption.never;
  bool _iconManuallyChanged = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedPlace == null) return;
    if (_labelController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    final shortcut = LocationShortcut(
      id: '', // Will be assigned by the provider
      label: _labelController.text.trim(),
      address: _selectedPlace!.description,
      latitude: _selectedPlace!.latitude,
      longitude: _selectedPlace!.longitude,
      placeId: _selectedPlace!.placeId,
      iconName: _selectedIcon,
      sortOrder: 0,
      createdAt: DateTime.now(),
      expiresAt: _selectedExpiry.expiresAt,
    );

    await ref.read(shortcutsProvider.notifier).addShortcut(shortcut);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave =
        _selectedPlace != null && _labelController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1: Search for a place
            Text(
              'Step 1: Find the place',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            PlaceSearchField(
              onPlaceSelected: (result) {
                setState(() {
                  _selectedPlace = result;
                  if (_labelController.text.isEmpty) {
                    // Auto-fill label with the first part of the address
                    _labelController.text =
                        result.description.split(',').first.trim();
                  }
                  // Auto-detect icon from label
                  _selectedIcon = autoDetectIcon(
                    _labelController.text.isNotEmpty
                        ? _labelController.text
                        : result.description.split(',').first.trim(),
                  );
                });
              },
            ),

            if (_selectedPlace != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withAlpha(75)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedPlace!.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Step 2: Give it a name
            Text(
              'Step 2: Give it a name',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labelController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                hintText: 'e.g. City Hospital',
                labelText: 'Shortcut Name',
              ),
              onChanged: (value) {
                setState(() {
                  // Re-detect icon from label if user hasn't manually picked one
                  if (!_iconManuallyChanged && value.trim().isNotEmpty) {
                    _selectedIcon = autoDetectIcon(value);
                  }
                });
              },
              textCapitalization: TextCapitalization.words,
            ),

            if (_selectedPlace != null) ...[
              const SizedBox(height: 28),

              // Step 3: Icon (auto-detected)
              Text(
                'Step 3: Icon',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              IconPickerCompact(
                selectedIconName: _selectedIcon,
                onIconSelected: (iconName) {
                  setState(() {
                    _selectedIcon = iconName;
                    _iconManuallyChanged = true;
                  });
                },
              ),

              const SizedBox(height: 28),

              // Step 4: Expiry
              Text(
                'Step 4: Expiry',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ExpiryPicker(
                selected: _selectedExpiry,
                onChanged: (option) => setState(() => _selectedExpiry = option),
              ),
            ],

            const SizedBox(height: 40),

            // Save button
            ElevatedButton(
              onPressed: canSave && !_isSaving ? _save : null,
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Save Shortcut'),
            ),
          ],
        ),
      ),
    );
  }
}
