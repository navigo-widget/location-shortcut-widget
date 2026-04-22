import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/providers/shortcuts_provider.dart';
import 'package:navigo/services/navigation_service.dart';
import 'package:navigo/services/sharing_service.dart';
import 'package:navigo/services/widget_service.dart';
import 'package:navigo/utils/shortcut_icons.dart';
import 'package:navigo/widgets/shortcut_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _reorderMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWidgetPrompt();
    });
  }

  Future<void> _checkWidgetPrompt() async {
    final box = await Hive.openBox('settings');
    final hasPrompted =
        box.get('widget_prompt_shown', defaultValue: false) as bool;

    if (hasPrompted || !mounted) return;

    final isPinned = await WidgetService.isWidgetPinned();
    if (isPinned || !mounted) return;

    await box.put('widget_prompt_shown', true);
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete with confirmation ─────────────────────────────────────────────

  Future<void> _confirmDelete(LocationShortcut shortcut) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${shortcut.label}"?'),
        content: const Text('You will lose this shortcut. This cannot be undone.'),
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
      ref.read(shortcutsProvider.notifier).deleteShortcut(shortcut.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = ref.watch(shortcutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NaviGo'),
        actions: [
          if (shortcuts.isNotEmpty)
            TextButton(
              onPressed: () =>
                  setState(() => _reorderMode = !_reorderMode),
              child: Text(_reorderMode ? 'Done' : 'Reorder'),
            ),
          if (!_reorderMode)
            IconButton(
              icon: const Icon(Icons.settings, size: 28),
              tooltip: 'Settings',
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: _reorderMode
          ? _ReorderList(shortcuts: shortcuts)
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                // +1 for the placeholder tile that is always last
                itemCount: shortcuts.length + 1,
                itemBuilder: (context, index) {
                  if (index == shortcuts.length) {
                    return _PlaceholderTile(
                      onTap: () => context.push('/add'),
                    );
                  }
                  final shortcut = shortcuts[index];
                  return ShortcutButton(
                    shortcut: shortcut,
                    onEdit: () => context.push('/edit/${shortcut.id}'),
                    onNavigate: () =>
                        _navigateToPlace(context, shortcut),
                    onShare: () =>
                        SharingService.shareShortcutWithFallback(shortcut),
                    onDelete: () => _confirmDelete(shortcut),
                  );
                },
              ),
            ),
      floatingActionButton: _reorderMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/add'),
              icon: const Icon(Icons.add_location, size: 28),
              label: const Text('Add Place'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _navigateToPlace(
      BuildContext context, LocationShortcut shortcut) async {
    final success = await NavigationService.navigateTo(shortcut);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open a maps app. Please install Google Maps or another navigation app.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
  }
}

// ── Placeholder tile ──────────────────────────────────────────────────────────

class _PlaceholderTile extends StatelessWidget {
  final VoidCallback onTap;
  const _PlaceholderTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final borderColor = isDark
        ? primary.withAlpha(100)
        : primary.withAlpha(80);
    final iconColor = isDark
        ? primary.withAlpha(160)
        : primary.withAlpha(140);
    final textColor = isDark
        ? primary.withAlpha(180)
        : primary.withAlpha(160);

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: borderColor),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_location_alt_rounded,
                size: 40,
                color: iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                'Add your first\nlocation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 2.0;
    const dashLen = 8.0;
    const gapLen = 6.0;
    const radius = 20.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
            size.width - strokeWidth, size.height - strokeWidth),
        const Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLen : gapLen;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, distance + len),
            paint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

// ── Reorder list ──────────────────────────────────────────────────────────────

class _ReorderList extends ConsumerWidget {
  final List<LocationShortcut> shortcuts;
  const _ReorderList({required this.shortcuts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      itemCount: shortcuts.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(shortcutsProvider.notifier).reorder(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final shortcut = shortcuts[index];
        final iconData = getShortcutIcon(shortcut.iconName);

        return Card(
          key: ValueKey(shortcut.id),
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: iconData.color.withAlpha(40),
              child: Icon(iconData.icon, color: iconData.color, size: 24),
            ),
            title: Text(
              shortcut.label,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              shortcut.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            trailing: ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle_rounded,
                    size: 26, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }
}
