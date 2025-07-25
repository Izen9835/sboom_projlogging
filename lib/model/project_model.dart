import 'dart:convert';

class Project {
  final String name;
  final String full_name;
  final String html_url;
  final String description;
  final String? projectID;

  Project({
    required this.name,
    required this.full_name,
    required this.html_url,
    required this.description,
    this.projectID,
  });

  Project copyWith({
    String? name,
    String? full_name,
    String? html_url,
    String? description,
    String? projectID,
  }) {
    return Project(
      name: name ?? this.name,
      full_name: full_name ?? this.full_name,
      html_url: html_url ?? this.html_url,
      description: description ?? this.description,
      projectID: projectID ?? this.projectID,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'full_name': full_name});
    result.addAll({'html_url': html_url});
    result.addAll({'description': description});
    if (projectID != null) {
      result.addAll({'projectID': projectID});
    }

    return result;
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      name: map['name'] ?? '',
      full_name: map['full_name'] ?? '',
      html_url: map['html_url'] ?? '',
      description: map['description'] ?? '',
      projectID: map['projectID'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Project.fromJson(String source) =>
      Project.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Project(name: $name, full_name: $full_name, html_url: $html_url, description: $description, projectID: $projectID)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project &&
        other.name == name &&
        other.full_name == full_name &&
        other.html_url == html_url &&
        other.description == description &&
        other.projectID == projectID;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        full_name.hashCode ^
        html_url.hashCode ^
        description.hashCode ^
        projectID.hashCode;
  }
}
