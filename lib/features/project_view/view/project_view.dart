import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sboom_projlogging/features/project_view/widgets/bugreports_list.dart';
import 'package:sboom_projlogging/features/project_view/widgets/changelogs_list.dart';
import 'package:sboom_projlogging/model/changelog_model.dart';
import 'package:sboom_projlogging/model/project_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectViewPage extends ConsumerWidget {
  final Project proj;

  const ProjectViewPage({Key? key, required this.proj}) : super(key: key);

  static MaterialPageRoute route({required Project proj}) {
    return MaterialPageRoute(builder: (context) => ProjectViewPage(proj: proj));
  }

  void _launchUrl(BuildContext context) async {
    final url = Uri.tryParse(proj.html_url);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final snackBar = SnackBar(content: Text('Could not launch URL'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name (large, bold)
            Text(
              proj.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            // full_name below name
            Text(
              proj.full_name,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (proj.projectID != null && proj.projectID!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: Center(
                child: Text(
                  proj.projectID!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Open URL button
              ElevatedButton.icon(
                onPressed: () => _launchUrl(context),
                icon: const Icon(Icons.link),
                label: const Text('Open Project Link'),
              ),
              const SizedBox(height: 20),

              // Description (less crucial, less prominent)
              if ((proj.description ?? '').isNotEmpty) ...[
                Text(
                  'Description:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  proj.description!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[800]),
                ),
                const SizedBox(height: 20),
              ],

              // Summary Section (using the new widget)
              // SummaryWidget(proj: proj),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Changelogs',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ChangelogsList(proj: proj),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20), // spacing between the two lists
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bug Reports',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        BugReportsList(proj: proj),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
