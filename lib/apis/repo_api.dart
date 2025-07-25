import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sboom_projlogging/constants/appwrite_constants.dart';
import 'package:sboom_projlogging/core/core.dart';
import 'package:sboom_projlogging/model/changelog_model.dart';
import 'package:sboom_projlogging/model/repo_model.dart';

final RepoAPIProvider = Provider((ref) {
  return RepoAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class IRepoAPI {
  FutureEither<List<Repo>> getReposFromDB();
  FutureEitherVoid saveReposToDB(List<Repo> reposList);
  FutureEither<List<Changelog>> getChangelogsFromRepo(Repo repo);
}

class RepoAPI implements IRepoAPI {
  final Databases _db;
  RepoAPI({required Databases db}) : _db = db, super();

  @override
  FutureEitherVoid saveReposToDB(List<Repo> reposList) async {
    final Map<String, Failure> failures = {};

    for (final repo in reposList) {
      try {
        print('trying ${repo.name} now...');
        await _db.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.repoCollection,
          documentId: repo.repoID,
          data: repo.toMap(),
        );
      } on AppwriteException catch (e, st) {
        print('Failed ${repo.name}: ${e.message}');
        failures[repo.name] = Failure(e.message ?? 'Error saving repo', st);
      } catch (e, st) {
        print('Failed ${repo.name}: ${e.toString()}');
        failures[repo.name] = Failure(e.toString(), st);
      }
    }

    if (failures.isNotEmpty) {
      // Aggregate all failure messages
      final aggregatedMessage = failures.entries
          .map((e) => '${e.key}: ${e.value.message}')
          .join('\n');

      // Optionally merge all stack traces or take the first
      final aggregatedStackTrace = failures.values.first.stackTrace;

      return left(Failure(aggregatedMessage, aggregatedStackTrace));
    }

    return right(null); // Success, no failures
  }

  // perhaps make this generic so can do with bugreports and summary too...
  @override
  FutureEither<List<Changelog>> getChangelogsFromRepo(Repo repo) async {
    try {
      print('my frickin id is ${repo.repoID}');
      final list = await _db.listDocuments(
        collectionId: AppwriteConstants.clogCollection,
        databaseId: AppwriteConstants.databaseId,
        queries: [Query.equal('repoID', repo.repoID)],
      );
      print("items found is ${list.documents.length}");
      print(list.documents[0].data);
      return right(
        list.documents
            .map((changelog) => Changelog.fromMap(changelog.data))
            .toList(),
      );
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<List<Repo>> getReposFromDB() async {
    try {
      final list = await _db.listDocuments(
        collectionId: AppwriteConstants.repoCollection,
        databaseId: AppwriteConstants.databaseId,
      );
      return right(
        list.documents.map((repo) => Repo.fromMap(repo.data)).toList(),
      );
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
