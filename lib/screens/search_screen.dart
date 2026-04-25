import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/checklist_item.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../utils/custom_route_transitions.dart';
import '../utils/note_style.dart';
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
    final String query = _searchController.text.trim();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search title, content, tags, or checklist items',
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: (String value) {
            setState(() {});
            Provider.of<NoteProvider>(context, listen: false).setSearchQuery(value);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () {
              _searchController.clear();
              setState(() {});
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
                      query.isEmpty ? 'Start typing to search your notes.' : 'No matching notes found.',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: ListView.builder(
              key: ValueKey<String>(query),
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                final Note note = notes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SearchResultCard(
                    note: note,
                    query: query,
                    onTap: () {
                      if (note.type == NoteType.checklist) {
                        Navigator.push(
                          context,
                          AnimatedPageRoute<void>(page: ChecklistEditorScreen(noteId: note.id)),
                        );
                      } else {
                        Navigator.push(
                          context,
                          AnimatedPageRoute<void>(page: TextEditorScreen(noteId: note.id)),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Note note;
  final String query;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.note,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background = Color(note.backgroundColorValue);
    final Color foreground = NoteStyle.foregroundFor(background);
    final String contentSnippet = _contentContext(note, query);
    final List<String> tags = note.allTags;

    return Card(
      color: background,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (note.labelValue > 0)
                    Container(
                      width: 5,
                      height: 24,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: NoteStyle.getLabelColor(note.labelValue),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  Expanded(
                    child: _HighlightedText(
                      text: note.title.trim().isEmpty
                          ? (note.type == NoteType.checklist ? 'Checklist' : 'Untitled note')
                          : note.title,
                      query: query,
                      baseStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                      highlightColor: theme.colorScheme.primary.withOpacity(0.28),
                      foregroundColor: foreground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    note.type == NoteType.checklist ? Icons.checklist_rounded : Icons.notes_rounded,
                    size: 18,
                    color: foreground.withOpacity(0.72),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (contentSnippet.isNotEmpty)
                _HighlightedText(
                  text: contentSnippet,
                  query: query,
                  baseStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground.withOpacity(0.88),
                    height: 1.45,
                  ),
                  highlightColor: foreground.withOpacity(0.15),
                  foregroundColor: foreground.withOpacity(0.9),
                )
              else
                Text(
                  note.type == NoteType.checklist
                      ? 'Checklist matches found in tasks.'
                      : 'No content preview available.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground.withOpacity(0.72),
                  ),
                ),
              if (tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((String tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: foreground.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: _HighlightedText(
                        text: '#$tag',
                        query: query,
                        baseStyle: theme.textTheme.labelMedium?.copyWith(
                          color: foreground.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                        highlightColor: theme.colorScheme.primary.withOpacity(0.24),
                        foregroundColor: foreground.withOpacity(0.84),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  if (note.reminderAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: foreground.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.alarm_rounded, size: 14, color: foreground.withOpacity(0.82)),
                          const SizedBox(width: 6),
                          Text(
                            NoteStyle.reminderLabel(note.reminderAt!),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: foreground.withOpacity(0.82),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    DateFormat('dd MMM · hh:mm a').format(note.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foreground.withOpacity(0.64),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _contentContext(Note note, String query) {
    if (query.trim().isEmpty) {
      return note.type == NoteType.checklist
          ? note.checklistItems.map((ChecklistItem item) => item.text).join(' • ')
          : note.content;
    }

    final String source = note.type == NoteType.checklist
        ? note.checklistItems.map((ChecklistItem item) => item.text).join(' • ')
        : note.content;
    final String trimmed = source.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final String lowerSource = trimmed.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    final int matchIndex = lowerSource.indexOf(lowerQuery);
    if (matchIndex == -1) {
      return trimmed.length > 120 ? '${trimmed.substring(0, 120)}…' : trimmed;
    }

    final int start = (matchIndex - 36).clamp(0, trimmed.length);
    final int end = (matchIndex + lowerQuery.length + 52).clamp(0, trimmed.length);
    final String prefix = start > 0 ? '…' : '';
    final String suffix = end < trimmed.length ? '…' : '';
    return '$prefix${trimmed.substring(start, end)}$suffix';
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? baseStyle;
  final Color highlightColor;
  final Color foregroundColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: _buildSpans(),
        style: baseStyle,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<InlineSpan> _buildSpans() {
    if (query.trim().isEmpty) {
      return <InlineSpan>[TextSpan(text: text, style: baseStyle)];
    }

    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    final List<InlineSpan> spans = <InlineSpan>[];
    int start = 0;

    while (true) {
      final int matchIndex = lowerText.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }

      if (matchIndex > start) {
        spans.add(TextSpan(text: text.substring(start, matchIndex), style: baseStyle));
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: highlightColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              text.substring(matchIndex, matchIndex + lowerQuery.length),
              style: baseStyle?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
      start = matchIndex + lowerQuery.length;
    }

    return spans;
  }
}
