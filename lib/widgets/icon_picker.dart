import 'package:flutter/material.dart';
import 'package:navigo/utils/shortcut_icons.dart';

/// Shows the currently selected icon with a "Change" button.
/// Tapping the button opens a dialog with all available icons.
class IconPickerCompact extends StatelessWidget {
  final String selectedIconName;
  final ValueChanged<String> onIconSelected;

  const IconPickerCompact({
    super.key,
    required this.selectedIconName,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = getShortcutIcon(selectedIconName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
          ? Theme.of(context).colorScheme.surface
          : const Color(0xFFF5F5FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconData.color.withAlpha(isDark ? 80 : 50),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Selected icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconData.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconData.color.withAlpha(80),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              iconData.icon,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // Label
          Expanded(
            child: Text(
              iconData.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Change button
          TextButton(
            onPressed: () => _showIconPickerDialog(context),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showIconPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => IconPickerDialog(
        selectedIconName: selectedIconName,
        onIconSelected: (iconName) {
          onIconSelected(iconName);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Dialog showing all available icons in a grid.
class IconPickerDialog extends StatelessWidget {
  final String selectedIconName;
  final ValueChanged<String> onIconSelected;

  const IconPickerDialog({
    super.key,
    required this.selectedIconName,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final entries = shortcutIcons.entries.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Choose an icon'),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isSelected = entry.key == selectedIconName;
            final iconData = entry.value;

            return GestureDetector(
              onTap: () => onIconSelected(entry.key),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? iconData.color
                          : iconData.color.withAlpha(isDark ? 50 : 35),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: iconData.color, width: 3)
                          : Border.all(
                              color:
                                  iconData.color.withAlpha(isDark ? 80 : 60),
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
                      size: 24,
                      color: isSelected ? Colors.white : iconData.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    iconData.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? iconData.color
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
