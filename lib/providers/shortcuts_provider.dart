import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:navigo/models/shortcut.dart';
import 'package:navigo/services/storage_service.dart';
import 'package:navigo/services/widget_service.dart';

const _uuid = Uuid();

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final shortcutsProvider =
    StateNotifierProvider<ShortcutsNotifier, List<LocationShortcut>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ShortcutsNotifier(storage);
});

class ShortcutsNotifier extends StateNotifier<List<LocationShortcut>> {
  final StorageService _storage;

  ShortcutsNotifier(this._storage) : super([]) {
    loadAll();
  }

  void loadAll() {
    state = _storage.getAll();
  }

  Future<void> addShortcut(LocationShortcut shortcut) async {
    final newShortcut = shortcut.copyWith(
      id: _uuid.v4(),
      sortOrder: state.length,
    );
    await _storage.add(newShortcut);
    state = _storage.getAll();
    await WidgetService.syncToWidget(state);
  }

  Future<void> updateShortcut(LocationShortcut shortcut) async {
    await _storage.update(shortcut);
    state = _storage.getAll();
    await WidgetService.syncToWidget(state);
  }

  Future<void> deleteShortcut(String id) async {
    await _storage.delete(id);
    state = _storage.getAll();
    await WidgetService.syncToWidget(state);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final shortcuts = List<LocationShortcut>.from(state);
    if (newIndex > oldIndex) newIndex--;
    final item = shortcuts.removeAt(oldIndex);
    shortcuts.insert(newIndex, item);
    await _storage.reorder(shortcuts);
    state = _storage.getAll();
    await WidgetService.syncToWidget(state);
  }
}
