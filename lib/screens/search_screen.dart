import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'text_editor_screen.dart';
import 'checklist_editor_screen.dart';
import '../models/note.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            Provider.of<NoteProvider>(context, listen: false).setSearchQuery(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              Provider.of<NoteProvider>(context, listen: false).setSearchQuery('');
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.searchedNotes;
          if (notes.isEmpty) {
            return const Center(child: Text('No matching notes found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
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
          );
        },
      ),
    );
  }
}
