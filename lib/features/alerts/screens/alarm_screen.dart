import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sine_ai/core/providers/app_providers.dart';
import 'package:sine_ai/services/notification_service.dart';
import 'package:sine_ai/themes/theme_extensions.dart';
import 'package:sine_ai/features/alerts/stopwatch/stopwatch_screen.dart';
import 'package:sine_ai/localization/app_strings.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});
  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _moods = [
    'Motivational 🔥',
    'Attitude 😤',
    'Funny 😂',
    'Spiritual 🙏',
    'Aggressive 🔥',
    'Caring ❤️',
    'Gentle 🌙',
  ];

  final _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    NotificationService.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleAlarm(int index, bool current) async {
    HapticFeedback.mediumImpact();
    ref.read(alarmProvider.notifier).toggleAlarm(index);
    final alarms = ref.read(alarmProvider);
    final alarm = alarms[index];
    if (!current) {
      await NotificationService.scheduleAlarm(
        id: alarm['id'] as int,
        time: alarm['time'] as String,
        label: alarm['label'] as String,
        mood: alarm['mood'] as String,
        days: List<bool>.from(alarm['days'] as List),
      );
    } else {
      await NotificationService.cancelAlarm(alarm['id'] as int);
    }
  }

  void _toggleReminder(int index, bool current) async {
    HapticFeedback.mediumImpact();
    ref.read(reminderProvider.notifier).toggleReminder(index);
    final reminders = ref.read(reminderProvider);
    final r = reminders[index];
    if (!current) {
      await NotificationService.scheduleReminder(
        id: r['id'] as int,
        time: r['time'] as String,
        label: r['label'] as String,
        message: r['message'] as String,
      );
    } else {
      await NotificationService.cancelAlarm(r['id'] as int);
    }
  }

  void _onAddPressed() {
    if (_tabController.index == 0) {
      _showAlarmSheet();
    } else {
      _showReminderSheet();
    }
  }

  void _showAlarmSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      isScrollControlled: true,
      builder: (_) => _AlarmAddSheet(
        moods: _moods,
        onAdd: (alarm) {
          ref.read(alarmProvider.notifier).addAlarm(alarm);
          NotificationService.scheduleAlarm(
            id: alarm['id'] as int,
            time: alarm['time'] as String,
            label: alarm['label'] as String,
            mood: alarm['mood'] as String,
            days: List<bool>.from(alarm['days'] as List),
          );
        },
      ),
    );
  }

  void _showEditAlarmSheet(int index) {
    final theme = Theme.of(context);
    final alarms = ref.read(alarmProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      isScrollControlled: true,
      builder: (_) => _AlarmAddSheet(
        moods: _moods,
        existingAlarm: alarms[index],
        onAdd: (alarm) {
          ref.read(alarmProvider.notifier).updateAlarm(index, alarm);
          NotificationService.cancelAlarm(alarms[index]['id'] as int);
          if (alarm['active'] == true) {
            NotificationService.scheduleAlarm(
              id: alarm['id'] as int,
              time: alarm['time'] as String,
              label: alarm['label'] as String,
              mood: alarm['mood'] as String,
              days: List<bool>.from(alarm['days'] as List),
            );
          }
        },
      ),
    );
  }

  void _showReminderSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      isScrollControlled: true,
      builder: (_) => _ReminderAddSheet(
        onAdd: (reminder) {
          ref.read(reminderProvider.notifier).addReminder(reminder);
          NotificationService.scheduleReminder(
            id: reminder['id'] as int,
            time: reminder['time'] as String,
            label: reminder['label'] as String,
            message: reminder['message'] as String,
          );
        },
      ),
    );
  }

  void _showEditReminderSheet(int index) {
    final theme = Theme.of(context);
    final reminders = ref.read(reminderProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      isScrollControlled: true,
      builder: (_) => _ReminderAddSheet(
        existingReminder: reminders[index],
        onAdd: (reminder) {
          ref.read(reminderProvider.notifier).updateReminder(index, reminder);
          NotificationService.cancelAlarm(reminders[index]['id'] as int);
          if (reminder['active'] == true) {
            NotificationService.scheduleReminder(
              id: reminder['id'] as int,
              time: reminder['time'] as String,
              label: reminder['label'] as String,
              message: reminder['message'] as String,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alarms = ref.watch(alarmProvider);
    final reminders = ref.watch(reminderProvider);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAlarmsList(alarms),
                  const StopwatchScreen(),
                  _buildRemindersList(reminders),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SINE ALERT',
                style: GoogleFonts.getFont(font,
                  fontSize: 11,
                  color: ext.textSecondary?.withValues(alpha: 0.4),
                  letterSpacing: 4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                AppStrings.get('alerts'),
                style: GoogleFonts.getFont(font,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (_tabController.index != 1)
          GestureDetector(
            onTap: _onAddPressed,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: ext.card,
          border: Border.all(color: ext.border ?? Colors.transparent),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
          ),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: ext.textSecondary?.withValues(alpha: 0.5),
          labelStyle: GoogleFonts.getFont(font, fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Alarms'),
            Tab(text: 'Stopwatch'),
            Tab(text: 'Reminders'),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmsList(List<Map<String, dynamic>> alarms) {
    return alarms.isEmpty
        ? _buildEmpty('Koi alarm nahi\n+ dabao aur banao!')
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            itemCount: alarms.length,
            itemBuilder: (_, i) => _buildAlarmCard(alarms, i),
          );
  }

  Widget _buildEmpty(String msg) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);
    return Center(
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: GoogleFonts.getFont(font, color: ext.textSecondary?.withValues(alpha: 0.4), fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAlarmCard(List<Map<String, dynamic>> alarms, int index) {
    final alarm = alarms[index];
    final active = alarm['active'] as bool;
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: ext.card,
        border: Border.all(
          color: active ? theme.colorScheme.primary.withValues(alpha: 0.3) : ext.border ?? Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm['time'] as String,
                      style: GoogleFonts.getFont(font,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: active ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      alarm['label'] as String,
                      style: GoogleFonts.getFont(font,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _toggleAlarm(index, active),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 54, height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: active ? (ext.primaryGradient ?? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary])) : null,
                      color: active ? null : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      alignment: active ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        width: 22, height: 22,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final on = (alarms[index]['days'] as List)[i] as bool;
                return Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      _days[i],
                      style: GoogleFonts.getFont(font,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: on ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: ext.border?.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showEditAlarmSheet(index),
                    icon: Icon(Icons.edit_rounded, size: 16, color: ext.textSecondary),
                    label: Text('Edit', style: GoogleFonts.getFont(font, color: ext.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(alarmProvider.notifier).removeAlarm(index);
                    },
                    icon: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent.withValues(alpha: 0.7)),
                    label: Text('Delete', style: GoogleFonts.getFont(font, color: Colors.redAccent.withValues(alpha: 0.7), fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(List<Map<String, dynamic>> reminders) {
    return reminders.isEmpty
        ? _buildEmpty('Koi reminder nahi\n+ dabao aur banao!')
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            itemCount: reminders.length,
            itemBuilder: (_, i) => _buildReminderCard(reminders, i),
          );
  }

  Widget _buildReminderCard(List<Map<String, dynamic>> reminders, int index) {
    final r = reminders[index];
    final active = r['active'] as bool;
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: ext.card,
        border: Border.all(color: active ? theme.colorScheme.primary.withValues(alpha: 0.3) : ext.border ?? Colors.transparent, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: active ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                  child: Center(child: Text(r['icon'] as String, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['label'] as String, style: GoogleFonts.getFont(font, fontSize: 16, fontWeight: FontWeight.w900, color: active ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                      Text('${r['time']} • ${r['repeat']}', style: GoogleFonts.getFont(font, fontSize: 13, color: active ? theme.colorScheme.primary : ext.textSecondary?.withValues(alpha: 0.4), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleReminder(index, active),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 54, height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      alignment: active ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        width: 22, height: 22,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ext.border?.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showEditReminderSheet(index),
                    icon: Icon(Icons.edit_rounded, size: 16, color: ext.textSecondary),
                    label: Text('Edit', style: GoogleFonts.getFont(font, color: ext.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(reminderProvider.notifier).removeReminder(index);
                    },
                    icon: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent.withValues(alpha: 0.7)),
                    label: Text('Delete', style: GoogleFonts.getFont(font, color: Colors.redAccent.withValues(alpha: 0.7), fontWeight: FontWeight.w700, fontSize: 13)),
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

class _AlarmAddSheet extends ConsumerStatefulWidget {
  final List<String> moods;
  final Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? existingAlarm;
  const _AlarmAddSheet({required this.moods, required this.onAdd, this.existingAlarm});
  @override
  ConsumerState<_AlarmAddSheet> createState() => _AlarmAddSheetState();
}

class _AlarmAddSheetState extends ConsumerState<_AlarmAddSheet> {
  late TimeOfDay _time;
  final _labelCtrl = TextEditingController();
  final List<bool> _days = [true, true, true, true, true, false, false];
  late String _selectedMood;

  @override
  void initState() {
    super.initState();
    _time = const TimeOfDay(hour: 7, minute: 0);
    _selectedMood = widget.moods.first;
    if (widget.existingAlarm != null) {
      final a = widget.existingAlarm!;
      _labelCtrl.text = a['label'] ?? '';
      _selectedMood = a['mood'] ?? widget.moods.first;
      if (a['days'] != null) {
        for (int i = 0; i < 7; i++) {
          _days[i] = (a['days'] as List)[i] as bool;
        }
      }
      final parts = (a['time'] as String).split(':');
      if (parts.length == 2) _time = TimeOfDay(hour: int.tryParse(parts[0]) ?? 7, minute: int.tryParse(parts[1]) ?? 0);
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: ext.border)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _time);
              if (t != null) setState(() => _time = t);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: ext.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ext.border ?? Colors.transparent),
              ),
              child: Center(
                child: Text(_time.format(context), style: GoogleFonts.getFont(font, fontSize: 56, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: -2)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _labelCtrl, 
            style: GoogleFonts.getFont(font, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Alarm Label (e.g. Gym)', 
              hintStyle: GoogleFonts.getFont(font, color: ext.textSecondary?.withValues(alpha: 0.4)),
              prefixIcon: Icon(Icons.label_rounded, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onAdd({
                  'id': widget.existingAlarm?['id'] ?? DateTime.now().millisecondsSinceEpoch % 100000,
                  'time': _time.format(context),
                  'label': _labelCtrl.text.isEmpty ? 'Alarm' : _labelCtrl.text,
                  'days': List.from(_days),
                  'active': true,
                  'mood': _selectedMood,
                });
                Navigator.pop(context);
              },
              child: const Text('Save Alarm'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderAddSheet extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? existingReminder;
  const _ReminderAddSheet({required this.onAdd, this.existingReminder});
  @override
  ConsumerState<_ReminderAddSheet> createState() => _ReminderAddSheetState();
}

class _ReminderAddSheetState extends ConsumerState<_ReminderAddSheet> {
  late TimeOfDay _time;
  final _labelCtrl = TextEditingController();
  String _selectedIcon = '🔔';

  @override
  void initState() {
    super.initState();
    _time = const TimeOfDay(hour: 9, minute: 0);
    if (widget.existingReminder != null) {
      _labelCtrl.text = widget.existingReminder!['label'] ?? '';
      _selectedIcon = widget.existingReminder!['icon'] ?? '🔔';
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final font = ref.watch(fontProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: ext.border)),
          const SizedBox(height: 24),
          TextField(
            controller: _labelCtrl, 
            style: GoogleFonts.getFont(font, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Reminder Label', 
              hintStyle: GoogleFonts.getFont(font, color: ext.textSecondary?.withValues(alpha: 0.4)),
              prefixIcon: Icon(Icons.notifications_active_rounded, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onAdd({
                  'id': widget.existingReminder?['id'] ?? DateTime.now().millisecondsSinceEpoch % 100000 + 200,
                  'time': _time.format(context),
                  'label': _labelCtrl.text.isEmpty ? 'Reminder' : _labelCtrl.text,
                  'repeat': 'Daily',
                  'active': true,
                  'icon': _selectedIcon,
                });
                Navigator.pop(context);
              },
              child: const Text('Save Reminder'),
            ),
          ),
        ],
      ),
    );
  }
}
