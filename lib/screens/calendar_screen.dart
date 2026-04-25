import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../utils/custom_route_transitions.dart';
import '../utils/staggered_animation.dart';
import '../widgets/note_card.dart';
import 'checklist_editor_screen.dart';
import 'text_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectionPulseSeed = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Note> _getNotesForDay(DateTime day, List<Note> reminderNotes) {
    return reminderNotes.where((Note note) {
      if (note.reminderAt == null) {
        return false;
      }
      return isSameDay(note.reminderAt, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String monthKey = '${_focusedDay.year}-${_focusedDay.month}';

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder calendar')),
      body: Consumer<NoteProvider>(
        builder: (BuildContext context, NoteProvider noteProvider, Widget? child) {
          final List<Note> reminderNotes = noteProvider.reminderNotes;
          final List<Note> notesForSelectedDay = _selectedDay == null
              ? <Note>[]
              : _getNotesForDay(_selectedDay!, reminderNotes);
          final String selectedDayKey = _selectedDay == null
              ? 'none'
              : DateFormat('yyyy-MM-dd').format(_selectedDay!);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              Text(
                DateFormat('MMMM yyyy').format(_focusedDay),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Card(
                  key: ValueKey<String>(monthKey),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar<Note>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      focusedDay: _focusedDay,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      selectedDayPredicate: (DateTime day) => isSameDay(_selectedDay, day),
                      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectionPulseSeed++;
                        });
                      },
                      onPageChanged: (DateTime focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: (DateTime day) => _getNotesForDay(day, reminderNotes),
                      calendarStyle: CalendarStyle(
                        outsideTextStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.32),
                        ),
                        todayDecoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(color: Colors.transparent),
                        markerDecoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarBuilders: CalendarBuilders<Note>(
                        defaultBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
                          return _buildDayCell(
                            context: context,
                            day: day,
                            isSelected: false,
                            isToday: isSameDay(day, DateTime.now()),
                          );
                        },
                        todayBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
                          return _buildDayCell(
                            context: context,
                            day: day,
                            isSelected: false,
                            isToday: true,
                          );
                        },
                        selectedBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
                          return TweenAnimationBuilder<double>(
                            key: ValueKey<String>('${DateFormat('yyyy-MM-dd').format(day)}-$_selectionPulseSeed'),
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutBack,
                            tween: Tween<double>(begin: 0.82, end: 1),
                            builder: (BuildContext context, double value, Widget? child) {
                              return Transform.scale(scale: value, child: child);
                            },
                            child: _buildDayCell(
                              context: context,
                              day: day,
                              isSelected: true,
                              isToday: isSameDay(day, DateTime.now()),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Scheduled notes',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: notesForSelectedDay.isEmpty
                    ? Card(
                        key: ValueKey<String>('empty-$selectedDayKey'),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No reminders on this day.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : StaggeredListAnimation(
                        key: ValueKey<String>('notes-$selectedDayKey'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: notesForSelectedDay.map((Note note) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              height: 252,
                              child: NoteCard(
                                note: note,
                                onTap: () {
                                  if (note.type == NoteType.checklist) {
                                    Navigator.push(
                                      context,
                                      AnimatedPageRoute<void>(page: ChecklistEditorScreen(noteId: note.id)),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      AnimatedPageRoute<void>(page: TextEditorScreen(noteId: note.id)),
                                    );
                                  }
                                },
                                onLongPress: () {},
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayCell({
    required BuildContext context,
    required DateTime day,
    required bool isSelected,
    required bool isToday,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = isSelected
        ? theme.colorScheme.primary
        : isToday
            ? theme.colorScheme.primary.withOpacity(0.14)
            : Colors.transparent;
    final Color foregroundColor = isSelected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: theme.colorScheme.primary.withOpacity(0.22),
          onTap: null,
          child: Center(
            child: Text(
              '${day.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
