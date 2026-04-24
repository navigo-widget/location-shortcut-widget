import 'package:flutter/material.dart';
import 'package:navigo/utils/expiry_utils.dart';

/// Single-row segmented button for picking an expiry duration.
/// Uses abbreviated labels (None / 3d / 1w / 1m / 1y) so it always fits
/// on one line regardless of screen width.
class ExpiryPicker extends StatelessWidget {
  final ExpiryOption selected;
  final ValueChanged<ExpiryOption> onChanged;

  const ExpiryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _shortLabel = {
    ExpiryOption.never:     'None',
    ExpiryOption.threeDays: '3d',
    ExpiryOption.oneWeek:   '1w',
    ExpiryOption.oneMonth:  '1m',
    ExpiryOption.oneYear:   '1y',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SegmentedButton<ExpiryOption>(
      segments: ExpiryOption.values
          .map(
            (option) => ButtonSegment<ExpiryOption>(
              value: option,
              label: Tooltip(
                message: option.label, // long-press shows full label
                child: Text(
                  _shortLabel[option]!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (newSelection) => onChanged(newSelection.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        // Selected segment: dark green bg, white text
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.primary;
          }
          return null; // let theme handle unselected
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark
                ? theme.colorScheme.primary   // mint on dark green
                : Colors.white;
          }
          return theme.colorScheme.onSurface;
        }),
      ),
    );
  }
}
