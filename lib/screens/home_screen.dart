import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/custom_route_transitions.dart';
import '../utils/staggered_animation.dart';
import '../widgets/note_card.dart';
import 'calendar_screen.dart';
import 'checklist_editor_screen.dart';
import 'note_collection_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'templates_screen.dart';
import 'text_editor_screen.dart';

enum HomeNoteFilter { all, pinned, reminders, checklists }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  HomeNoteFilter _activeFilter = HomeNoteFilter.all;
  String _activeTag = '';
  late final AnimationController _fabPulseController;
  late final AnimationController _fabTapController;

  @override
  void initState() {
    super.initState();
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _fabTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    _fabTapController.dispose();
    super.dispose();
  }

  Future<T?> _showAnimatedSheet<T>(Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _AnimatedSheetShell(child: child);
      },
    );
  }

  void _handleFabPress() {
    _fabTapController.forward(from: 0);
    Future<void>.delayed(const Duration(milliseconds: 70), () {
      if (mounted) {
        _showNewNoteOptions(context);
      }
    });
  }

  void _pushPage(Widget page) {
    Navigator.push(context, AnimatedPageRoute<void>(page: page));
  }

  void _showNewNoteOptions(BuildContext context) {
    _showAnimatedSheet<void>(
      SafeArea(
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
                  _pushPage(const TextEditorScreen());
                },
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.checklist_rounded)),
                title: const Text('Checklist'),
                subtitle: const Text('For groceries, tasks, and planning'),
                onTap: () {
                  Navigator.pop(context);
                  _pushPage(const ChecklistEditorScreen());
                },
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.auto_awesome)),
                title: const Text('From template'),
                subtitle: const Text('Use a pre-made template'),
                onTap: () async {
                  Navigator.pop(context);
                  final Note? template = await showModalBottomSheet<Note>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext ctx) {
                      return _AnimatedSheetShell(
                        child: const TemplatesScreen(),
                      );
                    },
                  );
                  if (template != null && mounted) {
                    if (template.type == NoteType.checklist) {
                      _pushPage(const ChecklistEditorScreen());
                    } else {
                      _pushPage(const TextEditorScreen());
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, String noteId) {
    final NoteProvider noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final Note? note = noteProvider.findById(noteId);
    if (note == null) {
      return;
    }

    _showAnimatedSheet<void>(
      SafeArea(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_fabPulseController, _fabTapController]),
        child: FloatingActionButton.extended(
          heroTag: 'home-new-note',
          onPressed: _handleFabPress,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New note'),
        ),
        builder: (BuildContext context, Widget? child) {
          final Animation<double> tapAnimation = TweenSequence<double>(
            <TweenSequenceItem<double>>[
              TweenSequenceItem<double>(tween: Tween<double>(begin: 1, end: 0.96), weight: 30),
              TweenSequenceItem<double>(tween: Tween<double>(begin: 0.96, end: 1.05), weight: 35),
              TweenSequenceItem<double>(tween: Tween<double>(begin: 1.05, end: 1), weight: 35),
            ],
          ).animate(CurvedAnimation(parent: _fabTapController, curve: Curves.easeOutCubic));
          final double idleScale = 0.985 + (_fabPulseController.value * 0.03);
          return Transform.scale(
            scale: idleScale * tapAnimation.value,
            child: child,
          );
        },
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
            final List<String> allTags = noteProvider.getAllTags();
            if (_activeTag.isNotEmpty && !allTags.contains(_activeTag)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _activeTag = '';
                  });
                }
              });
            }

            final List<Note> visibleAllNotes = _applyTagFilter(baseNotes);
            final List<Note> filteredNotes = _applyTagFilter(_filteredNotes(baseNotes));
            final String noteCountLabel = _activeTag.isEmpty
                ? '${baseNotes.length} notes'
                : '${visibleAllNotes.length} of ${baseNotes.length} notes';

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
                      noteCountLabel,
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
                if (allTags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  _buildTagFilterRow(theme, allTags),
                ],
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _sectionTitle(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
                  _buildAllSections(theme, visibleAllNotes)
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
      onTap: () => _pushPage(const SearchScreen()),
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.10)),
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
            onTap: () => _pushPage(const CalendarScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.archive_outlined,
            label: 'Archive',
            onTap: () => _pushPage(const NoteCollectionScreen(type: NoteCollectionType.archived)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.delete_outline_rounded,
            label: 'Trash',
            onTap: () => _pushPage(const NoteCollectionScreen(type: NoteCollectionType.trash)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => _pushPage(const SettingsScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.bar_chart_rounded,
            label: 'Stats',
            onTap: () {
              final NoteProvider provider = Provider.of<NoteProvider>(context, listen: false);
              final stats = NoteStatistics.fromNotes(provider.allNotes);
              Navigator.push(
                context,
                AnimatedPageRoute<void>(
                  page: StatisticsScreen(stats: stats),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.auto_awesome,
            label: 'Templates',
            onTap: () {
              Navigator.push(
                context,
                AnimatedPageRoute<void>(page: const TemplatesScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagFilterRow(ThemeData theme, List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        ChoiceChip(
          selected: _activeTag.isEmpty,
          label: const Text('All tags'),
          onSelected: (_) {
            setState(() {
              _activeTag = '';
            });
          },
        ),
        ...tags.map((String tag) {
          return ChoiceChip(
            selected: _activeTag == tag,
            avatar: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
            label: Text('#$tag'),
            onSelected: (_) {
              setState(() {
                _activeTag = _activeTag == tag ? '' : tag;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildAllSections(ThemeData theme, List<Note> notes) {
    if (notes.isEmpty) {
      return _buildFilteredEmptyState(theme);
    }

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

    return StaggeredGridAnimation(
      itemCount: notes.length,
      crossAxisCount: columns,
      mainAxisExtent: 252,
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
              onPressed: _handleFabPress,
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
              _activeTag.isEmpty ? 'No notes match this view yet.' : 'No notes match this tag yet.',
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
        AnimatedPageRoute<void>(page: ChecklistEditorScreen(noteId: note.id)),
      );
      return;
    }

    Navigator.push(
      context,
      AnimatedPageRoute<void>(page: TextEditorScreen(noteId: note.id)),
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

  List<Note> _applyTagFilter(List<Note> notes) {
    if (_activeTag.isEmpty) {
      return notes;
    }

    return notes.where((Note note) => note.allTags.contains(_activeTag)).toList();
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
        return _activeTag.isEmpty ? 'Your notes' : 'Filtered notes';
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
          color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.04) : Colors.white,
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

class _AnimatedSheetShell extends StatelessWidget {
  final Widget child;

  const _AnimatedSheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (BuildContext context, double value, Widget? _) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 50),
            child: Transform.scale(
              scale: 0.96 + (0.04 * value),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Material(
                    color: theme.bottomSheetTheme.backgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28), bottom: Radius.circular(28)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
