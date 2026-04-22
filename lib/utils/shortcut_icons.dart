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

/// Predefined icon options for shortcuts — vibrant and colorful.
const Map<String, ShortcutIconData> shortcutIcons = {
  'home': ShortcutIconData(
    icon: Icons.home_rounded,
    color: Color(0xFF2E7D32),
    label: 'Home',
  ),
  'hospital': ShortcutIconData(
    icon: Icons.local_hospital_rounded,
    color: Color(0xFFD32F2F),
    label: 'Hospital',
  ),
  'bank': ShortcutIconData(
    icon: Icons.account_balance_rounded,
    color: Color(0xFF1565C0),
    label: 'Bank',
  ),
  'grocery': ShortcutIconData(
    icon: Icons.shopping_cart_rounded,
    color: Color(0xFFE65100),
    label: 'Grocery',
  ),
  'temple': ShortcutIconData(
    icon: Icons.temple_hindu_rounded,
    color: Color(0xFFBF360C),
    label: 'Temple',
  ),
  'mosque': ShortcutIconData(
    icon: Icons.mosque_rounded,
    color: Color(0xFF00695C),
    label: 'Mosque',
  ),
  'church': ShortcutIconData(
    icon: Icons.church_rounded,
    color: Color(0xFF4E342E),
    label: 'Church',
  ),
  'pharmacy': ShortcutIconData(
    icon: Icons.local_pharmacy_rounded,
    color: Color(0xFF00897B),
    label: 'Pharmacy',
  ),
  'restaurant': ShortcutIconData(
    icon: Icons.restaurant_rounded,
    color: Color(0xFFC2185B),
    label: 'Restaurant',
  ),
  'cafe': ShortcutIconData(
    icon: Icons.coffee_rounded,
    color: Color(0xFF6D4C41),
    label: 'Cafe',
  ),
  'park': ShortcutIconData(
    icon: Icons.park_rounded,
    color: Color(0xFF558B2F),
    label: 'Park',
  ),
  'office': ShortcutIconData(
    icon: Icons.business_rounded,
    color: Color(0xFF455A64),
    label: 'Office',
  ),
  'school': ShortcutIconData(
    icon: Icons.school_rounded,
    color: Color(0xFF6A1B9A),
    label: 'School',
  ),
  'gym': ShortcutIconData(
    icon: Icons.fitness_center_rounded,
    color: Color(0xFFEF6C00),
    label: 'Gym',
  ),
  'doctor': ShortcutIconData(
    icon: Icons.medical_services_rounded,
    color: Color(0xFFAD1457),
    label: 'Doctor',
  ),
  'airport': ShortcutIconData(
    icon: Icons.flight_rounded,
    color: Color(0xFF0277BD),
    label: 'Airport',
  ),
  'train': ShortcutIconData(
    icon: Icons.train_rounded,
    color: Color(0xFF546E7A), // steel blue-grey — railways/iron, not old brand indigo
    label: 'Train',
  ),
  'bus': ShortcutIconData(
    icon: Icons.directions_bus_rounded,
    color: Color(0xFF1B5E20),
    label: 'Bus Stop',
  ),
  'petrol': ShortcutIconData(
    icon: Icons.local_gas_station_rounded,
    color: Color(0xFF37474F),
    label: 'Petrol',
  ),
  'market': ShortcutIconData(
    icon: Icons.storefront_rounded,
    color: Color(0xFFF57F17),
    label: 'Market',
  ),
  'friend': ShortcutIconData(
    icon: Icons.people_rounded,
    color: Color(0xFF7B1FA2),
    label: 'Friend',
  ),
  'family': ShortcutIconData(
    icon: Icons.family_restroom_rounded,
    color: Color(0xFF00838F),
    label: 'Family',
  ),
  'place': ShortcutIconData(
    icon: Icons.place_rounded,
    color: Color(0xFF5D4037),
    label: 'Other',
  ),
};

/// Get the icon data for a given icon name, with a fallback.
ShortcutIconData getShortcutIcon(String iconName) {
  return shortcutIcons[iconName] ?? shortcutIcons['place']!;
}

/// Auto-detect the best icon based on the shortcut label.
/// Returns the icon key (e.g. 'hospital', 'bank').
String autoDetectIcon(String label) {
  final lower = label.toLowerCase();

  const patterns = <String, List<String>>{
    'hospital': ['hospital', 'medical center', 'clinic', 'health center', 'emergency'],
    'doctor': ['doctor', 'dr.', 'physician', 'dentist', 'dental'],
    'pharmacy': ['pharmacy', 'chemist', 'drugstore', 'medical store', 'medicine'],
    'bank': ['bank', 'atm', 'credit union', 'finance'],
    'grocery': ['grocery', 'supermarket', 'mart', 'provision', 'kirana'],
    'restaurant': ['restaurant', 'bistro', 'diner', 'eatery', 'dhaba', 'food'],
    'cafe': ['cafe', 'coffee', 'starbucks', 'bakery'],
    'temple': ['temple', 'mandir', 'hindu', 'gurudwara'],
    'mosque': ['mosque', 'masjid', 'islamic'],
    'church': ['church', 'cathedral', 'chapel', 'christian'],
    'school': ['school', 'college', 'university', 'academy', 'institute', 'education'],
    'park': ['park', 'garden', 'playground', 'nature'],
    'gym': ['gym', 'fitness', 'yoga', 'workout', 'sports'],
    'airport': ['airport', 'terminal', 'aviation'],
    'train': ['train', 'railway', 'station', 'metro'],
    'bus': ['bus stop', 'bus stand', 'bus station', 'bus depot'],
    'petrol': ['petrol', 'gas station', 'fuel', 'diesel', 'petroleum'],
    'market': ['market', 'bazaar', 'mall', 'shopping', 'store', 'shop'],
    'office': ['office', 'corporate', 'workspace', 'coworking'],
    'home': ['home', 'house', 'apartment', 'residence', 'flat'],
  };

  for (final entry in patterns.entries) {
    for (final keyword in entry.value) {
      if (lower.contains(keyword)) {
        return entry.key;
      }
    }
  }

  return 'place';
}
