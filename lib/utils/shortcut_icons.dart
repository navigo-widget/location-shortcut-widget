import 'package:flutter/material.dart';

class ShortcutIconData {
  final IconData icon;
  final Color color;
  final String label;

  const ShortcutIconData({
    required this.icon,
    required this.color,
    required this.label,
  });
}

/// Predefined icon options for shortcuts.
/// Each entry maps an icon name (stored in the model) to its visual data.
const Map<String, ShortcutIconData> shortcutIcons = {
  'home': ShortcutIconData(
    icon: Icons.home,
    color: Color(0xFF4CAF50),
    label: 'Home',
  ),
  'hospital': ShortcutIconData(
    icon: Icons.local_hospital,
    color: Color(0xFFF44336),
    label: 'Hospital',
  ),
  'bank': ShortcutIconData(
    icon: Icons.account_balance,
    color: Color(0xFF3F51B5),
    label: 'Bank',
  ),
  'grocery': ShortcutIconData(
    icon: Icons.shopping_cart,
    color: Color(0xFFFF9800),
    label: 'Grocery',
  ),
  'temple': ShortcutIconData(
    icon: Icons.temple_hindu,
    color: Color(0xFFFF5722),
    label: 'Temple',
  ),
  'pharmacy': ShortcutIconData(
    icon: Icons.local_pharmacy,
    color: Color(0xFF009688),
    label: 'Pharmacy',
  ),
  'restaurant': ShortcutIconData(
    icon: Icons.restaurant,
    color: Color(0xFFE91E63),
    label: 'Restaurant',
  ),
  'park': ShortcutIconData(
    icon: Icons.park,
    color: Color(0xFF8BC34A),
    label: 'Park',
  ),
  'office': ShortcutIconData(
    icon: Icons.work,
    color: Color(0xFF607D8B),
    label: 'Office',
  ),
  'school': ShortcutIconData(
    icon: Icons.school,
    color: Color(0xFF9C27B0),
    label: 'School',
  ),
  'place': ShortcutIconData(
    icon: Icons.place,
    color: Color(0xFF795548),
    label: 'Other',
  ),
};

/// Get the icon data for a given icon name, with a fallback.
ShortcutIconData getShortcutIcon(String iconName) {
  return shortcutIcons[iconName] ?? shortcutIcons['place']!;
}
