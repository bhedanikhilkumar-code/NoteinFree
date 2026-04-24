import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/note_card.dart';
import 'calendar_screen.dart';
import 'checklist_editor_screen.dart';
import 'note_collection_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'text_editor_screen.dart';

enum HomeNoteFilter { all, pinned, reminders, checklists }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeNoteFilter _activeFilter = HomeNoteFilter.all;

  void _showNewNoteOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.notes_rounded)),
                  title: const Text('Text note'),
                  subtitle: const Text('Clean writing flow for quick thoughts'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<TextEditorScreen>(
                        builder: (_) => const TextEditorScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.checklist_rounded)),
                  title: const Text('Checklist'),
                  subtitle: const Text('For groceries, tasks, and planning'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<ChecklistEditorScreen>(
                        builder: (_) => const ChecklistEditorScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoteOptions(BuildContext context, String noteId) {
    final NoteProvider noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final Note? note = noteProvider.findById(noteId);
    if (note == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(note.pinned ? Icons.push_pin_outlined : Icons.push_pin_rounded),
                title: Text(note.pinned ? 'Unpin note' : 'Pin note'),
                onTap: () async {
                  await noteProvider.togglePin(noteId);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: Icon(note.archived ? Icons.unarchive_outlined : Icons.archive_outlined),
                title: Text(note.archived ? 'Move back to notes' : 'Archive note'),
                onTap: () async {
                  await noteProvider.toggleArchive(noteId);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Move to trash'),
                onTap: () async {
                  await noteProvider.moveToTrash(noteId);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewNoteOptions(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New note'),
      ),
      body: SafeArea(
        child: Consumer2<NoteProvider, SettingsProvider>(
          builder: (
            BuildContext context,
            NoteProvider noteProvider,
            SettingsProvider settings,
            Widget? child,
          ) {
            final List<Note> baseNotes = _sortedByPreference(
              noteProvider.allNotes,
              settings.sortOrder,
            );
            final List<Note> filteredNotes = _filteredNotes(baseNotes);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Notein',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${baseNotes.length} notes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Keep the flow quick, clean, and distraction-light.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.68),
                  ),
                ),
                const SizedBox(height: 18),
                _buildSearchBar(context, theme),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HomeNoteFilter.values.map((HomeNoteFilter filter) {
                    final bool isSelected = _activeFilter == filter;
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(_filterLabel(filter)),
                      onSelected: (_) {
                        setState(() {
                          _activeFilter = filter;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Text(
                      _sectionTitle(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      settings.sortLabel(settings.sortOrder),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (baseNotes.isEmpty)
                  _buildEmptyState(theme)
                else if (_activeFilter == HomeNoteFilter.all)
                  _buildAllSections(theme, baseNotes)
                else if (filteredNotes.isEmpty)
                  _buildFilteredEmptyState(theme)
                else
                  _buildNoteGrid(filteredNotes),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<SearchScreen>(
            builder: (_) => const SearchScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.10),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search notes, tasks, or reminders',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.68),
                ),
              ),
            ),
            Icon(Icons.tune_rounded, color: theme.colorScheme.onSurface.withOpacity(0.48)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickActionCard(
            icon: Icons.calendar_month_rounded,
            label: 'Calendar',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<CalendarScreen>(
                builder: (_) => const CalendarScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.archive_outlined,
            label: 'Archive',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<NoteCollectionScreen>(
                builder: (_) => const NoteCollectionScreen(type: NoteCollectionType.archived),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.delete_outline_rounded,
            label: 'Trash',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<NoteCollectionScreen>(
                builder: (_) => const NoteCollectionScreen(type: NoteCollectionType.trash),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<SettingsScreen>(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllSections(ThemeData theme, List<Note> notes) {
    final List<Note> pinnedNotes = notes.where((Note note) => note.pinned).toList();
    final List<Note> regularNotes = notes.where((Note note) => !note.pinned).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (pinnedNotes.isNotEmpty) ...<Widget>[
          Text(
            'Pinned',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _buildNoteGrid(pinnedNotes),
          const SizedBox(height: 18),
        ],
        if (regularNotes.isNotEmpty) ...<Widget>[
          Text(
            pinnedNotes.isNotEmpty ? 'Others' : 'All notes',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _buildNoteGrid(regularNotes),
        ],
      ],
    );
  }

  Widget _buildNoteGrid(List<Note> notes) {
    final int columns = MediaQuery.of(context).size.width > 920
        ? 4
        : MediaQuery.of(context).size.width > 720
            ? 3
            : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 220,
      ),
      itemBuilder: (BuildContext context, int index) {
        final Note note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _openNote(context, note),
          onLongPress: () => _showNoteOptions(context, note.id),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(Icons.note_alt_outlined, size: 54, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Your note space is ready.',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Start with a quick thought, a checklist, or a reminder-driven note.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.68),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _showNewNoteOptions(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create first note'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Icon(Icons.filter_alt_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'No notes match this view yet.',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _openNote(BuildContext context, Note note) {
    if (note.type == NoteType.checklist) {
      Navigator.push(
        context,
        MaterialPageRoute<ChecklistEditorScreen>(
          builder: (_) => ChecklistEditorScreen(noteId: note.id),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<TextEditorScreen>(
        builder: (_) => TextEditorScreen(noteId: note.id),
      ),
    );
  }

  List<Note> _filteredNotes(List<Note> notes) {
    switch (_activeFilter) {
      case HomeNoteFilter.pinned:
        return notes.where((Note note) => note.pinned).toList();
      case HomeNoteFilter.reminders:
        return notes.where((Note note) => note.reminderAt != null).toList();
      case HomeNoteFilter.checklists:
        return notes.where((Note note) => note.type == NoteType.checklist).toList();
      case HomeNoteFilter.all:
      default:
        return notes;
    }
  }

  List<Note> _sortedByPreference(List<Note> notes, int sortOrder) {
    final List<Note> sorted = List<Note>.from(notes);
    sorted.sort((Note a, Note b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }

      switch (sortOrder) {
        case SettingsProvider.sortOldestFirst:
          return a.updatedAt.compareTo(b.updatedAt);
        case SettingsProvider.sortAlphabetical:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SettingsProvider.sortNewestFirst:
        default:
          return b.updatedAt.compareTo(a.updatedAt);
      }
    });
    return sorted;
  }

  String _filterLabel(HomeNoteFilter filter) {
    switch (filter) {
      case HomeNoteFilter.pinned:
        return 'Pinned';
      case HomeNoteFilter.reminders:
        return 'Reminders';
      case HomeNoteFilter.checklists:
        return 'Checklists';
      case HomeNoteFilter.all:
      default:
        return 'All';
    }
  }

  String _sectionTitle() {
    switch (_activeFilter) {
      case HomeNoteFilter.pinned:
        return 'Pinned notes';
      case HomeNoteFilter.reminders:
        return 'Reminder notes';
      case HomeNoteFilter.checklists:
        return 'Checklist notes';
      case HomeNoteFilter.all:
      default:
        return 'Your notes';
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
