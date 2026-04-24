import 'package:flutter/material.dart';

@immutable
class FontOption {
  final String id;
  final String label;
  final String? fontFamily;
  final String preview;

  const FontOption({
    required this.id,
    required this.label,
    required this.preview,
    this.fontFamily,
  });
}

class AppFonts {
  static const String system = 'system';
  static const String sans = 'sans';
  static const String serif = 'serif';
  static const String mono = 'mono';

  static const List<FontOption> options = [
    FontOption(
      id: system,
      label: 'System Default',
      preview: 'Balanced and clean',
      fontFamily: null,
    ),
    FontOption(
      id: sans,
      label: 'Modern Sans',
      preview: 'Smooth and minimal',
      fontFamily: 'sans-serif',
    ),
    FontOption(
      id: serif,
      label: 'Classic Serif',
      preview: 'Great for longer writing',
      fontFamily: 'serif',
    ),
    FontOption(
      id: mono,
      label: 'Focus Mono',
      preview: 'Structured and technical',
      fontFamily: 'monospace',
    ),
  ];

  static FontOption byId(String id) {
    return options.firstWhere(
      (option) => option.id == id,
      orElse: () => options.first,
    );
  }
}
