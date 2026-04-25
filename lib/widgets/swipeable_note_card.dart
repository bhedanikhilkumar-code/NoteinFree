import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/note_provider.dart';
import 'note_card.dart';

class SwipeableNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const SwipeableNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id),
      background: _buildBackground(context, Colors.blue.shade700, Icons.archive_outlined, 'Archive'),
      secondaryBackground: _buildBackground(context, Colors.red.shade600, Icons.delete_outline_rounded, 'Trash'),
      confirmDismiss: (DismissDirection direction) async {
        final NoteProvider provider = Provider.of<NoteProvider>(context, listen: false);
        if (direction == DismissDirection.endToStart) {
          await provider.moveToTrash(note.id);
        } else {
          await provider.toggleArchive(note.id);
        }
        return false;
      },
      child: NoteCard(
        note: note,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }


  Widget _buildBackground(BuildContext context, Color color, IconData icon, String label) {
    final bool isArchive = label == 'Archive';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: isArchive ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isArchive) ...<Widget>[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          if (!isArchive) ...<Widget>[
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white),
          ],
        ],
      ),
    );
  }
}