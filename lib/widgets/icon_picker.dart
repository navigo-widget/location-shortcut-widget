import 'package:flutter/material.dart';
import 'package:location_shortcut_widget/utils/shortcut_icons.dart';

/// A colorful grid of preset icons for the user to choose from.
class IconPicker extends StatelessWidget {
  final String selectedIconName;
  final ValueChanged<String> onIconSelected;

  const IconPicker({
    super.key,
    required this.selectedIconName,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final entries = shortcutIcons.entries.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 10,
      runSpacing: 14,
      children: entries.map((entry) {
        final isSelected = entry.key == selectedIconName;
        final iconData = entry.value;

        return GestureDetector(
          onTap: () => onIconSelected(entry.key),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  // Always show the icon's color as background
                  color: isSelected
                      ? iconData.color
                      : iconData.color.withAlpha(isDark ? 50 : 35),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: iconData.color, width: 3)
                      : Border.all(
                          color: iconData.color.withAlpha(isDark ? 80 : 60),
                          width: 1.5,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: iconData.color.withAlpha(80),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  iconData.icon,
                  size: 28,
                  color: isSelected ? Colors.white : iconData.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                iconData.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? iconData.color
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
