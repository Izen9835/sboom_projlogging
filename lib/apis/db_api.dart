import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sboom_projlogging/constants/appwrite_constants.dart';
import 'package:sboom_projlogging/core/core.dart';
import 'package:sboom_projlogging/model/model.dart';

//TODO: convert to generics based on models in model.dart

final dbAPIProvider = Provider((ref) {
  return dbAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class IdbAPI {
  FutureEitherVoid createListModel(List<dynamic>? list);
  FutureEither<List<Project>> getListProject();
}

class dbAPI implements IdbAPI {
  final Databases _db;
  dbAPI({required Databases db}) : _db = db, super();

  @override
  FutureEitherVoid createListModel(List<dynamic>? list) async {
    final Map<String, Failure> failures = {};

    if (list == null || list.isEmpty) {
      return left(
        Failure(
          "db_api:createList: input list was empty",
          StackTrace.fromString(''),
        ),
      );
    }

    for (final obj in list) {
      try {
        final projectID = (obj as dynamic).projectID as String?;
        final dataMap = (obj as dynamic).toMap() as Map<String, dynamic>;

        if (projectID == null || projectID.isEmpty) {
          throw ArgumentError.value(
            projectID,
            'projectID',
            'Must not be null or empty for processing object of type: ${obj.runtimeType}',
          );
        }

        // Build comparison map excluding 'projectID'
        final comparisonMap = Map<String, dynamic>.from(dataMap)
          ..remove('projectID');

        // Build list of Appwrite queries for each field equality check
        final queries =
            comparisonMap.entries
                .map((e) => Query.equal(e.key, e.value))
                .toList();

        // Query Appwrite DB for existing documents matching all these fields
        final existingDocs = await _db.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.repoCollection,
          queries: queries,
        );

        if (existingDocs.documents.isNotEmpty) {
          print(
            'Skipping creation for projectID $projectID: matching document exists.',
          );
          continue; // Skip creation for duplicates
        }

        // No duplicates found, proceed to create the document
        await _db.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.repoCollection,
          documentId: projectID,
          data: dataMap,
        );
      } on AppwriteException catch (e, st) {
        print('Failed ${obj.runtimeType}: ${e.message}');
        failures[obj.projectID ?? 'unknown'] = Failure(
          e.message ?? 'Error saving item',
          st,
        );
      } on ArgumentError catch (e, st) {
        print('Validation failed for ${obj.runtimeType}: ${e.message}');
        failures[obj.projectID ?? 'unknown'] = Failure(
          e.message ?? 'Invalid data',
          st,
        );
      } on NoSuchMethodError catch (e, st) {
        print(
          'Failed ${obj.runtimeType}: Missing required method or property - $e',
        );
        failures['unknown'] = Failure(
          'Missing projectID or toMap method on object',
          st,
        );
      } catch (e, st) {
        print('Failed ${obj.runtimeType}: ${e.toString()}');
        failures[obj.projectID ?? 'unknown'] = Failure(e.toString(), st);
      }
    }

    if (failures.isNotEmpty) {
      final aggregatedMessage = failures.entries
          .map((e) => '${e.key}: ${e.value.message}')
          .join('\n');

      final aggregatedStackTrace = failures.values.first.stackTrace;

      return left(Failure(aggregatedMessage, aggregatedStackTrace));
    }

    return right(null); // Success, no failures
  }

  @override
  FutureEither<List<Project>> getListProject() {
    // TODO: implement getListProject
    throw UnimplementedError();
  }
}
