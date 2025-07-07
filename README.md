# Auto Update for Flutter

A comprehensive Flutter package for automatically updating your app using GitHub releases, without relying on Google Play Store.

## Features

- ✅ **Automatic version checking** from GitHub releases
- ✅ **Download progress tracking** with visual feedback
- ✅ **Automatic installation** after download
- ✅ **Customizable UI** and callbacks
- ✅ **Permission handling** for storage and installation
- ✅ **Modular design** for easy integration
- ✅ **Error handling** and retry mechanisms
- ✅ **Rate limiting** to prevent spam checks
- ✅ **Release notes support** in update dialogs

## Quick Start

### 1. Add Dependencies

```yaml
dependencies:
  autoupdate: ^0.0.1
```

### 2. Configure Android Permissions

Add these permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

### 3. Basic Usage

#### Method 1: Using AutoUpdaterMixin (Recommended)

```dart
import 'package:flutter/material.dart';
import 'package:autoupdate/autoupdate.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with AutoUpdaterMixin {
  @override
  void initState() {
    super.initState();

    final config = AutoUpdaterConfig(
      githubRepo: 'your-username/your-repo',
      apkFileName: 'app-release.apk',
    );

    initAutoUpdater(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(
        child: UpdateCheckButton(
          autoUpdater: autoUpdater!,
          child: Text('Check for Updates'),
        ),
      ),
    );
  }
}
```

#### Method 2: Standalone Instance

```dart
import 'package:flutter/material.dart';
import 'package:autoupdate/autoupdate.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AutoUpdaterWidget(
      config: AutoUpdaterConfig(
        githubRepo: 'your-username/your-repo',
        apkFileName: 'app-release.apk',
        checkOnStartup: true,
      ),
      child: MaterialApp(
        title: 'My App',
        home: MyHomePage(),
      ),
    );
  }
}
```

## Configuration

### AutoUpdaterConfig

```dart
final config = AutoUpdaterConfig(
  // Required
  githubRepo: 'your-username/your-repo',
  apkFileName: 'app-release.apk',

  // Optional - UI customization
  showReleaseNotes: true,
  allowSkip: true,
  dialogTitle: 'Update Available',
  dialogContent: 'A new version is available!',
  updateButtonText: 'Update Now',
  skipButtonText: 'Later',

  // Optional - Behavior
  checkOnStartup: true,
  minCheckInterval: Duration(hours: 1),
  showProgressDialog: true,
  progressDialogTitle: 'Downloading Update',
  autoInstall: true,

  // Optional - Theme
  dialogTheme: ThemeData.light(),
);
```

### Custom Callbacks

```dart
final callbacks = AutoUpdaterCallbacks(
  onUpdateAvailable: (context, versionInfo, currentVersion) async {
    // Custom update dialog
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('🎉 New Update!'),
        content: Text('Version ${versionInfo.version} is available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Update'),
          ),
        ],
      ),
    ) ?? false;
  },

  onDownloadProgress: (percent, received, total) {
    print('Download: $percent%');
  },

  onDownloadCompleted: (filePath) {
    print('Download completed: $filePath');
  },

  onInstallCompleted: () {
    print('Installation completed!');
  },

  onVersionCheckFailed: (error) {
    print('Version check failed: $error');
  },
);
```

## GitHub Setup

### 1. Create Releases

1. Go to your GitHub repository
2. Click on "Releases" → "Create a new release"
3. Set a tag (e.g., `v1.0.1`)
4. Add release notes
5. Upload your APK file
6. Publish the release

### 2. APK Naming

Ensure your APK filename matches the `apkFileName` in your config:

```dart
AutoUpdaterConfig(
  apkFileName: 'app-release.apk', // Must match your uploaded file
  // ...
)
```

### 3. Version Format

Use semantic versioning for your releases:

- `v1.0.0`
- `v1.0.1`
- `v2.0.0`

## Advanced Usage

### Manual Update Check

```dart
// Using mixin
await checkForUpdates();

// Using standalone instance
await autoUpdater.checkForUpdates(context);
```

### Status Monitoring

```dart
// Check if update is in progress
if (autoUpdater.isChecking) {
  print('Update check in progress');
}

if (autoUpdater.isDownloading) {
  print('Download in progress');
}

// Get last check time
final lastCheck = autoUpdater.lastCheckTime;
```

### Custom Progress Dialog

```dart
final callbacks = AutoUpdaterCallbacks(
  onDownloadProgress: (percent, received, total) {
    // Update your custom progress UI
    setState(() {
      downloadProgress = percent;
    });
  },
);
```

## Error Handling

The package includes comprehensive error handling:

- **Network errors**: Automatic retry with exponential backoff
- **Permission errors**: User-friendly permission request dialogs
- **Download errors**: Detailed error messages and cleanup
- **Installation errors**: Fallback options and error reporting

## Troubleshooting

### Common Issues

1. **"No APK found in release assets"**

   - Ensure your APK file is uploaded to the GitHub release
   - Check that the filename matches your config

2. **"Storage permission denied"**

   - Add required permissions to AndroidManifest.xml
   - Request permissions at runtime

3. **"Install permission denied"**

   - Enable "Install unknown apps" in Android settings
   - Request MANAGE_EXTERNAL_STORAGE permission

4. **"Version check failed"**
   - Verify your GitHub repository URL
   - Check internet connectivity
   - Ensure the repository is public or you have proper access

### Debug Mode

Enable debug logging:

```dart
// Add this to see detailed logs
import 'dart:developer' as developer;

// In your callbacks
onVersionCheckFailed: (error) {
  developer.log('Version check failed: $error');
},
```

## API Reference

### AutoUpdaterConfig

| Property             | Type     | Default  | Description                    |
| -------------------- | -------- | -------- | ------------------------------ |
| `githubRepo`         | String   | Required | GitHub repository (owner/repo) |
| `apkFileName`        | String   | Required | APK filename to download       |
| `showReleaseNotes`   | bool     | true     | Show release notes in dialog   |
| `allowSkip`          | bool     | true     | Allow users to skip updates    |
| `checkOnStartup`     | bool     | true     | Check for updates on app start |
| `minCheckInterval`   | Duration | 1 hour   | Minimum time between checks    |
| `showProgressDialog` | bool     | true     | Show download progress dialog  |
| `autoInstall`        | bool     | true     | Auto-install after download    |

### AutoUpdaterCallbacks

| Callback              | Parameters                           | Description               |
| --------------------- | ------------------------------------ | ------------------------- |
| `onUpdateAvailable`   | context, versionInfo, currentVersion | Custom update dialog      |
| `onDownloadProgress`  | percent, received, total             | Download progress updates |
| `onDownloadStarted`   | url                                  | Download started          |
| `onDownloadCompleted` | filePath                             | Download completed        |
| `onDownloadFailed`    | error                                | Download failed           |
| `onInstallStarted`    | filePath                             | Installation started      |
| `onInstallCompleted`  | -                                    | Installation completed    |
| `onInstallFailed`     | error                                | Installation failed       |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions:

1. Check the [troubleshooting section](#troubleshooting)
2. Search existing [issues](https://github.com/your-repo/autoupdate/issues)
3. Create a new issue with detailed information

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.
