import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app_data.dart';
import 'local_store.dart';
import 'notifications.dart';

final localStoreProvider = Provider<LocalStore>((ref) {
  return LocalStore();
});

final appDataProvider = AsyncNotifierProvider<AppDataNotifier, AppData>(
  AppDataNotifier.new,
);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});

class AppDataNotifier extends AsyncNotifier<AppData> {
  Timer? _saveTimer;
  AppData? _pendingData;

  @override
  Future<AppData> build() async {
    final store = ref.read(localStoreProvider);
    ref.onDispose(() {
      _saveTimer?.cancel();
    });
    await ref.read(notificationServiceProvider).init();
    final data = await store.load();
    return data;
  }

  Future<void> toggleRoutine(String id) async {
    final current = state.asData?.value;
    if (current == null) return;
    final target = current.routines.firstWhere((r) => r.id == id);
    final toggledDone = !target.done;
    final updated = current.copyWith(
      routines: current.routines
          .map((r) => r.id == id ? r.copyWith(done: !r.done) : r)
          .toList(),
    );
    await _persist(updated);
    await _handleToggleNotification(
      id: id,
      title: target.title,
      body: target.note.isEmpty ? target.time : target.note,
      remindAt: target.remindAt,
      toDone: toggledDone,
    );
  }

  Future<void> toggleTodo(String id) async {
    final current = state.asData?.value;
    if (current == null) return;
    final target = current.todos.firstWhere((t) => t.id == id);
    final toggledDone = !target.done;
    final updated = current.copyWith(
      todos: current.todos
          .map((t) => t.id == id ? t.copyWith(done: !t.done) : t)
          .toList(),
    );
    await _persist(updated);
    await _handleToggleNotification(
      id: id,
      title: target.title,
      body: target.due,
      remindAt: target.remindAt,
      toDone: toggledDone,
    );
  }

  Future<void> _persist(AppData data) async {
    state = AsyncData(data);
    _pendingData = data;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final pending = _pendingData;
        if (pending != null) {
          await ref.read(localStoreProvider).save(pending);
        }
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }

  Future<void> addRoutine({
    required String title,
    String time = '언제든',
    String note = '',
    String remindAt = '',
  }) async {
    final current =
        state.asData?.value ?? const AppData(routines: [], todos: []);
    final newRoutine = Routine(
      id: _id(),
      title: title,
      time: time,
      note: note,
      remindAt: remindAt,
    );
    final updated = current.copyWith(
      routines: [...current.routines, newRoutine],
    );
    await _persist(updated);
    await _scheduleIfNeeded(newRoutine.id, title, note, remindAt);
  }

  Future<void> addTodo({
    required String title,
    String due = '오늘',
    String priority = '보통',
    String remindAt = '',
  }) async {
    final current =
        state.asData?.value ?? const AppData(routines: [], todos: []);
    final newTodo = Todo(
      id: _id(),
      title: title,
      due: due,
      priority: priority,
      remindAt: remindAt,
    );
    final updated = current.copyWith(todos: [...current.todos, newTodo]);
    await _persist(updated);
    await _scheduleIfNeeded(newTodo.id, title, due, remindAt);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _scheduleIfNeeded(
    String id,
    String title,
    String body,
    String remindAt,
  ) async {
    final scheduled = _nextDateTime(remindAt);
    if (scheduled == null) return;
    await ref
        .read(notificationServiceProvider)
        .scheduleOnce(
          id: id.hashCode & 0x7fffffff,
          title: title,
          body: body,
          dateTime: scheduled,
        );
  }

  Future<void> _handleToggleNotification({
    required String id,
    required String title,
    required String body,
    required String remindAt,
    required bool toDone,
  }) async {
    if (remindAt.isEmpty) return;
    final notifier = ref.read(notificationServiceProvider);
    final notiId = id.hashCode & 0x7fffffff;
    if (toDone) {
      await notifier.cancel(notiId);
    } else {
      final scheduled = _nextDateTime(remindAt);
      if (scheduled != null) {
        await notifier.scheduleOnce(
          id: notiId,
          title: title,
          body: body,
          dateTime: scheduled,
        );
      }
    }
  }

  DateTime? _nextDateTime(String remindAt) {
    if (remindAt.isEmpty) return null;
    final parts = remindAt.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
