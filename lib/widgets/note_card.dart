import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

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
    return Card(
      color: Color(note.colorValue),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              if (note.type == NoteType.text || note.type == NoteType.sticky)
                Text(
                  note.content.isNotEmpty ? note.content : 'Empty note',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                )
              else if (note.type == NoteType.checklist)
                ...note.checklistItems.take(5).map((item) => Row(
                  children: [
                    Icon(
                      item.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                )),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd().format(note.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  Row(
                    children: [
                      if (note.locked) const Icon(Icons.lock, size: 16),
                      if (note.pinned) const Icon(Icons.push_pin, size: 16),
                      if (note.reminderAt != null) const Icon(Icons.alarm, size: 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
