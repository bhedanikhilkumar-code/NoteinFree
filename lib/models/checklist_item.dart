class ChecklistItem {
  String text;
  bool isCompleted;

  ChecklistItem({
    required this.text,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      text: json['text'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
