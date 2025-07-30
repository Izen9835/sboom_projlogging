import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sboom_projlogging/core/core.dart';
import 'package:sboom_projlogging/model/project_model.dart';

final GithubAPIProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return GithubAPI(account: account);
});

final repoListProvider = FutureProvider<List<dynamic>>(
  (ref) => ref.watch(GithubAPIProvider).getGitHubPublicRepos(),
);

abstract class IGithubAPI {
  Future<List<dynamic>> getGitHubPublicRepos();
}

class GithubAPI implements IGithubAPI {
  final Account _account;
  GithubAPI({required Account account}) : _account = account;

  @override
  Future<List<dynamic>> getGitHubPublicRepos() async {
    // Get the current session
    final session = await _account.getSession(sessionId: 'current');
    final accessToken = session.providerAccessToken;

    // STEP 1: get public repos in user's organisations

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

    // STEP 2: get public repos in user's own repositories

    // Get the username of the authenticated user.
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

    // Fetch only that user's own public repos.
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
