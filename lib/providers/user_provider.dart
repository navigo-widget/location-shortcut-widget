import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

const _settingsBox = 'settings';
const _userNameKey = 'user_name';

/// Persisted user display name, used in share messages.
final userNameProvider =
    StateNotifierProvider<UserNameNotifier, String>((ref) {
  return UserNameNotifier();
});

class UserNameNotifier extends StateNotifier<String> {
  UserNameNotifier() : super('') {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_settingsBox);
    state = box.get(_userNameKey, defaultValue: '') as String;
  }

  Future<void> setName(String name) async {
    state = name.trim();
    final box = await Hive.openBox(_settingsBox);
    await box.put(_userNameKey, state);
  }
}
