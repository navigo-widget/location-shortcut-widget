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

    // Single horizontal row — scrolls horizontally on narrow screens rather
    // than wrapping to a second line.
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ExpiryOption.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = ExpiryOption.values[index];
          final isSelected = option == selected;
          return ChoiceChip(
            label: Text(option.label),
            selected: isSelected,
            onSelected: (_) => onChanged(option),
            selectedColor: selectedBg,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color:
                  isSelected ? selectedFg : theme.textTheme.bodyLarge?.color,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: isSelected
                  ? BorderSide(color: selectedBorder, width: 2)
                  : BorderSide.none,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
