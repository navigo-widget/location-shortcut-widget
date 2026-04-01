import 'package:hive_ce/hive.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/utils/constants.dart';

/// Wraps Hive box operations for LocationShortcut persistence.
class StorageService {
  Box<LocationShortcut> get _box => Hive.box<LocationShortcut>(kHiveBoxName);

  /// Retrieve all shortcuts sorted by sortOrder.
  List<LocationShortcut> getAll() {
    final shortcuts = _box.values.toList();
    shortcuts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return shortcuts;
  }

  /// Add a new shortcut.
  Future<void> add(LocationShortcut shortcut) async {
    await _box.put(shortcut.id, shortcut);
  }

  /// Update an existing shortcut.
  Future<void> update(LocationShortcut shortcut) async {
    await _box.put(shortcut.id, shortcut);
  }

  /// Delete a shortcut by ID.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Reorder shortcuts by writing new sortOrder values.
  Future<void> reorder(List<LocationShortcut> reorderedShortcuts) async {
    for (int i = 0; i < reorderedShortcuts.length; i++) {
      reorderedShortcuts[i].sortOrder = i;
      await _box.put(reorderedShortcuts[i].id, reorderedShortcuts[i]);
    }
  }
}
