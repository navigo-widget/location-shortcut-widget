import 'package:flutter/material.dart';
import 'package:location_shortcut_widget/models/shortcut.dart';
import 'package:location_shortcut_widget/utils/shortcut_icons.dart';

/// A large, senior-friendly button tile for a single location shortcut.
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

    return Card(
      color: iconData.color.withAlpha(30),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconData.color.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData.icon,
                  size: 40,
                  color: iconData.color,
                  semanticLabel: shortcut.label,
                ),
              ),
              const SizedBox(height: 12),
              // Label
              Text(
                shortcut.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Tap hint
              Text(
                'Tap to navigate',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
