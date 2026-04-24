import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../utils/note_style.dart';

class TextEditorScreen extends StatefulWidget {
  final String? noteId;

  const TextEditorScreen({super.key, this.noteId});

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  Note? _note;
  int _colorValue = NoteStyle.palette.first;
  bool _pinned = false;
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.noteId == null) {
        return;
      }

      final NoteProvider noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final Note? note = noteProvider.findById(widget.noteId!);
      if (note == null) {
        return;
      }

      setState(() {
        _note = note;
        _titleController.text = note.title;
        _contentController.text = note.content;
        _colorValue = note.colorValue;
        _pinned = note.pinned;
        _reminderAt = note.reminderAt;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _persistNote({bool popAfterSave = false}) async {
    final NoteProvider noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (popAfterSave && mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (_note == null) {
      final Note newNote = Note(
        id: noteProvider.generateId(),
        title: title,
        content: content,
        type: NoteType.text,
        colorValue: _colorValue,
        pinned: _pinned,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reminderAt: _reminderAt,
      );
      await noteProvider.addNote(newNote);
      _note = newNote;
    } else {
      _note!
        ..title = title
        ..content = content
        ..colorValue = _colorValue
        ..pinned = _pinned
        ..reminderAt = _reminderAt;
      await noteProvider.updateNote(_note!);
    }

    if (popAfterSave && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickReminder() async {
    final DateTime initialDate = _reminderAt ?? DateTime.now().add(const Duration(hours: 1));
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    final TimeOfDay initialTime = _reminderAt == null
        ? TimeOfDay.fromDateTime(initialDate)
        : TimeOfDay.fromDateTime(_reminderAt!);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _reminderAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _showColorPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: NoteStyle.palette.map((int colorValue) {
                final bool selected = _colorValue == colorValue;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _colorValue = colorValue;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: selected ? const Icon(Icons.check_rounded) : null,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background = Color(_colorValue);
    final Color foreground = NoteStyle.foregroundFor(background);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        await _persistNote();
        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            IconButton(
              tooltip: _pinned ? 'Unpin note' : 'Pin note',
              icon: Icon(_pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined),
              onPressed: () {
                setState(() {
                  _pinned = !_pinned;
                });
              },
            ),
            IconButton(
              tooltip: 'Save note',
              icon: const Icon(Icons.check_rounded),
              onPressed: () => _persistNote(popAfterSave: true),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: foreground.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    tooltip: 'Change note color',
                    onPressed: _showColorPicker,
                    icon: const Icon(Icons.palette_outlined),
                    color: foreground,
                  ),
                  IconButton(
                    tooltip: _reminderAt == null ? 'Add reminder' : 'Edit reminder',
                    onPressed: _pickReminder,
                    icon: const Icon(Icons.alarm_rounded),
                    color: foreground,
                  ),
                  if (_reminderAt != null)
                    IconButton(
                      tooltip: 'Clear reminder',
                      onPressed: () {
                        setState(() {
                          _reminderAt = null;
                        });
                      },
                      icon: const Icon(Icons.alarm_off_rounded),
                      color: foreground,
                    ),
                  const Spacer(),
                  Text(
                    _note == null
                        ? 'Draft'
                        : 'Edited ${DateFormat('dd MMM · hh:mm a').format(_note!.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foreground.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_reminderAt != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: foreground.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.alarm_rounded, size: 16, color: foreground),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          NoteStyle.reminderLabel(_reminderAt!),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Title',
                  filled: false,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: foreground.withOpacity(0.50)),
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: null,
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Write your note…',
                    filled: false,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: foreground.withOpacity(0.50)),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: foreground.withOpacity(0.92),
                    height: 1.5,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
