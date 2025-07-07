import 'package:flutter/material.dart';
import 'package:autoupdate/autoupdate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Update Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with AutoUpdaterMixin {
  late AutoUpdater _autoUpdater;

  @override
  void initState() {
    super.initState();

    // Initialize auto updater with configuration
    final config = AutoUpdaterConfig(
      githubRepo: 'your-username/your-repo', // Replace with your repo
      apkFileName: 'app-release.apk',
      showReleaseNotes: true,
      allowSkip: true,
      checkOnStartup: true,
      minCheckInterval: const Duration(hours: 1),
      showProgressDialog: true,
      autoInstall: true,
    );

    // Initialize with custom callbacks
    initAutoUpdater(
      config,
      callbacks: AutoUpdaterCallbacks(
        onUpdateAvailable: (context, versionInfo, currentVersion) async {
          // Custom update dialog
          return await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('🎉 New Update Available!'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Version ${versionInfo.version} is ready to install!',
                          ),
                          const SizedBox(height: 8),
                          Text('Current: $currentVersion'),
                          if (versionInfo.releaseNotes != null) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'What\'s new:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(versionInfo.releaseNotes!),
                          ],
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Later'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Update Now'),
                        ),
                      ],
                    ),
              ) ??
              false;
        },
        onDownloadProgress: (percent, received, total) {
          print('Download: $percent% ($received/$total bytes)');
        },
        onDownloadCompleted: (filePath) {
          print('Download completed: $filePath');
        },
        onInstallCompleted: () {
          print('Installation completed successfully!');
        },
        onVersionCheckFailed: (error) {
          print('Version check failed: $error');
        },
      ),
    );

    // Also create a standalone instance for manual control
    _autoUpdater = AutoUpdater(config: config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Update Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Auto Update Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Method 1: Using the mixin
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Method 1: Using AutoUpdaterMixin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    UpdateCheckButton(
                      autoUpdater: autoUpdater!,
                      child: const Text('Check for Updates (Mixin)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Method 2: Using standalone instance
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Method 2: Standalone Instance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    UpdateCheckButton(
                      autoUpdater: _autoUpdater,
                      child: const Text('Check for Updates (Standalone)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Checking:'),
                        Text(autoUpdater?.isChecking == true ? 'Yes' : 'No'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Downloading:'),
                        Text(autoUpdater?.isDownloading == true ? 'Yes' : 'No'),
                      ],
                    ),
                    if (autoUpdater?.lastCheckTime != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Last Check:'),
                          Text(
                            autoUpdater!.lastCheckTime!.toString().substring(
                              0,
                              19,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Setup Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Replace "your-username/your-repo" with your GitHub repository',
                    ),
                    Text('2. Upload APK files to GitHub releases'),
                    Text('3. Ensure APK filename matches the config'),
                    Text('4. Add required permissions to AndroidManifest.xml'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
