import 'dart:convert';

class Summary {
  final String text;

  Summary({required this.text});

  Summary copyWith({String? text}) {
    return Summary(text: text ?? this.text);
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'text': text});

    return result;
  }

  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(text: map['text'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory Summary.fromJson(String source) =>
      Summary.fromMap(json.decode(source));

  @override
  String toString() => 'Summary(text: $text)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Summary && other.text == text;
  }

  @override
  int get hashCode => text.hashCode;
}
