import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteStyle {
  static const List<int> palette = [
    0xFFFFF8E7,
    0xFFFDECEC,
    0xFFF5F0FF,
    0xFFEFF7FF,
    0xFFEAFBF3,
    0xFFFFF2D9,
    0xFFF3F4F6,
    0xFF1F2430,
  ];

  static Color foregroundFor(Color background) {
    final Brightness brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : const Color(0xFF171717);
  }

  static String reminderLabel(DateTime reminderAt) {
    final DateTime now = DateTime.now();
    final DateFormat timeFormat = DateFormat('dd MMM · hh:mm a');
    final DateFormat dateFormat = DateFormat('dd MMM');

    if (now.year == reminderAt.year &&
        now.month == reminderAt.month &&
        now.day == reminderAt.day) {
      return 'Today · ${DateFormat('hh:mm a').format(reminderAt)}';
    }

    if (now.add(const Duration(days: 1)).year == reminderAt.year &&
        now.add(const Duration(days: 1)).month == reminderAt.month &&
        now.add(const Duration(days: 1)).day == reminderAt.day) {
      return 'Tomorrow · ${DateFormat('hh:mm a').format(reminderAt)}';
    }

    if (now.year == reminderAt.year) {
      return '${dateFormat.format(reminderAt)} · ${DateFormat('hh:mm a').format(reminderAt)}';
    }

    return timeFormat.format(reminderAt);
  }
}
