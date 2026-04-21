import 'package:flutter/material.dart';

/// The five expiry options available to the user.
enum ExpiryOption { never, threeDays, oneWeek, oneMonth, oneYear }

extension ExpiryOptionX on ExpiryOption {
  String get label => switch (this) {
        ExpiryOption.never => 'Never',
        ExpiryOption.threeDays => '3 Days',
        ExpiryOption.oneWeek => '1 Week',
        ExpiryOption.oneMonth => '1 Month',
        ExpiryOption.oneYear => '1 Year',
      };

  /// Compute the absolute expiry DateTime from now, or null for never.
  DateTime? get expiresAt => switch (this) {
        ExpiryOption.never => null,
        ExpiryOption.threeDays => DateTime.now().add(const Duration(days: 3)),
        ExpiryOption.oneWeek => DateTime.now().add(const Duration(days: 7)),
        ExpiryOption.oneMonth => DateTime.now().add(const Duration(days: 30)),
        ExpiryOption.oneYear => DateTime.now().add(const Duration(days: 365)),
      };

  /// Warning threshold in days before expiry.
  int get warningDays => switch (this) {
        ExpiryOption.never => 0,
        ExpiryOption.threeDays => 1,
        ExpiryOption.oneWeek => 2,
        ExpiryOption.oneMonth => 7,
        ExpiryOption.oneYear => 30,
      };
}

/// Infer the original ExpiryOption from the stored expiresAt and createdAt.
/// Used to pre-select the correct chip in the edit screen.
ExpiryOption inferExpiryOption(DateTime? expiresAt, DateTime createdAt) {
  if (expiresAt == null) return ExpiryOption.never;
  final totalDays = expiresAt.difference(createdAt).inDays;
  if (totalDays <= 4) return ExpiryOption.threeDays;
  if (totalDays <= 10) return ExpiryOption.oneWeek;
  if (totalDays <= 45) return ExpiryOption.oneMonth;
  return ExpiryOption.oneYear;
}

/// The visual state of a tile based on how close it is to expiry.
enum ExpiryStatus { none, subtle, warning, urgent }

ExpiryStatus computeExpiryStatus(DateTime? expiresAt, DateTime createdAt) {
  if (expiresAt == null) return ExpiryStatus.none;

  final remaining = expiresAt.difference(DateTime.now());

  // Expired or expires today
  if (remaining.inDays <= 0) return ExpiryStatus.urgent;

  // Determine warning threshold from original total duration
  final totalDays = expiresAt.difference(createdAt).inDays;
  final option = totalDays <= 4
      ? ExpiryOption.threeDays
      : totalDays <= 10
          ? ExpiryOption.oneWeek
          : totalDays <= 45
              ? ExpiryOption.oneMonth
              : ExpiryOption.oneYear;

  if (remaining.inDays <= option.warningDays) return ExpiryStatus.warning;
  return ExpiryStatus.subtle;
}

/// Human-readable badge text for the remaining time.
String expiryBadgeText(DateTime expiresAt) {
  final days = expiresAt.difference(DateTime.now()).inDays;
  if (days <= 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  if (days < 7) return '$days days';
  final weeks = (days / 7).round();
  if (days < 30) return '$weeks ${weeks == 1 ? 'wk' : 'wks'}';
  final months = (days / 30).round();
  if (days < 365) return '$months ${months == 1 ? 'mo' : 'mos'}';
  return '${(days / 365).round()} yr';
}

/// Tile background tint for the top section based on expiry status.
Color? expiryTintColor(ExpiryStatus status, bool isDark) =>
    switch (status) {
      ExpiryStatus.urgent => isDark
          ? const Color(0xFF3D0A0A) // dark red tint
          : const Color(0xFFFDE8E8), // light red tint
      ExpiryStatus.warning => isDark
          ? const Color(0xFF2E1A00) // dark orange tint
          : const Color(0xFFFFF3E0), // light orange tint
      _ => null,
    };

/// Badge colour for the expiry pill.
Color expiryBadgeColor(ExpiryStatus status) => switch (status) {
      ExpiryStatus.urgent => const Color(0xFFC62828),
      ExpiryStatus.warning => const Color(0xFFFF8F00),
      ExpiryStatus.subtle => const Color(0xFF9E9E9E),
      ExpiryStatus.none => Colors.transparent,
    };
