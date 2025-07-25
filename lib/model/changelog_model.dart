import 'dart:convert';

class Changelog {
  final String title;
  final String text;
  final String createdBy;
  final DateTime createdAt;
  final String repoID;

  Changelog({
    required this.title,
    required this.text,
    required this.createdBy,
    required this.createdAt,
    required this.repoID,
  });

  Changelog copyWith({
    String? title,
    String? text,
    String? createdBy,
    DateTime? createdAt,
    String? repoID,
  }) {
    return Changelog(
      title: title ?? this.title,
      text: text ?? this.text,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      repoID: repoID ?? this.repoID,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'title': title});
    result.addAll({'text': text});
    result.addAll({'createdBy': createdBy});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'repoID': repoID});

    return result;
  }

  factory Changelog.fromMap(Map<String, dynamic> map) {
    return Changelog(
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      repoID: map['repoID']?['repoID'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Changelog.fromJson(String source) =>
      Changelog.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Changelog(title: $title, text: $text, createdBy: $createdBy, createdAt: $createdAt, repoID: $repoID)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Changelog &&
        other.title == title &&
        other.text == text &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.repoID == repoID;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        text.hashCode ^
        createdBy.hashCode ^
        createdAt.hashCode ^
        repoID.hashCode;
  }
}
