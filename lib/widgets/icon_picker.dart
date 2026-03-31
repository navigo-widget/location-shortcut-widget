import 'package:flutter/material.dart';
import 'package:location_shortcut_widget/utils/shortcut_icons.dart';

/// A grid of preset icons for the user to choose from when creating a shortcut.
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

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: entries.map((entry) {
        final isSelected = entry.key == selectedIconName;
        final iconData = entry.value;

        return GestureDetector(
          onTap: () => onIconSelected(entry.key),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? iconData.color.withAlpha(60)
                      : Colors.grey.withAlpha(25),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: iconData.color, width: 3)
                      : null,
                ),
                child: Icon(
                  iconData.icon,
                  size: 32,
                  color: isSelected ? iconData.color : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                iconData.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? iconData.color : Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
