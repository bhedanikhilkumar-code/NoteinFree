import 'checklist_item.dart';

enum NoteType { text, checklist, sticky }

class Note {
  final String id;
  String title;
  String content;
  NoteType type;
  int backgroundColorValue;
  int labelValue;
  bool pinned;
  bool locked;
  bool archived;
  bool deleted;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? reminderAt;
  List<ChecklistItem> checklistItems;
  String tag;
  List<String> tags;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    this.type = NoteType.text,
    this.backgroundColorValue = 0xFFEEEEEE,
    this.labelValue = 0,
    this.pinned = false,
    this.locked = false,
    this.archived = false,
    this.deleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.reminderAt,
    this.checklistItems = const <ChecklistItem>[],
    this.tag = '',
    this.tags = const <String>[],
  });

  int get colorValue => backgroundColorValue;
  set colorValue(int value) => backgroundColorValue = value;

  List<String> get allTags {
    final Set<String> uniqueTags = <String>{};
    if (tag.trim().isNotEmpty) {
      uniqueTags.add(tag.trim());
    }
    for (final String value in tags) {
      final String cleanValue = value.trim();
      if (cleanValue.isNotEmpty) {
        uniqueTags.add(cleanValue);
      }
    }
    return uniqueTags.toList();
  }

  Map<String, dynamic> toJson() {
    final List<String> normalizedTags = allTags;
    return <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'type': type.index,
      'backgroundColorValue': backgroundColorValue,
      'labelValue': labelValue,
      'pinned': pinned,
      'locked': locked,
      'archived': archived,
      'deleted': deleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'checklistItems': checklistItems.map((ChecklistItem item) => item.toJson()).toList(),
      'tag': normalizedTags.isEmpty ? '' : normalizedTags.first,
      'tags': normalizedTags,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final String legacyTag = json['tag'] as String? ?? '';
    final List<String> decodedTags = (json['tags'] as List<dynamic>?)
            ?.map((dynamic value) => value.toString().trim())
            .where((String value) => value.isNotEmpty)
            .toList() ??
        <String>[];
    final Set<String> uniqueTags = <String>{...decodedTags};
    if (legacyTag.trim().isNotEmpty) {
      uniqueTags.add(legacyTag.trim());
    }
    final List<String> normalizedTags = uniqueTags.toList();

    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: NoteType.values[json['type'] as int? ?? 0],
      backgroundColorValue: json['backgroundColorValue'] as int? ??
          json['colorValue'] as int? ??
          0xFFEEEEEE,
      labelValue: json['labelValue'] as int? ?? 0,
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
              ?.map((dynamic item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          <ChecklistItem>[],
      tag: normalizedTags.isEmpty ? '' : normalizedTags.first,
      tags: normalizedTags,
    );
  }
}
