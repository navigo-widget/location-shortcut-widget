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
    final primary = theme.colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExpiryOption.values.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) => onChanged(option),
          selectedColor: primary,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          labelStyle: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isSelected
                ? BorderSide(color: primary, width: 2)
                : BorderSide.none,
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
