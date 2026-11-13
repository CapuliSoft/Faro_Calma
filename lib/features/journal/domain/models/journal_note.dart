/// Represents a personal journal note stored in the local SQLite database.
class JournalNote {
  final int? id;
  final String title;
  final String content;
  final String? mood;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalNote({
    this.id,
    required this.title,
    required this.content,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalNote.fromMap(Map<String, dynamic> map) {
    return JournalNote(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      mood: map['mood'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  JournalNote copyWith({
    int? id,
    String? title,
    String? content,
    String? mood,
    bool clearMood = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: clearMood ? null : (mood ?? this.mood),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
