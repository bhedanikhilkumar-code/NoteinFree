import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteStyle {
  static const int defaultBackgroundColor = 0xFFEEEEEE;

  static const List<int> palette = <int>[
    0xFFFFCDD2,
    0xFFFFE0B2,
    0xFFFFF9C4,
    0xFFC8E6C9,
    0xFFBBDEFB,
    0xFFE1BEE7,
    0xFFF8BBD9,
    0xFFEEEEEE,
  ];

  static const List<int> labelColors = <int>[
    0xFFFFCDD2,
    0xFFFFE0B2,
    0xFFFFF9C4,
    0xFFC8E6C9,
    0xFFBBDEFB,
    0xFFE1BEE7,
    0xFFF8BBD9,
    0xFFEEEEEE,
  ];

  static const List<String> labelColorNames = <String>[
    'Red',
    'Orange',
    'Yellow',
    'Green',
    'Blue',
    'Purple',
    'Pink',
    'Gray',
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

    final DateTime tomorrow = now.add(const Duration(days: 1));
    if (tomorrow.year == reminderAt.year &&
        tomorrow.month == reminderAt.month &&
        tomorrow.day == reminderAt.day) {
      return 'Tomorrow · ${DateFormat('hh:mm a').format(reminderAt)}';
    }

    if (now.year == reminderAt.year) {
      return '${dateFormat.format(reminderAt)} · ${DateFormat('hh:mm a').format(reminderAt)}';
    }

    return timeFormat.format(reminderAt);
  }

  static String getLabelColorName(int labelValue) {
    if (labelValue <= 0 || labelValue > labelColorNames.length) {
      return '';
    }
    return labelColorNames[labelValue - 1];
  }

  static Color getLabelColor(int labelValue) {
    if (labelValue <= 0 || labelValue > labelColors.length) {
      return Colors.transparent;
    }
    return Color(labelColors[labelValue - 1]);
  }
}
