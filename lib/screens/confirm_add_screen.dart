import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/providers/shortcuts_provider.dart';
import 'package:navigo/utils/shortcut_icons.dart';

/// Shown when the app receives a deep link to add a shared shortcut.
/// Acts as a confirmation gate so links can't silently add shortcuts.
///
/// Duplicate handling (coordinates checked first):
///   coords + label match  → block: "Already exists as '[Label]'"
///   coords match only     → offer to replace the existing shortcut
///   label match only      → auto-suffix label, keep user on screen to edit
///   no match              → normal add
class ConfirmAddScreen extends ConsumerStatefulWidget {
  final LocationShortcut shortcut;

  const ConfirmAddScreen({super.key, required this.shortcut});

  @override
  ConsumerState<ConfirmAddScreen> createState() => _ConfirmAddScreenState();
}

class _ConfirmAddScreenState extends ConsumerState<ConfirmAddScreen> {
  late final TextEditingController _labelController;
  String? _labelHint;

  // ~11 m tolerance for floating-point coordinate comparison
  static const _coordEpsilon = 0.0001;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.shortcut.label);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runDuplicateCheck());
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  bool _sameCoords(LocationShortcut s) =>
      (s.latitude - widget.shortcut.latitude).abs() < _coordEpsilon &&
      (s.longitude - widget.shortcut.longitude).abs() < _coordEpsilon;

  void _runDuplicateCheck() {
    final existing = ref.read(shortcutsProvider);

    // ── 1. Coordinates match ────────────────────────────────────────
    final coordMatches = existing.where(_sameCoords).toList();
    if (coordMatches.isNotEmpty) {
      final match = coordMatches.first;
      if (match.label == widget.shortcut.label) {
        // Exact duplicate (coords + label) — block entirely
        _showExactDuplicateDialog(match.label);
      } else {
        // Same location, different name — offer to replace
        _showReplaceDialog(match);
      }
      return;
    }

    // ── 2. Label match only ─────────────────────────────────────────
    final baseLabel = widget.shortcut.label;
    if (existing.any((s) => s.label == baseLabel)) {
      int suffix = 2;
      while (existing.any((s) => s.label == '$baseLabel $suffix')) {
        suffix++;
      }
      setState(() {
        _labelController.text = '$baseLabel $suffix';
        _labelHint =
            '"$baseLabel" already exists — feel free to change the label below.';
      });
    }
  }

  // ── Dialogs ─────────────────────────────────────────────────────────

  void _showExactDuplicateDialog(String label) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Already saved'),
        content: Text('"$label" is already in your shortcuts.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showReplaceDialog(LocationShortcut existing) {
    // Capture screen context before entering the dialog builder,
    // so we don't accidentally use the dialog's local context after awaits.
    final screenContext = context;
    showDialog(
      context: screenContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Location already saved'),
        content: Text(
          'You already have "${existing.label}" saved at this location.\n\n'
          'Do you want to replace it with this one?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              screenContext.go('/');
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final updated = widget.shortcut.copyWith(
                id: existing.id,
                sortOrder: existing.sortOrder,
              );
              await ref
                  .read(shortcutsProvider.notifier)
                  .updateShortcut(updated);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '"${existing.label}" replaced with "${widget.shortcut.label}".',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
              context.go('/');
            },
            child: const Text('Replace'),
          ),
        ],
      ),
    );
  }

  // ── Add action ───────────────────────────────────────────────────────

  Future<void> _addShortcut() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) return;

    await ref
        .read(shortcutsProvider.notifier)
        .addShortcut(widget.shortcut.copyWith(label: label));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"$label" added to your shortcuts!',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
    context.go('/');
  }

  // ── UI ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final iconData = getShortcutIcon(widget.shortcut.iconName);
    final theme = Theme.of(context);

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

            Text(
              'Someone shared a place with you!',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Icon
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

                    // Editable label
                    TextField(
                      controller: _labelController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Label',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: theme.colorScheme.primary),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    // Label-duplicate hint
                    if (_labelHint != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _labelHint!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Address
                    Text(
                      widget.shortcut.address,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _addShortcut,
              child: const Text('Add to My Shortcuts'),
            ),

            const SizedBox(height: 12),

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
