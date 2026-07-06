import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../database/database_helper.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  String _searchQuery = '';
  bool _isLoading = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Note> get notes {
    if (_searchQuery.isEmpty) {
      return List.unmodifiable(_notes);
    }
    return List.unmodifiable(
      _notes.where((note) =>
        note.content.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList(),
    );
  }

  List<Note> get allNotes => List.unmodifiable(_notes);
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _dbHelper.readAllNotes();
      _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint('Notes loaded from database: ${_notes.length}');
    } catch (e) {
      debugPrint('Error loading notes: $e');
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String content) async {
    if (content.trim().isEmpty) return;

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    try {
      final noteId = await _dbHelper.createNote(note);
      final savedNote = note.copyWith(id: noteId.toString());
      _notes.insert(0, savedNote);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  Future<void> updateNote(String id, String content) async {
    if (content.trim().isEmpty) return;

    final index = _notes.indexWhere((note) => note.id == id);
    if (index == -1) return;

    final oldNote = _notes[index];
    _notes[index] = oldNote.copyWith(
      content: content.trim(),
      updatedAt: DateTime.now(),
    );

    try {
      await _dbHelper.updateNote(_notes[index]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);

    try {
      await _dbHelper.deleteNote(int.parse(id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
