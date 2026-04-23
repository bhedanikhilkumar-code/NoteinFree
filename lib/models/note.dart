import 'checklist_item.dart';

enum NoteType { text, checklist, sticky }

class Note {
  final String id;
  String title;
  String content;
  NoteType type;
  int colorValue;
  bool pinned;
  bool locked;
  bool archived;
  bool deleted;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? reminderAt;
  List<ChecklistItem> checklistItems;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    this.type = NoteType.text,
    this.colorValue = 0xFFFFFFFF,
    this.pinned = false,
    this.locked = false,
    this.archived = false,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.reminderAt,
    this.checklistItems = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.index,
      'colorValue': colorValue,
      'pinned': pinned,
      'locked': locked,
      'archived': archived,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'checklistItems': checklistItems.map((e) => e.toJson()).toList(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: NoteType.values[json['type'] as int? ?? 0],
      colorValue: json['colorValue'] as int? ?? 0xFFFFFFFF,
      pinned: json['pinned'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      reminderAt: json['reminderAt'] != null
          ? DateTime.parse(json['reminderAt'] as String)
          : null,
      checklistItems: (json['checklistItems'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
