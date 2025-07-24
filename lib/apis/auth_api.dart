import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sboom_projlogging/core/core.dart';

final authAPIProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthAPI(account: account);
});

final repoListProvider = FutureProvider<List<dynamic>>(
  (ref) => ref.watch(authAPIProvider).getGitHubPublicRepos(),
);

abstract class IAuthAPI {
  FutureEither<model.Session> login({
    required String email,
    required String password,
  });

  FutureEither<model.User> gitHubLogin();

  Future<model.User?> currentUserAccount();
}

class AuthAPI implements IAuthAPI {
  final Account _account;
  AuthAPI({required Account account}) : _account = account;

  @override
  Future<model.User?> currentUserAccount() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither<model.User> gitHubLogin() async {
    try {
      await _account.createOAuth2Session(
        provider: OAuthProvider.github,
        success: '${Uri.base.origin}/auth.html',
        scopes: ['public_repo', 'user'],
      );
      return right(await _account.get());
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<model.Session> login({
    required String email,
    required String password,
  }) {
    // TODO: implement login
    throw UnimplementedError();
  }

  Future<List<dynamic>> getGitHubPublicRepos() async {
    // Get the current session
    final session = await _account.getSession(sessionId: 'current');
    final accessToken = session.providerAccessToken;

    // if (accessToken == null) {
    //   throw Exception('GitHub access token not available.');
    // }

    // // Make request to GitHub API
    // final url = Uri.parse(
    //   'https://api.github.com/user/repos?visibility=public',
    // );
    // final response = await http.get(
    //   url,
    //   headers: {
    //     'Authorization': 'Bearer $accessToken',
    //     'Accept': 'application/vnd.github+json',
    //   },
    // );

    // if (response.statusCode == 200) {
    //   return jsonDecode(response.body);
    // } else {
    //   throw Exception(
    //     'GitHub request failed with status: ${response.statusCode}, ${response.body}',
    //   );
    // }

    // Step 1: Get the username of the authenticated user.
    final userResponse = await http.get(
      Uri.parse('https://api.github.com/user'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (userResponse.statusCode != 200) {
      throw Exception('GitHub user request failed...');
    }

    final username = jsonDecode(userResponse.body)['login'];

    // Step 2: Fetch only that user's own public repos.
    final reposResponse = await http.get(
      Uri.parse('https://api.github.com/users/$username/repos?type=public'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/vnd.github+json',
      },
    );

    if (reposResponse.statusCode == 200) {
      return jsonDecode(reposResponse.body);
    } else {
      throw Exception('GitHub repos request failed...');
    }
  }
}
