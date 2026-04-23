import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class NoteProvider with ChangeNotifier {
  final StorageService _storageService;
  List<Note> _notes = [];
  String _searchQuery = '';
  
  NoteProvider(this._storageService) {
    _loadNotes();
  }

  List<Note> get allNotes => _notes.where((n) => !n.deleted && !n.archived).toList();
  List<Note> get pinnedNotes => allNotes.where((n) => n.pinned).toList();
  List<Note> get unpinnedNotes => allNotes.where((n) => !n.pinned).toList();
  List<Note> get archivedNotes => _notes.where((n) => n.archived && !n.deleted).toList();
  List<Note> get deletedNotes => _notes.where((n) => n.deleted).toList();
  List<Note> get reminderNotes => allNotes.where((n) => n.reminderAt != null).toList();

  List<Note> get searchedNotes {
    if (_searchQuery.isEmpty) return allNotes;
    final query = _searchQuery.toLowerCase();
    return allNotes.where((n) {
      return n.title.toLowerCase().contains(query) || 
             n.content.toLowerCase().contains(query);
    }).toList();
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
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _notes[index].updatedAt = DateTime.now();
      await _saveNotes();
    }
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].pinned = !_notes[index].pinned;
      await _saveNotes();
    }
  }

  Future<void> moveToTrash(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].deleted = true;
      await _saveNotes();
    }
  }

  Future<void> restoreNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].deleted = false;
      await _saveNotes();
    }
  }

  Future<void> deletePermanently(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
  }

  Future<void> toggleArchive(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].archived = !_notes[index].archived;
      await _saveNotes();
    }
  }

  String generateId() {
    return const Uuid().v4();
  }
}
