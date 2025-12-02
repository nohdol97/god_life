import 'dart:convert';

class AppData {
  const AppData({required this.routines, required this.todos});

  final List<Routine> routines;
  final List<Todo> todos;

  AppData copyWith({List<Routine>? routines, List<Todo>? todos}) {
    return AppData(
      routines: routines ?? this.routines,
      todos: todos ?? this.todos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routines': routines.map((r) => r.toJson()).toList(),
      'todos': todos.map((t) => t.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory AppData.fromJson(Map<String, dynamic> json) {
    final routinesJson = json['routines'] as List<dynamic>? ?? [];
    final todosJson = json['todos'] as List<dynamic>? ?? [];
    return AppData(
      routines: routinesJson
          .map((e) => Routine.fromJson(e as Map<String, dynamic>))
          .toList(),
      todos: todosJson
          .map((e) => Todo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory AppData.sample() {
    return const AppData(
      routines: [
        Routine(
          id: 'r1',
          title: '독서하기',
          time: '07:30',
          note: '천천히 읽기',
          done: true,
        ),
        Routine(
          id: 'r2',
          title: '오메가3 섭취',
          time: '07:45',
          note: '물과 함께',
          done: true,
        ),
        Routine(id: 'r3', title: '환기하기', time: '08:00', note: '창문 5분 열기'),
        Routine(id: 'r4', title: '주 2회 운동', time: '저녁', note: '가볍게 스트레칭'),
      ],
      todos: [
        Todo(id: 't1', title: '장보기 리스트 확인', due: '오늘', priority: '보통'),
        Todo(id: 't2', title: '엄마 생신 선물 포장', due: 'D-2', priority: '높음'),
        Todo(id: 't3', title: '세탁기 돌리기', due: '오늘 오후', priority: '낮음'),
      ],
    );
  }
}

class Routine {
  const Routine({
    required this.id,
    required this.title,
    required this.time,
    required this.note,
    this.done = false,
    this.locked = false,
  });

  final String id;
  final String title;
  final String time;
  final String note;
  final bool done;
  final bool locked;

  Routine copyWith({
    String? id,
    String? title,
    String? time,
    String? note,
    bool? done,
    bool? locked,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      note: note ?? this.note,
      done: done ?? this.done,
      locked: locked ?? this.locked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'note': note,
      'done': done,
      'locked': locked,
    };
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String,
      title: json['title'] as String,
      time: json['time'] as String? ?? '',
      note: json['note'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
    );
  }
}

class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.due,
    this.priority = '보통',
    this.done = false,
    this.locked = false,
  });

  final String id;
  final String title;
  final String due;
  final String priority;
  final bool done;
  final bool locked;

  Todo copyWith({
    String? id,
    String? title,
    String? due,
    String? priority,
    bool? done,
    bool? locked,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      due: due ?? this.due,
      priority: priority ?? this.priority,
      done: done ?? this.done,
      locked: locked ?? this.locked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'due': due,
      'priority': priority,
      'done': done,
      'locked': locked,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      due: json['due'] as String? ?? '',
      priority: json['priority'] as String? ?? '보통',
      done: json['done'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
    );
  }
}
