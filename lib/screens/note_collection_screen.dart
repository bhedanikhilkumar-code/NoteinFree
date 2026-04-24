import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'checklist_editor_screen.dart';
import 'text_editor_screen.dart';

enum NoteCollectionType { archived, trash }

class NoteCollectionScreen extends StatelessWidget {
  final NoteCollectionType type;

  const NoteCollectionScreen({super.key, required this.type});

  String get _title {
    switch (type) {
      case NoteCollectionType.archived:
        return 'Archived';
      case NoteCollectionType.trash:
        return 'Trash';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Consumer<NoteProvider>(
        builder: (BuildContext context, NoteProvider noteProvider, Widget? child) {
          final List<Note> notes = type == NoteCollectionType.archived
              ? noteProvider.archivedNotes
              : noteProvider.deletedNotes;

          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      type == NoteCollectionType.archived
                          ? Icons.archive_outlined
                          : Icons.delete_outline_rounded,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      type == NoteCollectionType.archived
                          ? 'No archived notes yet.'
                          : 'Trash is empty.',
                    ),
                  ],
                ),
              ),
            );
          }

          final int columns = MediaQuery.of(context).size.width > 780 ? 3 : 2;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 220,
            ),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              final Note note = notes[index];
              return NoteCard(
                note: note,
                onTap: () => _openNote(context, note),
                onLongPress: () => _showActions(context, noteProvider, note),
              );
            },
          );
        },
      ),
    );
  }

  void _openNote(BuildContext context, Note note) {
    if (note.type == NoteType.checklist) {
      Navigator.push(
        context,
        MaterialPageRoute<ChecklistEditorScreen>(
          builder: (_) => ChecklistEditorScreen(noteId: note.id),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<TextEditorScreen>(
        builder: (_) => TextEditorScreen(noteId: note.id),
      ),
    );
  }

  void _showActions(BuildContext context, NoteProvider noteProvider, Note note) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (type == NoteCollectionType.archived)
                ListTile(
                  leading: const Icon(Icons.unarchive_outlined),
                  title: const Text('Move back to notes'),
                  onTap: () async {
                    await noteProvider.toggleArchive(note.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              if (type == NoteCollectionType.archived)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Move to trash'),
                  onTap: () async {
                    await noteProvider.moveToTrash(note.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              if (type == NoteCollectionType.trash)
                ListTile(
                  leading: const Icon(Icons.restore_rounded),
                  title: const Text('Restore note'),
                  onTap: () async {
                    await noteProvider.restoreNote(note.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              if (type == NoteCollectionType.trash)
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded),
                  title: const Text('Delete permanently'),
                  onTap: () async {
                    await noteProvider.deletePermanently(note.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
