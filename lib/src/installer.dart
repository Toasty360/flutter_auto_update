import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

class InstallResult {
  final bool success;
  final String? error;

  InstallResult({required this.success, this.error});
}

class ApkInstaller {
  static Future<InstallResult> installApk(String filePath) async {
    if (!Platform.isAndroid) {
      return InstallResult(
        success: false,
        error: 'Auto-update only supported on Android',
      );
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return InstallResult(
          success: false,
          error: 'APK file not found at $filePath',
        );
      }

      if (Platform.isAndroid) {
        return await _installApkAndroid(filePath);
      }

      return InstallResult(success: false, error: 'Platform not supported');
    } catch (e) {
      return InstallResult(
        success: false,
        error: 'Installation failed: ${e.toString()}',
      );
    }
  }

  static Future<InstallResult> _installApkAndroid(String filePath) async {
    try {
      final result = await OpenFile.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );

      return InstallResult(
        success: result.type == ResultType.done,
        error: result.type == ResultType.done ? null : result.message,
      );
    } on PlatformException catch (e) {
      return InstallResult(
        success: false,
        error: 'Failed to open installer: ${e.message}',
      );
    }
  }
}
