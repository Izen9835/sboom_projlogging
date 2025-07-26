import 'dart:convert';

class Changelog {
  final String title;
  final String text;
  final String createdBy;
  final DateTime createdAt;
  final String projectID;

  Changelog({
    required this.title,
    required this.text,
    required this.createdBy,
    required this.createdAt,
    required this.projectID,
  });

  Changelog copyWith({
    String? title,
    String? text,
    String? createdBy,
    DateTime? createdAt,
    String? projectID,
  }) {
    return Changelog(
      title: title ?? this.title,
      text: text ?? this.text,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      projectID: projectID ?? this.projectID,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'title': title});
    result.addAll({'text': text});
    result.addAll({'createdBy': createdBy});
    result.addAll({'createdAt': createdAt.toIso8601String()});
    result.addAll({'projectID': projectID});

    return result;
  }

  factory Changelog.fromMap(Map<String, dynamic> map) {
    return Changelog(
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      projectID:
          map['projectID']?['projectID'] ??
          '', // this is important for 'relationships' attributes on appwrite
    );
  }

  String toJson() => json.encode(toMap());

  factory Changelog.fromJson(String source) =>
      Changelog.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Changelog(title: $title, text: $text, createdBy: $createdBy, createdAt: $createdAt, projectID: $projectID)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Changelog &&
        other.title == title &&
        other.text == text &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.projectID == projectID;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        text.hashCode ^
        createdBy.hashCode ^
        createdAt.hashCode ^
        projectID.hashCode;
  }
}
