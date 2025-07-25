import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/features/settings/widgets/repos_selector.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(child: ReposSelector()),
    );
  }
}
