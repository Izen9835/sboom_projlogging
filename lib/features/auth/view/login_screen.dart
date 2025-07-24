import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => LoginScreen());

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void OnGithubLogin() {
    ref.read(authControllerProvider.notifier).githubLogin(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    width: (MediaQuery.of(context).size.width) * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            // Handle email/password authentication here
                          },
                          child: Text('Login'),
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('OR'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: OnGithubLogin,
                          icon: Icon(Icons.login),
                          label: Text('Login with GitHub'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
