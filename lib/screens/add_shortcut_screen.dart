import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/providers/shortcuts_provider.dart';
import 'package:navigo/services/location_service.dart';
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
  bool _isLocating = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not get your location. Please check location permissions.',
              ),
            ),
          );
        }
        return;
      }

      final address = await LocationService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      final label = address.split(',').first.trim();
      setState(() {
        _selectedPlace = PlaceResult(
          description: address,
          placeId: '',
          latitude: position.latitude,
          longitude: position.longitude,
        );
        if (_labelController.text.isEmpty) {
          _labelController.text = label;
        }
        if (!_iconManuallyChanged) {
          _selectedIcon = autoDetectIcon(
            _labelController.text.isNotEmpty ? _labelController.text : label,
          );
        }
      });
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ~11 m tolerance for floating-point coordinate comparison (same as ConfirmAddScreen)
  static const _coordEpsilon = 0.0001;

  // ── Duplicate-check dialogs ──────────────────────────────────────────

  /// Shown when coords AND label both match an existing shortcut.
  void _showExactDuplicateDialog(String label) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Already saved'),
        content: Text('"$label" is already in your shortcuts.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shown when coords match but label differs.
  /// Returns true  → replace existing
  ///         false → save as a new shortcut anyway
  ///         null  → cancelled
  Future<bool?> _showReplaceDialog(LocationShortcut existing) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Location already saved'),
        content: Text(
          'You already have "${existing.label}" saved at this location.\n\n'
          'Do you want to replace it with this one?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),        // null → cancel
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false), // save as new
            child: const Text('Save Anyway'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),  // replace
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  /// Shown when label matches but coords differ.
  /// Returns true → proceed with save, false / null → cancel.
  Future<bool> _showLabelDuplicateDialog(String label) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name already used'),
        content: Text(
          '"$label" already exists in your shortcuts.\n\n'
          'Save this new place with the same name?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save Anyway'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Save ─────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_selectedPlace == null) return;
    final label = _labelController.text.trim();
    if (label.isEmpty) return;
    if (_selectedPlace!.latitude == 0 && _selectedPlace!.longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid location coordinates. Please search and select a place again.',
          ),
        ),
      );
      return;
    }

    // ── Duplicate checks (mirrors ConfirmAddScreen._runDuplicateCheck) ──
    final existing = ref.read(shortcutsProvider);

    // 1. Coordinate match?
    final coordMatches = existing
        .where((s) =>
            (s.latitude - _selectedPlace!.latitude).abs() < _coordEpsilon &&
            (s.longitude - _selectedPlace!.longitude).abs() < _coordEpsilon)
        .toList();

    if (coordMatches.isNotEmpty) {
      final match = coordMatches.first;

      if (match.label == label) {
        // Exact duplicate — block entirely
        _showExactDuplicateDialog(label);
        return;
      }

      // Same location, different name — offer to replace
      final replace = await _showReplaceDialog(match);
      if (!mounted) return;

      if (replace == null) return; // user cancelled

      if (replace) {
        // Replace the existing shortcut in-place
        setState(() => _isSaving = true);
        try {
          await ref.read(shortcutsProvider.notifier).updateShortcut(
                match.copyWith(
                  label: label,
                  address: _selectedPlace!.description,
                  latitude: _selectedPlace!.latitude,
                  longitude: _selectedPlace!.longitude,
                  placeId: _selectedPlace!.placeId,
                  iconName: _selectedIcon,
                  expiresAt: _selectedExpiry.expiresAt,
                ),
              );
          if (mounted) context.pop();
        } finally {
          if (mounted) setState(() => _isSaving = false);
        }
        return;
      }
      // replace == false → fall through and save as a new shortcut
    }

    // 2. Label-only match?
    if (existing.any((s) => s.label == label)) {
      final proceed = await _showLabelDuplicateDialog(label);
      if (!mounted) return;
      if (!proceed) return;
    }

    // ── Proceed with save ────────────────────────────────────────────
    setState(() => _isSaving = true);
    try {
      await ref.read(shortcutsProvider.notifier).addShortcut(
            LocationShortcut(
              id: '', // assigned by the provider
              label: label,
              address: _selectedPlace!.description,
              latitude: _selectedPlace!.latitude,
              longitude: _selectedPlace!.longitude,
              placeId: _selectedPlace!.placeId,
              iconName: _selectedIcon,
              sortOrder: 0,
              createdAt: DateTime.now(),
              expiresAt: _selectedExpiry.expiresAt,
            ),
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

            const SizedBox(height: 12),

            // "Use My Current Location" alternative
            OutlinedButton.icon(
              onPressed: _isLocating ? null : _useCurrentLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                _isLocating ? 'Getting your location…' : 'Use My Current Location',
              ),
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
