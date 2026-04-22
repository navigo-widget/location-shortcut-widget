import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigo/models/shortcut.dart';
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
  bool _isSaving = false;

  // Non-null when the user has picked a new address; null = keep original
  PlaceResult? _newPlace;
  bool _showAddressSearch = false;

  // ~11 m tolerance (same as AddShortcutScreen & ConfirmAddScreen)
  static const _coordEpsilon = 0.0001;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  // ── Duplicate-check dialogs ───────────────────────────────────────────────

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

  /// Returns true → replace existing, null → cancelled.
  Future<bool?> _showReplaceDialog(LocationShortcut existing) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Location already saved'),
        content: Text(
          'You already have "${existing.label}" saved at this location.\n\n'
          'Do you want to replace it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  void _showLabelDuplicateDialog(String label) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name already used'),
        content: Text(
          '"$label" is already the name of another shortcut.\n\n'
          'Please choose a different name.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save(LocationShortcut original) async {
    final label = _labelController.text.trim();
    if (label.isEmpty) return;

    final effectiveLat = _newPlace?.latitude ?? original.latitude;
    final effectiveLng = _newPlace?.longitude ?? original.longitude;

    if (effectiveLat == 0 && effectiveLng == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid location coordinates. Please pick a different address.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
      return;
    }

    // ── Duplicate checks — exclude the shortcut being edited ──────────────
    final others = ref
        .read(shortcutsProvider)
        .where((s) => s.id != widget.shortcutId)
        .toList();

    // 1. Coordinate match?
    final coordMatches = others
        .where((s) =>
            (s.latitude - effectiveLat).abs() < _coordEpsilon &&
            (s.longitude - effectiveLng).abs() < _coordEpsilon)
        .toList();

    if (coordMatches.isNotEmpty) {
      final match = coordMatches.first;

      if (match.label == label) {
        _showExactDuplicateDialog(label);
        return;
      }

      final replace = await _showReplaceDialog(match);
      if (!mounted) return;
      if (replace == null) return;

      if (replace) {
        setState(() => _isSaving = true);
        try {
          // Delete this shortcut and update the matched one in-place
          await ref
              .read(shortcutsProvider.notifier)
              .deleteShortcut(widget.shortcutId);
          await ref.read(shortcutsProvider.notifier).updateShortcut(
                match.copyWith(
                  label: label,
                  address: _newPlace?.description ?? original.address,
                  latitude: effectiveLat,
                  longitude: effectiveLng,
                  placeId: _newPlace?.placeId ?? original.placeId,
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
    }

    // 2. Label-only match?
    if (others.any((s) => s.label == label)) {
      _showLabelDuplicateDialog(label);
      return;
    }

    // ── Proceed with update ───────────────────────────────────────────────
    setState(() => _isSaving = true);
    try {
      await ref.read(shortcutsProvider.notifier).updateShortcut(
            original.copyWith(
              label: label,
              iconName: _selectedIcon,
              expiresAt: _selectedExpiry.expiresAt,
              address: _newPlace?.description,
              latitude: _newPlace?.latitude,
              longitude: _newPlace?.longitude,
              placeId: _newPlace?.placeId,
            ),
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final shortcuts = ref.watch(shortcutsProvider);
    final shortcut =
        shortcuts.where((s) => s.id == widget.shortcutId).firstOrNull;

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
      _selectedExpiry =
          inferExpiryOption(shortcut.expiresAt, shortcut.createdAt);
      _initialized = true;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Place'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 28),
            tooltip: 'Share this shortcut',
            onPressed: () =>
                SharingService.shareShortcutWithFallback(shortcut),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Address ──────────────────────────────────────────────────
            Text('Address', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),

            // Tappable chip — tap to toggle the inline search field
            InkWell(
              onTap: () =>
                  setState(() => _showAddressSearch = !_showAddressSearch),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _newPlace != null
                      ? Colors.green.withAlpha(20)
                      : isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.grey.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: _newPlace != null
                      ? Border.all(color: Colors.green.withAlpha(80))
                      : Border.all(
                          color: isDark
                              ? theme.colorScheme.outlineVariant
                              : Colors.grey.withAlpha(50),
                        ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _newPlace != null
                          ? Icons.check_circle_rounded
                          : Icons.place_rounded,
                      size: 26,
                      color: _newPlace != null
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _newPlace?.description ?? shortcut.address,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      _showAddressSearch
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.edit_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            // Inline search — revealed on chip tap
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

            // ── Label ─────────────────────────────────────────────────────
            Text('Shortcut Name', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              style: const TextStyle(fontSize: 20),
              maxLength: 25,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: const InputDecoration(
                hintText: 'e.g. City Hospital',
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 28),

            // ── Icon ──────────────────────────────────────────────────────
            Text('Icon', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            IconPickerCompact(
              selectedIconName: _selectedIcon,
              onIconSelected: (iconName) =>
                  setState(() => _selectedIcon = iconName),
            ),

            const SizedBox(height: 28),

            // ── Expiry ────────────────────────────────────────────────────
            Text('Expiry', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ExpiryPicker(
              selected: _selectedExpiry,
              onChanged: (option) =>
                  setState(() => _selectedExpiry = option),
            ),

            const SizedBox(height: 40),

            // ── Save ──────────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _isSaving ? null : () => _save(shortcut),
              child: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Save Changes'),
            ),

            const SizedBox(height: 16),

            // ── Delete ────────────────────────────────────────────────────
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
      builder: (ctx) => AlertDialog(
        title: Text('Delete "$label"?'),
        content: const Text(
          'You will lose this shortcut. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
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
