import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/checklist_item.dart';
import '../providers/note_provider.dart';

class ChecklistEditorScreen extends StatefulWidget {
  final String? noteId;

  const ChecklistEditorScreen({super.key, this.noteId});

  @override
  State<ChecklistEditorScreen> createState() => _ChecklistEditorScreenState();
}

class _ChecklistEditorScreenState extends State<ChecklistEditorScreen> {
  late TextEditingController _titleController;
  final TextEditingController _newItemController = TextEditingController();
  Note? _note;
  int _colorValue = 0xFFFFFFFF;
  bool _pinned = false;
  List<ChecklistItem> _items = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.noteId != null) {
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);
        _note = noteProvider.allNotes.firstWhere((n) => n.id == widget.noteId);
        setState(() {
          _titleController.text = _note!.title;
          _colorValue = _note!.colorValue;
          _pinned = _note!.pinned;
          _items = List.from(_note!.checklistItems);
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    
    if (_titleController.text.isEmpty && _items.isEmpty) {
      Navigator.pop(context);
      return;
    }

    if (_note == null) {
      final newNote = Note(
        id: noteProvider.generateId(),
        title: _titleController.text,
        type: NoteType.checklist,
        colorValue: _colorValue,
        pinned: _pinned,
        checklistItems: _items,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      noteProvider.addNote(newNote);
    } else {
      _note!.title = _titleController.text;
      _note!.colorValue = _colorValue;
      _note!.pinned = _pinned;
      _note!.checklistItems = _items;
      noteProvider.updateNote(_note!);
    }
    Navigator.pop(context);
  }

  void _addItem() {
    if (_newItemController.text.isNotEmpty) {
      setState(() {
        _items.add(ChecklistItem(text: _newItemController.text));
        _newItemController.clear();
      });
    }
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
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    leading: Checkbox(
                      value: item.isCompleted,
                      onChanged: (val) {
                        setState(() {
                          item.isCompleted = val ?? false;
                        });
                      },
                    ),
                    title: Text(
                      item.text,
                      style: TextStyle(
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _items.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    decoration: const InputDecoration(
                      hintText: 'Add an item...',
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
