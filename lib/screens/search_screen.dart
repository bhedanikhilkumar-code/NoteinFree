import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'checklist_editor_screen.dart';
import 'text_editor_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    Provider.of<NoteProvider>(context, listen: false).setSearchQuery('');
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search title, content, or checklist items',
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: (String value) {
            Provider.of<NoteProvider>(context, listen: false).setSearchQuery(value);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () {
              _searchController.clear();
              Provider.of<NoteProvider>(context, listen: false).setSearchQuery('');
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (BuildContext context, NoteProvider noteProvider, Widget? child) {
          final List<Note> notes = noteProvider.searchedNotes;
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.search_off_rounded, size: 52, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'No matching notes found.',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              final Note note = notes[index];
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
            },
          );
        },
      ),
    );
  }
}
