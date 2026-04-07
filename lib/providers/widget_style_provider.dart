import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

const _settingsBox = 'settings';
const _widgetStyleKey = 'widget_style';

/// Available widget visual styles.
enum WidgetStyle {
  frostedGlass,
  boldColors,
}

/// Persisted widget style preference.
final widgetStyleProvider =
    StateNotifierProvider<WidgetStyleNotifier, WidgetStyle>((ref) {
  return WidgetStyleNotifier();
});

class WidgetStyleNotifier extends StateNotifier<WidgetStyle> {
  WidgetStyleNotifier() : super(WidgetStyle.frostedGlass) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_settingsBox);
    final stored =
        box.get(_widgetStyleKey, defaultValue: 'frostedGlass') as String;
    state = _fromString(stored);
  }

  Future<void> setStyle(WidgetStyle style) async {
    state = style;
    final box = await Hive.openBox(_settingsBox);
    await box.put(_widgetStyleKey, _toString(style));
  }

  static WidgetStyle _fromString(String value) {
    switch (value) {
      case 'boldColors':
        return WidgetStyle.boldColors;
      default:
        return WidgetStyle.frostedGlass;
    }
  }

  static String _toString(WidgetStyle style) {
    switch (style) {
      case WidgetStyle.frostedGlass:
        return 'frostedGlass';
      case WidgetStyle.boldColors:
        return 'boldColors';
    }
  }
}
