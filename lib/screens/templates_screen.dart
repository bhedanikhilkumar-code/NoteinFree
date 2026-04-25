import 'package:flutter/material.dart';

import '../models/checklist_item.dart';
import '../models/note.dart';

class NoteTemplate {
  final String name;
  final String icon;
  final int color;
  final String title;
  final String content;
  final NoteType type;
  final List<ChecklistItemTemplate>? checklistItems;

  const NoteTemplate({
    required this.name,
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
    required this.type,
    this.checklistItems,
  });
}

class ChecklistItemTemplate {
  final String text;
  final bool isChecked;

  const ChecklistItemTemplate({required this.text, this.isChecked = false});
}

final List<NoteTemplate> defaultTemplates = <NoteTemplate>[
  const NoteTemplate(
    name: 'Meeting Notes',
    icon: 'groups',
    color: 0xFF4285F4,
    title: 'Meeting - {date}',
    content: 'Agenda:\n1. \n2. \n3. \n\nAction Items:\n- \n\nDecisions:\n- ',
    type: NoteType.text,
  ),
  const NoteTemplate(
    name: 'Daily Journal',
    icon: 'auto_awesome',
    color: 0xFF9C27B0,
    title: 'Daily Journal - {date}',
    content: 'How was your day?\n\nHighlights:\n- \n\nChallenges:\n- \n\nGrateful for:\n- ',
    type: NoteType.text,
  ),
  const NoteTemplate(
    name: 'Shopping List',
    icon: 'shopping_cart',
    color: 0xFFFF5722,
    title: 'Shopping List',
    content: '',
    type: NoteType.checklist,
    checklistItems: <ChecklistItemTemplate>[
      ChecklistItemTemplate(text: 'Milk'),
      ChecklistItemTemplate(text: 'Bread'),
      ChecklistItemTemplate(text: 'Eggs'),
      ChecklistItemTemplate(text: 'Vegetables'),
    ],
  ),
  const NoteTemplate(
    name: 'Work Tasks',
    icon: 'work',
    color: 0xFF2196F3,
    title: 'Work Tasks - {date}',
    content: '',
    type: NoteType.checklist,
    checklistItems: <ChecklistItemTemplate>[
      ChecklistItemTemplate(text: 'Task 1'),
      ChecklistItemTemplate(text: 'Task 2'),
      ChecklistItemTemplate(text: 'Task 3'),
    ],
  ),
  const NoteTemplate(
    name: 'Recipe',
    icon: 'restaurant',
    color: 0xFFE91E63,
    title: 'Recipe: ',
    content: 'Ingredients:\n- \n- \n- \n\nInstructions:\n1. \n2. \n3. ',
    type: NoteType.text,
  ),
  const NoteTemplate(
    name: 'Travel Checklist',
    icon: 'flight',
    color: 0xFF009688,
    title: 'Packing List - {destination}',
    content: '',
    type: NoteType.checklist,
    checklistItems: <ChecklistItemTemplate>[
      ChecklistItemTemplate(text: 'Passport'),
      ChecklistItemTemplate(text: 'Tickets'),
      ChecklistItemTemplate(text: 'Phone charger'),
      ChecklistItemTemplate(text: 'Clothes'),
      ChecklistItemTemplate(text: 'Toiletries'),
    ],
  ),
  const NoteTemplate(
    name: 'Study Notes',
    icon: 'school',
    color: 0xFF673AB7,
    title: 'Study Notes - {subject}',
    content: 'Key Points:\n- \n- \n- \n\nDefinitions:\n- \n\nQuestions:\n- ',
    type: NoteType.text,
  ),
  const NoteTemplate(
    name: 'Fitness Tracker',
    icon: 'fitness_center',
    color: 0xFFFF9800,
    title: 'Workout Log - {date}',
    content: '',
    type: NoteType.checklist,
    checklistItems: <ChecklistItemTemplate>[
      ChecklistItemTemplate(text: 'Warm up'),
      ChecklistItemTemplate(text: 'Cardio'),
      ChecklistItemTemplate(text: 'Strength training'),
      ChecklistItemTemplate(text: 'Stretching'),
    ],
  ),
];

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Note Templates')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: defaultTemplates.length,
        itemBuilder: (BuildContext context, int index) {
          final NoteTemplate template = defaultTemplates[index];
          final Color color = Color(template.color);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _createFromTemplate(context, template),
              borderRadius: BorderRadius.circular(12),
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
                      child: Icon(_getIcon(template.icon), color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            template.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            template.type == NoteType.checklist
                                ? 'Checklist template'
                                : 'Text template',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.add_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'groups':
        return Icons.groups;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'work':
        return Icons.work;
      case 'restaurant':
        return Icons.restaurant;
      case 'flight':
        return Icons.flight;
      case 'school':
        return Icons.school;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.note;
    }
  }

  void _createFromTemplate(BuildContext context, NoteTemplate template) {
    final DateTime now = DateTime.now();
    String title = template.title
        .replaceAll('{date}', '${now.day}/${now.month}/${now.year}');

    final Note newNote = Note(
      id: '',
      title: title,
      content: template.content,
      type: template.type,
      createdAt: now,
      updatedAt: now,
    );

    if (template.type == NoteType.checklist && template.checklistItems != null) {
      newNote.checklistItems = template.checklistItems!
          .map((ChecklistItemTemplate item) => ChecklistItem(
                text: item.text,
              ))
          .toList();
    }

    Navigator.pop(context, newNote);
  }
}