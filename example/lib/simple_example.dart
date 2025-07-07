import 'package:flutter/material.dart';
import 'package:autoupdate/autoupdate.dart';

/// Simple example showing basic auto-update integration
class SimpleExample extends StatefulWidget {
  const SimpleExample({super.key});

  @override
  State<SimpleExample> createState() => _SimpleExampleState();
}

class _SimpleExampleState extends State<SimpleExample> with AutoUpdaterMixin {
  @override
  void initState() {
    super.initState();

    // Basic configuration
    final config = AutoUpdaterConfig(
      githubRepo: 'your-username/your-repo', // Replace with your repo
      apkFileName: 'app-release.apk',
    );

    initAutoUpdater(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Auto Update'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Simple Auto Update Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Simple update check button
            UpdateCheckButton(
              autoUpdater: autoUpdater!,
              child: const Text('Check for Updates'),
            ),

            const SizedBox(height: 16),

            // Manual check button
            ElevatedButton(
              onPressed: () async {
                await checkForUpdates();
              },
              child: const Text('Manual Check'),
            ),
          ],
        ),
      ),
    );
  }
}
