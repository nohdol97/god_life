import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_data.dart';
import 'local_store.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  return LocalStore();
});

final appDataProvider = AsyncNotifierProvider<AppDataNotifier, AppData>(
  AppDataNotifier.new,
);

class AppDataNotifier extends AsyncNotifier<AppData> {
  @override
  Future<AppData> build() async {
    final store = ref.read(localStoreProvider);
    final data = await store.load();
    return data;
  }

  Future<void> toggleRoutine(String id) async {
    final current = state.asData?.value;
    if (current == null) return;
    final updated = current.copyWith(
      routines: current.routines
          .map((r) => r.id == id ? r.copyWith(done: !r.done) : r)
          .toList(),
    );
    await _persist(updated);
  }

  Future<void> toggleTodo(String id) async {
    final current = state.asData?.value;
    if (current == null) return;
    final updated = current.copyWith(
      todos: current.todos
          .map((t) => t.id == id ? t.copyWith(done: !t.done) : t)
          .toList(),
    );
    await _persist(updated);
  }

  Future<void> _persist(AppData data) async {
    state = AsyncData(data);
    try {
      await ref.read(localStoreProvider).save(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addRoutine({
    required String title,
    String time = '언제든',
    String note = '',
  }) async {
    final current =
        state.asData?.value ?? const AppData(routines: [], todos: []);
    final newRoutine = Routine(id: _id(), title: title, time: time, note: note);
    final updated = current.copyWith(
      routines: [...current.routines, newRoutine],
    );
    await _persist(updated);
  }

  Future<void> addTodo({
    required String title,
    String due = '오늘',
    String priority = '보통',
  }) async {
    final current =
        state.asData?.value ?? const AppData(routines: [], todos: []);
    final newTodo = Todo(id: _id(), title: title, due: due, priority: priority);
    final updated = current.copyWith(todos: [...current.todos, newTodo]);
    await _persist(updated);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
}
