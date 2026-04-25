import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/checklist_item.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NoteProvider with ChangeNotifier {
  final StorageService _storageService;
  List<Note> _notes = <Note>[];
  String _searchQuery = '';

  NoteProvider(this._storageService) {
    _loadNotes();
  }

  List<Note> get allNotes => _sorted(
        _notes.where((Note note) => !note.deleted && !note.archived).toList(),
      );

  List<Note> get pinnedNotes => allNotes.where((Note note) => note.pinned).toList();

  List<Note> get unpinnedNotes => allNotes.where((Note note) => !note.pinned).toList();

  List<Note> get archivedNotes => _sorted(
        _notes.where((Note note) => note.archived && !note.deleted).toList(),
      );

  List<Note> get deletedNotes => _sorted(
        _notes.where((Note note) => note.deleted).toList(),
      );

  List<Note> get reminderNotes => _sorted(
        allNotes.where((Note note) => note.reminderAt != null).toList(),
      );

  List<Note> get searchedNotes {
    if (_searchQuery.trim().isEmpty) {
      return allNotes;
    }

    final String query = _searchQuery.toLowerCase();
    return allNotes.where((Note note) {
      final bool checklistMatch = note.checklistItems.any(
        (ChecklistItem item) => item.text.toLowerCase().contains(query),
      );

      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          checklistMatch ||
          note.allTags.any((String tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  Note? findById(String id) {
    try {
      return _notes.firstWhere((Note note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  void _loadNotes() {
    _notes = _storageService.loadNotes();
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    await _storageService.saveNotes(_notes);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    note.tags = _normalizedTags(note.tags, note.tag);
    note.tag = note.tags.isEmpty ? '' : note.tags.first;
    _notes.insert(0, note);
    await _saveNotes();
  }

  Future<void> updateNote(Note note) async {
    final int index = _notes.indexWhere((Note item) => item.id == note.id);
    if (index != -1) {
      note.tags = _normalizedTags(note.tags, note.tag);
      note.tag = note.tags.isEmpty ? '' : note.tags.first;
      _notes[index] = note;
      _notes[index].updatedAt = DateTime.now();
      await _saveNotes();
    }
  }

  Future<void> togglePin(String id) async {
    final Note? note = findById(id);
    if (note == null) {
      return;
    }

    note.pinned = !note.pinned;
    note.updatedAt = DateTime.now();
    await _saveNotes();
  }

  Future<void> moveToTrash(String id) async {
    final Note? note = findById(id);
    if (note == null) {
      return;
    }

    note.deleted = true;
    note.archived = false;
    note.updatedAt = DateTime.now();
    await _saveNotes();
  }

  Future<void> restoreNote(String id) async {
    final Note? note = findById(id);
    if (note == null) {
      return;
    }

    note.deleted = false;
    note.updatedAt = DateTime.now();
    await _saveNotes();
  }

  Future<void> deletePermanently(String id) async {
    _notes.removeWhere((Note note) => note.id == id);
    await _saveNotes();
  }

  Future<void> toggleArchive(String id) async {
    final Note? note = findById(id);
    if (note == null) {
      return;
    }

    note.archived = !note.archived;
    note.deleted = false;
    note.updatedAt = DateTime.now();
    await _saveNotes();
  }

  List<Note> getNotesByLabel(int labelValue) {
    return allNotes.where((Note note) => note.labelValue == labelValue).toList();
  }

  Future<void> setLabelColor(String noteId, int labelValue) async {
    final Note? note = findById(noteId);
    if (note == null) {
      return;
    }

    note.labelValue = labelValue;
    note.updatedAt = DateTime.now();
    await _saveNotes();
  }

  List<Note> getNotesByTag(String tag) {
    final String query = tag.trim().toLowerCase();
    if (query.isEmpty) {
      return allNotes;
    }

    return allNotes.where((Note note) {
      return note.allTags.any((String value) => value.toLowerCase() == query);
    }).toList();
  }

  Future<void> addTag(String noteId, String tag) async {
    final Note? note = findById(noteId);
    final String cleanTag = tag.trim();
    if (note == null || cleanTag.isEmpty) {
      return;
    }

    final bool exists = note.allTags.any(
      (String value) => value.toLowerCase() == cleanTag.toLowerCase(),
    );
    if (!exists) {
      note.tags = <String>[...note.allTags, cleanTag];
      note.tag = note.tags.first;
      note.updatedAt = DateTime.now();
      await _saveNotes();
    }
  }

  Future<void> removeTag(String noteId, String tag) async {
    final Note? note = findById(noteId);
    if (note == null) {
      return;
    }

    note.tags = note.allTags
        .where((String value) => value.toLowerCase() != tag.trim().toLowerCase())
        .toList();
    note.tag = note.tags.isEmpty ? '' : note.tags.first;
    note.updatedAt = DateTime.now();
    await _saveNotes();
  }

  List<String> getAllTags() {
    final Set<String> uniqueTags = <String>{};
    for (final Note note in allNotes) {
      uniqueTags.addAll(note.allTags);
    }
    final List<String> tags = uniqueTags.toList();
    tags.sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return tags;
  }

  String generateId() => const Uuid().v4();

  List<Note> _sorted(List<Note> notes) {
    notes.sort((Note a, Note b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  List<String> _normalizedTags(List<String> tags, String legacyTag) {
    final Set<String> unique = <String>{};

    void addTag(String value) {
      final String cleanValue = value.trim();
      if (cleanValue.isNotEmpty) {
        unique.add(cleanValue);
      }
    }

    for (final String value in tags) {
      addTag(value);
    }
    addTag(legacyTag);

    final List<String> values = unique.toList();
    values.sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return values;
  }
}
