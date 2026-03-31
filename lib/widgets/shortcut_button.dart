import 'package:flutter/material.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';
import 'package:location_shortcut_widget/utils/shortcut_icons.dart';

/// A large, senior-friendly button tile for a single location shortcut.
/// Vibrant colors with theme-aware backgrounds.
class ShortcutButton extends StatelessWidget {
  final LocationShortcut shortcut;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ShortcutButton({
    super.key,
    required this.shortcut,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = getShortcutIcon(shortcut.iconName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark
          ? iconData.color.withAlpha(30)
          : iconData.color.withAlpha(20),
      elevation: isDark ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: iconData.color.withAlpha(isDark ? 60 : 40),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large colorful icon circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconData.color,
                      iconData.color.withAlpha(180),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconData.color.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  iconData.icon,
                  size: 36,
                  color: Colors.white,
                  semanticLabel: shortcut.label,
                ),
              ),
              const SizedBox(height: 12),
              // Label
              Text(
                shortcut.label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Tap hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation_rounded, size: 14, color: iconData.color.withAlpha(180)),
                  const SizedBox(width: 3),
                  Text(
                    'Navigate',
                    style: TextStyle(
                      fontSize: 13,
                      color: iconData.color.withAlpha(180),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
