import 'dart:convert';

class Summary {
  final String text;
  final String projectID;
  final String id;

  Summary({required this.text, required this.projectID, required this.id});

  Summary copyWith({String? text, String? projectID, String? id}) {
    return Summary(
      text: text ?? this.text,
      projectID: projectID ?? this.projectID,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'text': text});
    result.addAll({'projectID': projectID});
    result.addAll({'id': id});

    return result;
  }

  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      text: map['text'] ?? '',
      projectID: map['projectID']?['projectID'] ?? '',
      id: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Summary.fromJson(String source) =>
      Summary.fromMap(json.decode(source));

  @override
  String toString() => 'Summary(text: $text, projectID: $projectID, id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Summary &&
        other.text == text &&
        other.projectID == projectID &&
        other.id == id;
  }

  @override
  int get hashCode => text.hashCode ^ projectID.hashCode ^ id.hashCode;
}
