import 'dart:convert';

class Repo {
  final String name;
  final String full_name;
  final String html_url;
  final String? description;
  final String? language;
  final String repoID;

  Repo({
    required this.name,
    required this.full_name,
    required this.html_url,
    required this.description,
    required this.language,
    required this.repoID,
  });

  Repo copyWith({
    String? name,
    String? full_name,
    String? html_url,
    String? description,
    String? language,
    String? repoID,
  }) {
    return Repo(
      name: name ?? this.name,
      full_name: full_name ?? this.full_name,
      html_url: html_url ?? this.html_url,
      description: description ?? this.description,
      language: language ?? this.language,
      repoID: repoID ?? this.repoID,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'full_name': full_name});
    result.addAll({'html_url': html_url});
    if (description != null) {
      result.addAll({'description': description});
    }
    if (language != null) {
      result.addAll({'language': language});
    }
    result.addAll({'repoID': repoID});

    return result;
  }

  factory Repo.fromMap(Map<String, dynamic> map) {
    return Repo(
      name: map['name'] ?? '',
      full_name: map['full_name'] ?? '',
      html_url: map['html_url'] ?? '',
      description: map['description'],
      language: map['language'],
      repoID: map['repoID'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Repo.fromJson(String source) => Repo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Repo(name: $name, full_name: $full_name, html_url: $html_url, description: $description, language: $language, repoID: $repoID)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Repo &&
        other.name == name &&
        other.full_name == full_name &&
        other.html_url == html_url &&
        other.description == description &&
        other.language == language &&
        other.repoID == repoID;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        full_name.hashCode ^
        html_url.hashCode ^
        description.hashCode ^
        language.hashCode ^
        repoID.hashCode;
  }
}
