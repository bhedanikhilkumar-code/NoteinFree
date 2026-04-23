import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class TextEditorScreen extends StatefulWidget {
  final String? noteId;

  const TextEditorScreen({super.key, this.noteId});

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Note? _note;
  int _colorValue = 0xFFFFFFFF;
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    
    // Defer initialization to after build to access provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.noteId != null) {
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);
        _note = noteProvider.allNotes.firstWhere((n) => n.id == widget.noteId);
        setState(() {
          _titleController.text = _note!.title;
          _contentController.text = _note!.content;
          _colorValue = _note!.colorValue;
          _pinned = _note!.pinned;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.pop(context);
      return; // Don't save empty notes
    }

    if (_note == null) {
      // Create new note
      final newNote = Note(
        id: noteProvider.generateId(),
        title: _titleController.text,
        content: _contentController.text,
        type: NoteType.text,
        colorValue: _colorValue,
        pinned: _pinned,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      noteProvider.addNote(newNote);
    } else {
      // Update existing note
      _note!.title = _titleController.text;
      _note!.content = _contentController.text;
      _note!.colorValue = _colorValue;
      _note!.pinned = _pinned;
      noteProvider.updateNote(_note!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(_colorValue),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_pinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _pinned = !_pinned),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              maxLines: null,
            ),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Note',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
