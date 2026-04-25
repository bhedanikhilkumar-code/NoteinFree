import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../services/export_service.dart';
import '../services/voice_service.dart';
import '../utils/note_style.dart';
import '../widgets/note_metadata_toolbar.dart';

class TextEditorScreen extends StatefulWidget {
  final String? noteId;

  const TextEditorScreen({super.key, this.noteId});

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagController;
  late final ScrollController _scrollController;
  final VoiceService _voiceService = VoiceService();
  Note? _note;
  int _backgroundColorValue = NoteStyle.defaultBackgroundColor;
  int _labelValue = 0;
  bool _pinned = false;
  bool _isListening = false;
  DateTime? _reminderAt;
  List<String> _tags = <String>[];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _tagController = TextEditingController();
    _scrollController = ScrollController();
    _initVoice();

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
        _backgroundColorValue = note.backgroundColorValue;
        _labelValue = note.labelValue;
        _pinned = note.pinned;
        _reminderAt = note.reminderAt;
        _tags = note.allTags;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCursor() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _persistNote({bool popAfterSave = false}) async {
    final NoteProvider noteProvider = Provider.of<NoteProvider>(context, listen: false);
    _commitPendingTags();
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (popAfterSave && mounted) {
        Navigator.pop(context);
      }
      return;
    }

    final List<String> tags = List<String>.from(_tags);
    if (_note == null) {
      final Note newNote = Note(
        id: noteProvider.generateId(),
        title: title,
        content: content,
        type: NoteType.text,
        backgroundColorValue: _backgroundColorValue,
        labelValue: _labelValue,
        pinned: _pinned,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reminderAt: _reminderAt,
        tag: tags.isEmpty ? '' : tags.first,
        tags: tags,
      );
      await noteProvider.addNote(newNote);
      _note = newNote;
    } else {
      _note!
        ..title = title
        ..content = content
        ..backgroundColorValue = _backgroundColorValue
        ..labelValue = _labelValue
        ..pinned = _pinned
        ..reminderAt = _reminderAt
        ..tag = tags.isEmpty ? '' : tags.first
        ..tags = tags;
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
                final bool selected = _backgroundColorValue == colorValue;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _backgroundColorValue = colorValue;
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

  void _onTagChanged(String value) {
    if (!value.contains(',')) {
      return;
    }

    final List<String> parts = value.split(',');
    for (int i = 0; i < parts.length - 1; i++) {
      _addTag(parts[i]);
    }

    final String remainder = parts.last.trimLeft();
    _tagController.value = TextEditingValue(
      text: remainder,
      selection: TextSelection.collapsed(offset: remainder.length),
    );
  }

  void _commitPendingTags() {
    _addTag(_tagController.text);
  }

  void _addTag([String? rawValue, bool clearField = true]) {
    final String source = rawValue ?? _tagController.text;
    final List<String> incomingTags = source
        .split(RegExp(r'[\n,]'))
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList();

    if (incomingTags.isEmpty) {
      if (clearField) {
        _tagController.clear();
      }
      return;
    }

    setState(() {
      for (final String tag in incomingTags) {
        final bool exists = _tags.any(
          (String existing) => existing.toLowerCase() == tag.toLowerCase(),
        );
        if (!exists) {
          _tags.add(tag);
        }
      }
      _tags.sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
    });

    if (clearField) {
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.removeWhere((String existing) => existing.toLowerCase() == tag.toLowerCase());
    });
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
  }

  void _toggleVoiceInput() {
    if (_isListening) {
      _voiceService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      _voiceService.startListening(
        onResult: (String text) {
          final String current = _contentController.text;
          final String newText = current.isEmpty ? text : '$current $text';
          _contentController.text = newText;
          _contentController.selection = TextSelection.collapsed(offset: newText.length);
          setState(() {
            _isListening = false;
          });
        },
        onPartial: (String text) {
          // Partial results can be shown live if needed
        },
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  Future<void> _exportNote() async {
    if (_note == null) {
      await _persistNote();
      return;
    }

    final String? action = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export as PDF'),
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: const Text('Export as TXT'),
                onTap: () => Navigator.pop(context, 'txt'),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share note'),
                onTap: () => Navigator.pop(context, 'share'),
              ),
            ],
          ),
        );
      },
    );

    if (action == null || _note == null) return;


    try {
      if (action == 'pdf') {
        final String path = await ExportService.exportNoteAsPdf(_note!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: $path')),
        );
      } else if (action == 'txt') {
        final String path = await ExportService.exportNoteAsTxt(_note!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: $path')),
        );
      } else if (action == 'share') {
        await ExportService.shareNote(_note!);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background = Color(_backgroundColorValue);
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
                  IconButton(
                    tooltip: 'Voice input',
                    onPressed: _toggleVoiceInput,
                    icon: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _isListening ? Colors.red : foreground,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Export / Share',
                    onPressed: _exportNote,
                    icon: const Icon(Icons.ios_share),
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
              NoteMetadataToolbar(
                foreground: foreground,
                selectedColorValue: _backgroundColorValue,
                selectedLabelValue: _labelValue,
                onColorChanged: (int colorValue) {
                  setState(() {
                    _backgroundColorValue = colorValue;
                  });
                },
                onLabelChanged: (int labelValue) {
                  setState(() {
                    _labelValue = labelValue;
                  });
                },
                tagController: _tagController,
                onTagChanged: _onTagChanged,
                onAddTag: _commitPendingTags,
                tags: _tags,
                onRemoveTag: _removeTag,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Note title...',
                  filled: false,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: foreground.withOpacity(0.35)),
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: null,
                onChanged: (_) => _scrollToCursor(),
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Start typing your thoughts here...',
                    filled: false,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: foreground.withOpacity(0.35)),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: foreground.withOpacity(0.92),
                    height: 1.5,
                  ),
                  maxLines: null,
                  onChanged: (_) => _scrollToCursor(),
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
