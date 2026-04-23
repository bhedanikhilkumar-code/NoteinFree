import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'text_editor_screen.dart';
import 'checklist_editor_screen.dart';
import 'search_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../models/note.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showNewNoteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text Note'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TextEditorScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_box),
                title: const Text('Checklist Note'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChecklistEditorScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoteOptions(BuildContext context, String noteId) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin),
                title: const Text('Toggle Pin'),
                onTap: () {
                  noteProvider.togglePin(noteId);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('Archive'),
                onTap: () {
                  noteProvider.toggleArchive(noteId);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Move to Trash'),
                onTap: () {
                  noteProvider.moveToTrash(noteId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notein'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.allNotes;
          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet. Create one!'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () {
                  // Navigate to appropriate editor
                  if (note.type == NoteType.checklist) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChecklistEditorScreen(noteId: note.id)));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TextEditorScreen(noteId: note.id)));
                  }
                },
                onLongPress: () => _showNoteOptions(context, note.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewNoteOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
