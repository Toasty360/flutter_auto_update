import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'version_checker.dart';
import 'apk_downloader.dart';
import 'installer.dart';
import 'auto_updater_config.dart';
import 'auto_updater_callbacks.dart';

class AutoUpdater {
  final AutoUpdaterConfig config;
  final AutoUpdaterCallbacks callbacks;
  DateTime? _lastCheckTime;
  bool _isChecking = false;
  bool _isDownloading = false;

  AutoUpdater({
    required this.config,
    this.callbacks = const AutoUpdaterCallbacks(),
  });

  /// Check for updates manually
  Future<void> checkForUpdates(BuildContext context) async {
    if (_isChecking) {
      print('Update check already in progress');
      return;
    }

    // Check if enough time has passed since last check
    if (_lastCheckTime != null) {
      final timeSinceLastCheck = DateTime.now().difference(_lastCheckTime!);
      if (timeSinceLastCheck < config.minCheckInterval) {
        print('Update check skipped - too soon since last check');
        return;
      }
    }

    _isChecking = true;
    _lastCheckTime = DateTime.now();

    try {
      // Request permissions first
      final permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        return;
      }

      // Get current version
      final currentVersion = await VersionChecker.getCurrentVersion();
      print('Current version: $currentVersion');

      // Get latest version from GitHub
      final latestVersion = await VersionChecker.getLatestRelease(
        config.githubRepo,
      );
      if (latestVersion == null) {
        callbacks.onVersionCheckFailed?.call('Failed to fetch latest version');
        return;
      }

      print('Latest version: ${latestVersion.version}');

      // Check if update is needed
      if (VersionChecker.isNewerVersion(
            latestVersion.version,
            currentVersion,
          ) &&
          context.mounted) {
        final shouldUpdate = await _showUpdateDialog(
          context,
          latestVersion,
          currentVersion,
        );
        if (shouldUpdate && context.mounted) {
          await _downloadAndInstall(context, latestVersion);
        }
      } else {
        print('App is up to date');
      }
    } catch (e) {
      print('Error checking for updates: $e');
      callbacks.onVersionCheckFailed?.call(e.toString());
    } finally {
      _isChecking = false;
    }
  }

  /// Download and install the update
  Future<void> _downloadAndInstall(
    BuildContext context,
    VersionInfo versionInfo,
  ) async {
    if (_isDownloading) {
      print('Download already in progress');
      return;
    }

    _isDownloading = true;

    try {
      callbacks.onDownloadStarted?.call(versionInfo.apkUrl);

      // Show progress dialog if enabled
      BuildContext? progressContext;
      if (config.showProgressDialog && context.mounted) {
        progressContext = await _showProgressDialog(context);
      }

      // Download APK
      final downloadResult = await ApkDownloader.downloadApk(
        versionInfo.apkUrl,
        config.apkFileName,
        onProgress: (percent, received, total) {
          callbacks.onDownloadProgress?.call(percent, received, total);
          if (progressContext != null) {
            _updateProgressDialog(progressContext, percent);
          }
        },
      );

      // Close progress dialog
      if (progressContext != null && context.mounted) {
        Navigator.of(progressContext).pop();
      }

      if (!downloadResult.success) {
        callbacks.onDownloadFailed?.call(
          downloadResult.error ?? 'Download failed',
        );
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Download Failed',
            downloadResult.error ?? 'Unknown error',
          );
        }
        return;
      }

      callbacks.onDownloadCompleted?.call(downloadResult.filePath!);

      // Install APK if auto-install is enabled
      if (config.autoInstall) {
        callbacks.onInstallStarted?.call(downloadResult.filePath!);

        final installResult = await ApkInstaller.installApk(
          downloadResult.filePath!,
        );

        if (installResult.success) {
          callbacks.onInstallCompleted?.call();
        } else {
          callbacks.onInstallFailed?.call(
            installResult.error ?? 'Installation failed',
          );
          if (context.mounted) {
            _showErrorDialog(
              context,
              'Installation Failed',
              installResult.error ?? 'Unknown error',
            );
          }
        }
      }
    } catch (e) {
      print('Error during download/install: $e');
      callbacks.onDownloadFailed?.call(e.toString());
      if (context.mounted) {
        _showErrorDialog(context, 'Update Failed', e.toString());
      }
    } finally {
      _isDownloading = false;
    }
  }

  /// Request necessary permissions
  Future<bool> _requestPermissions() async {
    // Request storage permission
    var storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      callbacks.onPermissionDenied?.call('Storage');
      print('Storage permission denied');
      return false;
    }

    // Request install permission (for Android 8+)
    var installStatus = await Permission.manageExternalStorage.request();
    if (!installStatus.isGranted) {
      callbacks.onPermissionDenied?.call('Install');
      print('Install permission denied');
      return false;
    }

    return true;
  }

  /// Show update dialog
  Future<bool> _showUpdateDialog(
    BuildContext context,
    VersionInfo versionInfo,
    String currentVersion,
  ) async {
    // Use custom callback if provided
    if (callbacks.onUpdateAvailable != null) {
      return await callbacks.onUpdateAvailable!(
        context,
        versionInfo,
        currentVersion,
      );
    }

    // Use default dialog
    return await showDialog<bool>(
          context: context,
          barrierDismissible: config.allowSkip,
          builder:
              (ctx) => AlertDialog(
                title: Text(config.dialogTitle ?? 'Update Available'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.dialogContent ??
                          'A new version (${versionInfo.version}) is available.\nCurrent version: $currentVersion',
                    ),
                    if (config.showReleaseNotes &&
                        versionInfo.releaseNotes != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Release Notes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        versionInfo.releaseNotes!,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                actions: [
                  if (config.allowSkip)
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(config.skipButtonText ?? 'Later'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(config.updateButtonText ?? 'Update'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// Show progress dialog
  Future<BuildContext> _showProgressDialog(BuildContext context) async {
    final completer = Completer<BuildContext>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        completer.complete(ctx);
        return AlertDialog(
          title: Text(config.progressDialogTitle ?? 'Downloading Update'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Downloading... 0%'),
            ],
          ),
        );
      },
    );

    return completer.future;
  }

  /// Update progress dialog
  void _updateProgressDialog(BuildContext context, int percent) {
    // This would need to be implemented with a state management solution
    // For now, we'll just print the progress
    print('Download progress: $percent%');
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Check if an update check is currently in progress
  bool get isChecking => _isChecking;

  /// Check if a download is currently in progress
  bool get isDownloading => _isDownloading;

  /// Get the last check time
  DateTime? get lastCheckTime => _lastCheckTime;
}
