import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/apis/auth_api.dart';
import 'package:sboom_projlogging/core/utils.dart';

final authControllerProvider = StateNotifierProvider((ref) {
  return AuthController(authAPI: ref.watch(authAPIProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  AuthController({required AuthAPI authAPI}) : _authAPI = authAPI, super(false);

  void login({
    required BuildContext context,
    required String email,
    required String pass,
  }) async {
    state = true;
    final res = await _authAPI.login(email: email, password: pass);
    res.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (r) {
        Navigator.pushNamed(context, 'home');
      },
    );
    state = false;
  }

  void githubLogin({required BuildContext context}) async {
    state = true; // isLoading = true
    final res = await _authAPI.gitHubLogin();
    res.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (r) {
        Navigator.pushNamed(context, 'home');
      },
    );
    state = false;
  }
}
