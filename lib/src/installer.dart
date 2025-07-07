import 'package:install_plugin/install_plugin.dart';

class InstallResult {
  final bool success;
  final String? error;

  InstallResult({required this.success, this.error});
}

class ApkInstaller {
  static Future<InstallResult> installApk(String filePath) async {
    try {
      await InstallPlugin.installApk(filePath);
      return InstallResult(success: true);
    } catch (e) {
      print("Install failed: $e");
      return InstallResult(success: false, error: e.toString());
    }
  }
}
