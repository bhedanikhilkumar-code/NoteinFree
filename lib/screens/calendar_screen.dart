import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder calendar')),
      body: Consumer<NoteProvider>(
        builder: (BuildContext context, NoteProvider noteProvider, Widget? child) {
          final List<Note> reminderNotes = noteProvider.reminderNotes;
          final List<Note> notesForSelectedDay = _selectedDay == null
              ? <Note>[]
              : _getNotesForDay(_selectedDay!, reminderNotes);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar<Note>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (DateTime day) => isSameDay(_selectedDay, day),
                    onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (DateTime day) => _getNotesForDay(day, reminderNotes),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Scheduled notes',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (notesForSelectedDay.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No reminders on this day.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ...notesForSelectedDay.map((Note note) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 210,
                      child: NoteCard(
                        note: note,
                        onTap: () {
                          if (note.type == NoteType.checklist) {
                            Navigator.push(
                              context,
                              MaterialPageRoute<ChecklistEditorScreen>(
                                builder: (_) => ChecklistEditorScreen(noteId: note.id),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute<TextEditorScreen>(
                                builder: (_) => TextEditorScreen(noteId: note.id),
                              ),
                            );
                          }
                        },
                        onLongPress: () {},
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
