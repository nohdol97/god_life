import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app_data.dart';
import 'src/providers.dart';

void main() {
  runApp(const ProviderScope(child: GodLifeApp()));
}

class GodLifeApp extends StatelessWidget {
  const GodLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'God Life',
      theme: const CupertinoThemeData(
        primaryColor: AppPalette.coralStrong,
        scaffoldBackgroundColor: AppPalette.coralBase,
        barBackgroundColor: AppPalette.coralSoft,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            color: AppPalette.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          navTitleTextStyle: TextStyle(
            color: AppPalette.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          navLargeTitleTextStyle: TextStyle(
            color: AppPalette.textDark,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appDataProvider);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppPalette.coralBase, AppPalette.coralSoft],
              ),
            ),
          ),
          data.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (e, _) => Center(
              child: Text(
                '불러오기 실패: $e',
                style: const TextStyle(color: AppPalette.textDark),
              ),
            ),
            data: (appData) => CustomScrollView(
              slivers: [
                const CupertinoSliverNavigationBar(largeTitle: Text('오늘 ✨')),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: _OverviewCard(
                      routines: appData.routines,
                      todos: appData.todos,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionHeader(title: '루틴 🐣', subtitle: '오늘의 작은 습관'),
                ),
                SliverList.builder(
                  itemCount: appData.routines.length,
                  itemBuilder: (context, index) => _RoutineTile(
                    routine: appData.routines[index],
                    onToggle: () => ref
                        .read(appDataProvider.notifier)
                        .toggleRoutine(appData.routines[index].id),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionHeader(title: '할 일 🌷', subtitle: '가볍게 체크하기'),
                ),
                SliverList.builder(
                  itemCount: appData.todos.length,
                  itemBuilder: (context, index) => _TodoTile(
                    todo: appData.todos[index],
                    onToggle: () => ref
                        .read(appDataProvider.notifier)
                        .toggleTodo(appData.todos[index].id),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
          _AddButton(
            onPressed: () {
              _showAddSheet(context, ref.read(appDataProvider.notifier));
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.routines, required this.todos});

  final List<Routine> routines;
  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    final completed = routines.where((r) => r.done).length;
    final totalRoutine = routines.length;
    final double doneRatio = totalRoutine == 0
        ? 0.0
        : (completed / totalRoutine);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.coralSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(40, 0, 0, 0),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘 요약 ✨',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPalette.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: '루틴 완료',
                  value: '$completed / $totalRoutine',
                  icon: CupertinoIcons.check_mark_circled_solid,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatChip(
                  label: '할 일 남음',
                  value: '${todos.length}',
                  icon: CupertinoIcons.square_list,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: doneRatio,
              backgroundColor: AppPalette.coralSoft,
              color: AppPalette.coralStrong,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.coralSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppPalette.textDark),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppPalette.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textDark,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppPalette.textMuted,
                ),
              ),
            ],
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minSize: 26,
            color: AppPalette.coralStrong.withOpacity(0.14),
            borderRadius: BorderRadius.circular(20),
            onPressed: () {},
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.plus_circle_fill,
                  color: AppPalette.coralStrong,
                  size: 18,
                ),
                SizedBox(width: 4),
                Text(
                  '추가',
                  style: TextStyle(color: AppPalette.textDark, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({required this.routine, required this.onToggle});

  final Routine routine;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.coralSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _CheckMark(active: routine.done, onTap: onToggle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${routine.time} · ${routine.note}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 16,
              color: AppPalette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({required this.todo, required this.onToggle});

  final Todo todo;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.coralSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _CheckMark(active: todo.done, onTap: onToggle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${todo.due} · 우선순위 ${todo.priority}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              CupertinoIcons.bell_solid,
              size: 16,
              color: AppPalette.coralStrong,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.active, this.onTap});

  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppPalette.coralStrong : AppPalette.coralSoft,
          border: Border.all(
            color: active
                ? AppPalette.coralStrong
                : AppPalette.textMuted.withOpacity(0.25),
            width: 1.4,
          ),
        ),
        child: active
            ? const Icon(
                CupertinoIcons.check_mark,
                size: 14,
                color: CupertinoColors.white,
              )
            : null,
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: SafeArea(
        child: CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(vertical: 14),
          borderRadius: BorderRadius.circular(14),
          onPressed: onPressed,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.add_circled_solid,
                color: CupertinoColors.white,
              ),
              SizedBox(width: 8),
              Text(
                '오늘 루틴/할 일 추가하기',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppPalette {
  static const Color coralBase = Color(0xFFF6B6B6);
  static const Color coralSurface = Color(0xFFF9DADA);
  static const Color coralSoft = Color(0xFFFDEEEF);
  static const Color coralStrong = Color(0xFFF26B8A);
  static const Color textDark = Color(0xFF3A2F2F);
  static const Color textMuted = Color(0xFF6D5C5C);
}

void _showAddSheet(BuildContext context, AppDataNotifier notifier) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (context) => _AddItemSheet(notifier: notifier),
  );
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet({required this.notifier});

  final AppDataNotifier notifier;

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _noteController = TextEditingController();
  final _dueController = TextEditingController();
  String _priority = '보통';
  ItemType _type = ItemType.routine;
  DateTime? _reminderTime;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('추가하기'),
      message: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoSegmentedControl<ItemType>(
              groupValue: _type,
              children: const {
                ItemType.routine: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text('루틴'),
                ),
                ItemType.todo: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text('할 일'),
                ),
              },
              onValueChanged: (value) {
                setState(() {
                  _type = value;
                });
              },
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: _titleController,
              placeholder: _type == ItemType.routine ? '루틴 제목' : '할 일 제목',
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
            const SizedBox(height: 8),
            if (_type == ItemType.routine) ...[
              CupertinoTextField(
                controller: _timeController,
                placeholder: '시간 (예: 07:30, 아침)',
                clearButtonMode: OverlayVisibilityMode.editing,
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _noteController,
                placeholder: '메모(선택)',
                clearButtonMode: OverlayVisibilityMode.editing,
              ),
              const SizedBox(height: 8),
              _ReminderPicker(
                label: '알림 시간',
                value: _reminderTime,
                onPick: _pickTime,
                onClear: () => setState(() => _reminderTime = null),
              ),
            ] else ...[
              CupertinoTextField(
                controller: _dueController,
                placeholder: '기한 (예: 오늘, D-2)',
                clearButtonMode: OverlayVisibilityMode.editing,
              ),
              const SizedBox(height: 8),
              const Text(
                '우선순위',
                style: TextStyle(fontSize: 13, color: AppPalette.textMuted),
              ),
              const SizedBox(height: 6),
              CupertinoSegmentedControl<String>(
                groupValue: _priority,
                children: const {
                  '낮음': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text('낮음'),
                  ),
                  '보통': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text('보통'),
                  ),
                  '높음': Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text('높음'),
                  ),
                },
                onValueChanged: (value) {
                  setState(() {
                    _priority = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              _ReminderPicker(
                label: '알림 시간',
                value: _reminderTime,
                onPick: _pickTime,
                onClear: () => setState(() => _reminderTime = null),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(color: CupertinoColors.systemRed),
              ),
            ],
          ],
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: _handleSave,
          isDefaultAction: true,
          child: const Text('저장'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        isDestructiveAction: false,
        child: const Text('취소'),
      ),
    );
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = '제목을 입력해주세요');
      return;
    }
    final time = _timeController.text.trim();
    final note = _noteController.text.trim();
    final due = _dueController.text.trim();

    if (_type == ItemType.routine) {
      await widget.notifier.addRoutine(
        title: title,
        time: time.isEmpty ? '언제든' : time,
        note: note,
        remindAt: _reminderTime != null ? _formatTime(_reminderTime!) : '',
      );
    } else {
      await widget.notifier.addTodo(
        title: title,
        due: due.isEmpty ? '오늘' : due,
        priority: _priority,
        remindAt: _reminderTime != null ? _formatTime(_reminderTime!) : '',
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickTime() async {
    DateTime initial = _reminderTime ?? DateTime.now();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 260,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('완료'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: initial,
                  onDateTimeChanged: (value) {
                    setState(() => _reminderTime = value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

enum ItemType { routine, todo }

class _ReminderPicker extends StatelessWidget {
  const _ReminderPicker({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final display = value == null
        ? '알림 없음'
        : '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppPalette.textMuted)),
            Text(
              display,
              style: const TextStyle(
                color: AppPalette.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              onPressed: onPick,
              child: const Text('선택'),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              onPressed: onClear,
              child: const Text(
                '지우기',
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
