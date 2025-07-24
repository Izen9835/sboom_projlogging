import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/features/auth/view/login_screen.dart';
import 'package:sboom_projlogging/features/home/view/home_view.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        'home': (context) => HomeView(),
      },
    );
  }
}
