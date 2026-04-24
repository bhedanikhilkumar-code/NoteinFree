import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../utils/note_style.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background = Color(note.colorValue);
    final Color foreground = NoteStyle.foregroundFor(background);

    return Card(
      color: background,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: note.title.trim().isEmpty
                        ? Text(
                            note.type == NoteType.checklist ? 'Checklist' : 'Untitled note',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: foreground.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            note.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: <Widget>[
                      if (note.pinned)
                        Icon(Icons.push_pin_rounded, size: 18, color: foreground.withOpacity(0.78)),
                      if (note.locked)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Icon(Icons.lock_rounded, size: 16, color: foreground.withOpacity(0.7)),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildPreview(theme, foreground),
              ),
              if (note.reminderAt != null) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: foreground.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.alarm_rounded, size: 14, color: foreground.withOpacity(0.82)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          NoteStyle.reminderLabel(note.reminderAt!),
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: foreground.withOpacity(0.82),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Edited ${DateFormat('dd MMM · hh:mm a').format(note.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground.withOpacity(0.64),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme, Color foreground) {
    if (note.type == NoteType.checklist) {
      final List<Widget> previewItems = note.checklistItems.take(4).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                item.isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                size: 18,
                color: foreground.withOpacity(0.75),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground.withOpacity(0.88),
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: foreground.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();

      if (previewItems.isEmpty) {
        return Text(
          'No checklist items yet.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: foreground.withOpacity(0.68),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: previewItems,
      );
    }

    final String content = note.content.trim().isEmpty ? 'Start writing...' : note.content;
    return Text(
      content,
      maxLines: 8,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: foreground.withOpacity(0.86),
        height: 1.45,
      ),
    );
  }
}
