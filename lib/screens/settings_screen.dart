import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigo/providers/theme_provider.dart';
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
