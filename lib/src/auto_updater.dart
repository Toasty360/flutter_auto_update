import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'version_checker.dart';
import 'apk_downloader.dart';
import 'installer.dart';

class AutoUpdater {
  final BuildContext context;
  final String githubRepo;
  final String apkFileName;

  AutoUpdater({
    required this.context,
    required this.githubRepo,
    required this.apkFileName,
  });

  Future<void> checkAndUpdate() async {
    await _requestPermissions();
    final latest = await VersionChecker.getLatestRelease(githubRepo);
    final current = await VersionChecker.getCurrentVersion();

    if (VersionChecker.isNewerVersion(latest.version, current)) {
      final confirmed = await _showUpdateDialog(latest.version);
      if (confirmed) {
        final filePath = await ApkDownloader.downloadApk(
          latest.apkUrl,
          apkFileName,
          onProgress: (progress) {
            debugPrint("Downloading: $progress%");
          },
        );
        if (filePath != null) {
          await ApkInstaller.installApk(filePath);
        }
      }
    }
  }

  Future<void> _requestPermissions() async {
    var storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      print("Storage permission denied.");
      return;
    }

    var installStatus = await Permission.manageExternalStorage.request();
    if (!installStatus.isGranted) {
      print("Install permission denied.");
      return;
    }
  }

  Future<bool> _showUpdateDialog(String version) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Update Available"),
                content: Text(
                  "A new version ($version) is available. Update now?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Later"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("Update"),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
