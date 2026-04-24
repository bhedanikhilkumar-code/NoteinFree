import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
        (item) => item.text.toLowerCase().contains(query),
      );

      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          checklistMatch;
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
    _notes.insert(0, note);
    await _saveNotes();
  }

  Future<void> updateNote(Note note) async {
    final int index = _notes.indexWhere((Note item) => item.id == note.id);
    if (index != -1) {
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
}
