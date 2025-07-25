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
}
