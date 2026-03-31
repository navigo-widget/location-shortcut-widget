import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';
import 'package:location_shortcut_widget/providers/shortcuts_provider.dart';
import 'package:location_shortcut_widget/widgets/icon_picker.dart';
import 'package:location_shortcut_widget/widgets/place_search_field.dart';

class AddShortcutScreen extends ConsumerStatefulWidget {
  const AddShortcutScreen({super.key});

  @override
  ConsumerState<AddShortcutScreen> createState() => _AddShortcutScreenState();
}

class _AddShortcutScreenState extends ConsumerState<AddShortcutScreen> {
  final _labelController = TextEditingController();
  PlaceResult? _selectedPlace;
  String _selectedIcon = 'place';
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
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 28),

            // Step 3: Choose an icon
            Text(
              'Step 3: Choose an icon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            IconPicker(
              selectedIconName: _selectedIcon,
              onIconSelected: (iconName) {
                setState(() => _selectedIcon = iconName);
              },
            ),

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
