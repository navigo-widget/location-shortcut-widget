import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigo/providers/shortcuts_provider.dart';
import 'package:navigo/providers/theme_provider.dart';
import 'package:navigo/providers/widget_style_provider.dart';
import 'package:navigo/services/widget_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _isWidgetPinned;

  @override
  void initState() {
    super.initState();
    _checkWidgetStatus();
  }

  Future<void> _checkWidgetStatus() async {
    final pinned = await WidgetService.isWidgetPinned();
    if (mounted) {
      setState(() => _isWidgetPinned = pinned);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Widget section
          Text(
            'Home Screen Widget',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _isWidgetPinned == true
                        ? Icons.widgets_rounded
                        : Icons.widgets_outlined,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isWidgetPinned == true
                              ? 'Widget is on home screen'
                              : 'Widget not added',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isWidgetPinned == true
                              ? 'Your shortcuts are accessible from the home screen'
                              : 'Add the widget for one-tap navigation',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (_isWidgetPinned == false)
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await WidgetService.requestPinWidget();
                        // Re-check after a short delay to allow the system to process
                        Future.delayed(const Duration(seconds: 2), () {
                          _checkWidgetStatus();
                        });
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Add'),
                      style: FilledButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  if (_isWidgetPinned == true)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Widget Style section
          Text(
            'Widget Style',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          _WidgetStylePicker(),

          const SizedBox(height: 28),

          // Appearance section
          Text(
            'Appearance',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          _ThemeOptionTile(
            title: 'System Default',
            subtitle: 'Follow your device settings',
            icon: Icons.settings_suggest,
            isSelected: currentMode == ThemeMode.system,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.system),
          ),
          const SizedBox(height: 8),
          _ThemeOptionTile(
            title: 'Light Mode',
            subtitle: 'Always use light theme',
            icon: Icons.light_mode,
            isSelected: currentMode == ThemeMode.light,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.light),
          ),
          const SizedBox(height: 8),
          _ThemeOptionTile(
            title: 'Dark Mode',
            subtitle: 'Always use dark theme',
            icon: Icons.dark_mode,
            isSelected: currentMode == ThemeMode.dark,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.dark),
          ),

          const SizedBox(height: 32),

          // About section
          Text(
            'About',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NaviGo',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'One-tap navigation for the people who need it most.\nNaviGo makes getting around simple.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      color: isSelected ? primaryColor.withAlpha(25) : theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon,
                  size: 32,
                  color: isSelected ? primaryColor : theme.iconTheme.color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? primaryColor
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primaryColor, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetStylePicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(widgetStyleProvider);

    return Row(
      children: [
        Expanded(
          child: _WidgetStyleCard(
            label: 'Frosted Glass',
            isSelected: currentStyle == WidgetStyle.frostedGlass,
            onTap: () async {
              await ref
                  .read(widgetStyleProvider.notifier)
                  .setStyle(WidgetStyle.frostedGlass);
              // Re-sync widget with new style
              final shortcuts = ref.read(shortcutsProvider);
              await WidgetService.syncToWidget(shortcuts,
                  style: WidgetStyle.frostedGlass);
            },
            child: _FrostedGlassPreview(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WidgetStyleCard(
            label: 'Bold Colors',
            isSelected: currentStyle == WidgetStyle.boldColors,
            onTap: () async {
              await ref
                  .read(widgetStyleProvider.notifier)
                  .setStyle(WidgetStyle.boldColors);
              final shortcuts = ref.read(shortcutsProvider);
              await WidgetService.syncToWidget(shortcuts,
                  style: WidgetStyle.boldColors);
            },
            child: _BoldColorsPreview(),
          ),
        ),
      ],
    );
  }
}

class _WidgetStyleCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _WidgetStyleCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : theme.dividerColor,
            width: isSelected ? 2.5 : 1,
          ),
          color: isSelected
              ? const Color(0xFFE3F2FD)
              : theme.cardTheme.color ?? theme.cardColor,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 90,
                child: child,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child:
                        Icon(Icons.check_circle, color: primaryColor, size: 18),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? primaryColor
                        : theme.textTheme.bodyLarge?.color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini frosted-glass widget preview.
class _FrostedGlassPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          // Title bar
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 36,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 2x2 grid of glass tiles
          Expanded(
            child: Row(
              children: [
                Expanded(child: _glassTile()),
                const SizedBox(width: 4),
                Expanded(child: _glassTile()),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _glassTile()),
                const SizedBox(width: 4),
                Expanded(child: _glassTile()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(90),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(140),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Mini bold-colors widget preview.
class _BoldColorsPreview extends StatelessWidget {
  static const _colors = [
    Color(0xFF1565C0),
    Color(0xFF00897B),
    Color(0xFFE65100),
    Color(0xFF6A1B9A),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade900,
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _boldTile(_colors[0])),
                const SizedBox(width: 4),
                Expanded(child: _boldTile(_colors[1])),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _boldTile(_colors[2])),
                const SizedBox(width: 4),
                Expanded(child: _boldTile(_colors[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _boldTile(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.place,
          color: Colors.white.withAlpha(200),
          size: 16,
        ),
      ),
    );
  }
}
