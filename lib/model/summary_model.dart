import 'dart:convert';

class Summary {
  final String text;
  final String projectID;

  Summary({required this.text, required this.projectID});

  Summary copyWith({String? text, String? projectID}) {
    return Summary(
      text: text ?? this.text,
      projectID: projectID ?? this.projectID,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'text': text});
    result.addAll({'projectID': projectID});

    return result;
  }

  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      text: map['text'] ?? '',
      projectID: map['projectID']?['projectID'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Summary.fromJson(String source) =>
      Summary.fromMap(json.decode(source));

  @override
  String toString() => 'Summary(text: $text, projectID: $projectID)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Summary &&
        other.text == text &&
        other.projectID == projectID;
  }

  @override
  int get hashCode => text.hashCode ^ projectID.hashCode;
}
