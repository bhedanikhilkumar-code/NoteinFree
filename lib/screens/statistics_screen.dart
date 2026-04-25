import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteStatistics {
  final int totalNotes;
  final int totalChecklists;
  final int pinnedCount;
  final int archivedCount;
  final int deletedCount;
  final int withReminders;
  final int withLabels;
  final int withTags;
  final List<String> allTags;
  final int notesThisWeek;
  final int notesThisMonth;
  final DateTime? oldestNote;
  final DateTime? newestNote;

  const NoteStatistics({
    required this.totalNotes,
    required this.totalChecklists,
    required this.pinnedCount,
    required this.archivedCount,
    required this.deletedCount,
    required this.withReminders,
    required this.withLabels,
    required this.withTags,
    required this.allTags,
    required this.notesThisWeek,
    required this.notesThisMonth,
    this.oldestNote,
    this.newestNote,
  });

  factory NoteStatistics.fromNotes(List<Note> allNotes) {
    final DateTime now = DateTime.now();
    final DateTime weekStart = now.subtract(const Duration(days: 7));
    final DateTime monthStart = now.subtract(const Duration(days: 30));

    int pinned = 0;
    int archived = 0;
    int deleted = 0;
    int withReminders = 0;
    int withLabels = 0;
    int withTags = 0;
    int checklists = 0;
    int thisWeek = 0;
    int thisMonth = 0;
    DateTime? oldest;
    DateTime? newest;
    final Set<String> tags = <String>{};

    for (final Note note in allNotes) {
      if (note.pinned) pinned++;
      if (note.archived) archived++;
      if (note.deleted) deleted++;
      if (note.reminderAt != null) withReminders++;
      if (note.labelValue > 0) withLabels++;
      if (note.allTags.isNotEmpty) {
        withTags++;
        tags.addAll(note.allTags);
      }
      if (note.type == NoteType.checklist) checklists++;

      if (!note.deleted && !note.archived) {
        if (note.createdAt.isAfter(weekStart)) thisWeek++;
        if (note.createdAt.isAfter(monthStart)) thisMonth++;

        if (oldest == null || note.createdAt.isBefore(oldest)) {
          oldest = note.createdAt;
        }
        if (newest == null || note.createdAt.isAfter(newest)) {
          newest = note.createdAt;
        }
      }
    }

    final List<String> sortedTags = tags.toList();
    sortedTags.sort();

    return NoteStatistics(
      totalNotes: allNotes.where((Note n) => !n.deleted && !n.archived).length,
      totalChecklists: checklists,
      pinnedCount: pinned,
      archivedCount: archived,
      deletedCount: deleted,
      withReminders: withReminders,
      withLabels: withLabels,
      withTags: withTags,
      allTags: sortedTags,
      notesThisWeek: thisWeek,
      notesThisMonth: thisMonth,
      oldestNote: oldest,
      newestNote: newest,
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  final NoteStatistics stats;

  const StatisticsScreen({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Note Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _buildStatCard(
            context,
            icon: Icons.note_outlined,
            title: 'Total Notes',
            value: stats.totalNotes.toString(),
            subtitle: '${stats.totalChecklists} checklists',
            color: theme.colorScheme.primary,
          ),
          _buildStatCard(
            context,
            icon: Icons.push_pin_outlined,
            title: 'Pinned Notes',
            value: stats.pinnedCount.toString(),
            subtitle: 'Currently pinned',
            color: Colors.amber,
          ),
          _buildStatCard(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Reminders',
            value: stats.withReminders.toString(),
            subtitle: 'Notes with reminders',
            color: Colors.orange,
          ),
          _buildStatCard(
            context,
            icon: Icons.label_outline_rounded,
            title: 'Labeled Notes',
            value: stats.withLabels.toString(),
            subtitle: 'Notes with color labels',
            color: Colors.purple,
          ),
          if (stats.allTags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.tag, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'Tags (${stats.allTags.length})',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: stats.allTags.map((String tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: theme.colorScheme.surfaceVariant,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildStatCard(
            context,
            icon: Icons.looks_one_outlined,
            title: 'This Week',
            value: stats.notesThisWeek.toString(),
            subtitle: 'Notes created this week',
            color: Colors.green,
          ),
          _buildStatCard(
            context,
            icon: Icons.calendar_month_outlined,
            title: 'This Month',
            value: stats.notesThisMonth.toString(),
            subtitle: 'Notes created this month',
            color: Colors.blue,
          ),
          if (stats.oldestNote != null) ...<Widget>[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Timeline',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text('Oldest note: ${_formatDate(stats.oldestNote!)}'),
                    if (stats.newestNote != null)
                      Text('Newest note: ${_formatDate(stats.newestNote!)}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}