import 'package:install_plugin/install_plugin.dart';

class ApkInstaller {
  static Future<void> installApk(String filePath) async {
    try {
      await InstallPlugin.installApk(filePath);
    } catch (e) {
      print("Install failed: $e");
    }
  }
}
