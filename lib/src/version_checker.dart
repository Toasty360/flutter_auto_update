import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfo {
  final String version;
  final String apkUrl;

  VersionInfo({required this.version, required this.apkUrl});
}

class VersionChecker {
  static Future<VersionInfo> getLatestRelease(String repo) async {
    final url = 'https://api.github.com/repos/$repo/releases/latest';
    final response = await Dio().get(url);

    final data = await response.data;
    final version = data['tag_name'];
    final asset = data['assets'].firstWhere(
      (a) => a['name'].toString().endsWith('.apk'),
      orElse: () => throw Exception("No APK found in release assets."),
    );

    return VersionInfo(version: version, apkUrl: asset['browser_download_url']);
  }

  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static bool isNewerVersion(String latest, String current) {
    List<int> parse(String v) =>
        v.replaceAll('v', '').split('.').map(int.parse).toList();

    final l = parse(latest);
    final c = parse(current);

    for (int i = 0; i < l.length; i++) {
      if (i >= c.length || l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }
}
