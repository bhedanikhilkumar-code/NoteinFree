import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import 'text_editor_screen.dart';
import 'checklist_editor_screen.dart';

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
    return reminderNotes.where((note) {
      if (note.reminderAt == null) return false;
      return isSameDay(note.reminderAt, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final reminderNotes = noteProvider.reminderNotes;
          final notesForSelectedDay = _selectedDay != null 
              ? _getNotesForDay(_selectedDay!, reminderNotes)
              : [];

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) => _getNotesForDay(day, reminderNotes),
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: notesForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final note = notesForSelectedDay[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: NoteCard(
                        note: note,
                        onTap: () {
                          if (note.type == NoteType.checklist) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChecklistEditorScreen(noteId: note.id)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TextEditorScreen(noteId: note.id)));
                          }
                        },
                        onLongPress: () {},
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
