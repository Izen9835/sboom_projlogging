import 'package:appwrite/models.dart' show Document;
import 'package:sboom_projlogging/constants/appwrite_constants.dart';

import 'bugreport_model.dart';
import 'changelog_model.dart';
import 'summary_model.dart';

enum DataType { Changelog, BugReport, Summary }

extension DataTypeExtension on DataType {
  String get collectionId {
    switch (this) {
      case DataType.Changelog:
        return AppwriteConstants.clogCollection;
      case DataType.BugReport:
        return AppwriteConstants.bugrepCollection;
      case DataType.Summary:
        return AppwriteConstants.summaryCollection;
    }
  }
}

T fromDocument<T>(Document doc) {
  if (T == Changelog) {
    return Changelog.fromMap(doc.data) as T;
  } else if (T == BugReport) {
    return BugReport.fromMap(doc.data) as T;
  } else if (T == Summary) {
    return Summary.fromMap(doc.data) as T;
  } else {
    throw UnsupportedError('Unknown type $T');
  }
}
