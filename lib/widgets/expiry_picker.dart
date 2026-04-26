import 'package:flutter/material.dart';
import 'package:navigo/utils/expiry_utils.dart';

/// A row of chips letting the user pick an expiry duration.
class ExpiryPicker extends StatelessWidget {
  final ExpiryOption selected;
  final ValueChanged<ExpiryOption> onChanged;

  const ExpiryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    // In dark mode the mint primary is too bright as a chip background.
    // Flip: use dark green container as background, mint as text/border.
    final selectedBg =
        isDark ? theme.colorScheme.primaryContainer : primary;
    final selectedFg = isDark ? primary : Colors.white;
    final selectedBorder =
        isDark ? primary : primary;

    // Fixed single row — every option gets equal width, never wraps or
    // scrolls. Compact labels (e.g. "3d", "1m") keep this readable on
    // narrow phone screens.
    return Row(
      children: [
        for (var i = 0; i < ExpiryOption.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _chip(theme, ExpiryOption.values[i], selectedBg, selectedFg, selectedBorder)),
        ],
      ],
    );
  }

  Widget _chip(ThemeData theme, ExpiryOption option, Color selectedBg,
      Color selectedFg, Color selectedBorder) {
    final isSelected = option == selected;
    return Material(
      color: isSelected
          ? selectedBg
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(option),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: selectedBorder, width: 2)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            option.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color:
                  isSelected ? selectedFg : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}
