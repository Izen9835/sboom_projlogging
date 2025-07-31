import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sboom_projlogging/constants/appwrite_constants.dart';
import 'package:sboom_projlogging/core/core.dart';
import 'package:sboom_projlogging/model/model.dart';

//TODO: convert to generics based on models in model.dart

final DbAPIProvider = Provider((ref) {
  return DbAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class IdbAPI {
  // create
  FutureEitherVoid createBatchProject(List<Project>? list);
  FutureEitherVoid createProjectDetail({
    required String projectID,
    required Map<String, dynamic> data,
    required DataType dataType,
    required bool stayUnique,
  });

  // read
  Future<List<Project>> getListProjects();
  Future<List<T>> getProjectDetails<T>(String projectID, DataType dataType);

  // update
  FutureEitherVoid updateProjectDetail<T>({
    required T data,
    required DataType dataType,
  });
}

class DbAPI implements IdbAPI {
  final Databases _db;
  DbAPI({required Databases db}) : _db = db, super();

  @override
  FutureEitherVoid createBatchProject(List<Project>? list) async {
    final Map<String, Failure> failures = {};

    if (list == null || list.isEmpty) {
      return left(
        Failure(
          "db_api:createList: input list was empty",
          StackTrace.fromString(''),
        ),
      );
    }

    for (final project in list) {
      try {
        final projectID = project.projectID;

        if (projectID == null || projectID.isEmpty) {
          throw ArgumentError.value(
            projectID,
            'projectID',
            'Must not be null or empty for processing object of type: Project',
          );
        }

        final dataMap = project.toMap();

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
          collectionId: AppwriteConstants.projectCollection,
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
          collectionId:
              AppwriteConstants.projectCollection, // TODO: adjust if needed
          documentId: projectID,
          data: dataMap,
        );
      } on AppwriteException catch (e, st) {
        print('Failed Project: ${e.message}');
        failures[project.projectID ?? 'unknown'] = Failure(
          e.message ?? 'Error saving item',
          st,
        );
      } on ArgumentError catch (e, st) {
        print('Validation failed for Project: ${e.message}');
        failures[project.projectID ?? 'unknown'] = Failure(
          e.message ?? 'Invalid data',
          st,
        );
      } catch (e, st) {
        print('Failed Project: ${e.toString()}');
        failures[project.projectID ?? 'unknown'] = Failure(e.toString(), st);
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
  FutureEitherVoid createProjectDetail({
    required String projectID,
    required Map<String, dynamic> data,
    required DataType dataType,
    required bool stayUnique,
  }) async {
    final collectionId = dataType.collectionId;

    try {
      if (stayUnique) {
        final existingDocs = await _db.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: collectionId,
          queries: [Query.equal('projectID', projectID)],
        );

        if (existingDocs.documents.isNotEmpty) {
          return left(
            Failure(
              'Document with projectID $projectID already exists in $collectionId',
              StackTrace.fromString(''),
            ),
          );
        }
      }

      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId:
            data['id']
                as String, //TODO: change function to accept the model as the data (rather than a json)
        data: data,
      );

      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Project>> getListProjects() async {
    final list = await _db.listDocuments(
      collectionId: AppwriteConstants.projectCollection,
      databaseId: AppwriteConstants.databaseId,
    );

    return list.documents
        .map((project) => Project.fromMap(project.data))
        .toList();
  }

  @override
  Future<List<T>> getProjectDetails<T>(
    String? projectID, // make nullable if needed
    DataType dataType,
  ) async {
    final collectionId = dataType.collectionId;

    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: collectionId,
      queries:
          projectID == null || projectID.isEmpty
              ? []
              : [Query.equal('projectID', projectID)],
    );

    return documents.documents.map((doc) => fromDocument<T>(doc)).toList();
  }

  @override
  FutureEitherVoid updateProjectDetail<T>({
    required T data,
    required DataType dataType,
  }) async {
    try {
      final collectionId = dataType.collectionId;

      final String documentId = (data as dynamic).id;
      final Map<String, dynamic> updateData = (data as dynamic).toMap();

      await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: documentId,
        data: updateData,
      );

      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
