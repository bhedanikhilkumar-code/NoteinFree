import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/checklist_item.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
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
    final Color background = Color(note.backgroundColorValue);
    final Color foreground = NoteStyle.foregroundFor(background);
    final List<String> tags = note.allTags;

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
                  if (note.labelValue > 0)
                    Container(
                      width: 5,
                      height: 26,
                      margin: const EdgeInsets.only(right: 10, top: 2),
                      decoration: BoxDecoration(
                        color: NoteStyle.getLabelColor(note.labelValue),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  Expanded(
                    child: note.title.trim().isEmpty
                        ? Text(
                            note.type == NoteType.checklist ? 'Checklist' : 'Untitled note',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: foreground.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                  const SizedBox(width: 6),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 32,
                        width: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          splashRadius: 18,
                          tooltip: note.pinned ? 'Unpin note' : 'Pin note',
                          onPressed: () {
                            context.read<NoteProvider>().togglePin(note.id);
                          },
                          icon: Icon(
                            note.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                            size: 18,
                            color: note.pinned
                                ? foreground.withOpacity(0.84)
                                : foreground.withOpacity(0.52),
                          ),
                        ),
                      ),
                      if (note.locked)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 15,
                            color: foreground.withOpacity(0.72),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildPreview(theme, foreground)),
              if (tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags.take(3).map((String tag) => _buildTagChip(tag, foreground)).toList(),
                ),
              ],
              if (note.reminderAt != null) ...<Widget>[
                const SizedBox(height: 12),
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

  Widget _buildTagChip(String tag, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: foreground.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          fontSize: 11,
          color: foreground.withOpacity(0.75),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme, Color foreground) {
    if (note.type == NoteType.checklist) {
      final List<Widget> previewItems = note.checklistItems.take(3).map<Widget>((ChecklistItem item) {
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
      maxLines: 7,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: foreground.withOpacity(0.86),
        height: 1.45,
      ),
    );
  }
}
