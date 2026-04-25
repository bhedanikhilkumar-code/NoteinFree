import 'package:flutter/material.dart';

import '../utils/note_style.dart';

class NoteMetadataToolbar extends StatelessWidget {
  final Color foreground;
  final int selectedColorValue;
  final int selectedLabelValue;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<int> onLabelChanged;
  final TextEditingController tagController;
  final ValueChanged<String> onTagChanged;
  final VoidCallback onAddTag;
  final List<String> tags;
  final ValueChanged<String> onRemoveTag;

  const NoteMetadataToolbar({
    super.key,
    required this.foreground,
    required this.selectedColorValue,
    required this.selectedLabelValue,
    required this.onColorChanged,
    required this.onLabelChanged,
    required this.tagController,
    required this.onTagChanged,
    required this.onAddTag,
    required this.tags,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: foreground.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionLabel(text: 'Background color', foreground: foreground),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NoteStyle.palette.map((int colorValue) {
              final bool selected = selectedColorValue == colorValue;
              return _SelectionDot(
                color: Color(colorValue),
                isSelected: selected,
                outlineColor: foreground,
                onTap: () => onColorChanged(colorValue),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _SectionLabel(text: 'Label accent', foreground: foreground),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ChoiceChip(
                selected: selectedLabelValue == 0,
                label: const Text('None'),
                onSelected: (_) => onLabelChanged(0),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: foreground.withOpacity(selectedLabelValue == 0 ? 1 : 0.74),
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: foreground.withOpacity(0.05),
                selectedColor: foreground.withOpacity(0.16),
                side: BorderSide.none,
              ),
              ...List<Widget>.generate(NoteStyle.labelColors.length, (int index) {
                final int labelValue = index + 1;
                return Tooltip(
                  message: NoteStyle.getLabelColorName(labelValue),
                  child: _SelectionDot(
                    color: NoteStyle.getLabelColor(labelValue),
                    isSelected: selectedLabelValue == labelValue,
                    outlineColor: foreground,
                    onTap: () => onLabelChanged(labelValue),
                    size: 28,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 14),
          _SectionLabel(text: 'Tags', foreground: foreground),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: tagController,
                  onChanged: onTagChanged,
                  onSubmitted: (_) => onAddTag(),
                  decoration: InputDecoration(
                    hintText: 'Add tag and press comma or enter',
                    filled: true,
                    fillColor: foreground.withOpacity(0.06),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintStyle: TextStyle(color: foreground.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onAddTag,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  foregroundColor: foreground,
                  backgroundColor: foreground.withOpacity(0.12),
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((String tag) {
                return InputChip(
                  label: Text('#$tag'),
                  onDeleted: () => onRemoveTag(tag),
                  deleteIconColor: foreground.withOpacity(0.7),
                  backgroundColor: foreground.withOpacity(0.08),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: foreground.withOpacity(0.82),
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color foreground;

  const _SectionLabel({required this.text, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: foreground.withOpacity(0.78),
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final Color outlineColor;
  final VoidCallback onTap;
  final double size;

  const _SelectionDot({
    required this.color,
    required this.isSelected,
    required this.outlineColor,
    required this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? outlineColor : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: outlineColor.withOpacity(0.18),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                size: size * 0.58,
                color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF171717),
              )
            : null,
      ),
    );
  }
}
