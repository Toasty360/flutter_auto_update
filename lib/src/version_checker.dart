import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfo {
  final String version;
  final String apkUrl;
  final String? releaseNotes;
  final DateTime? publishedAt;

  VersionInfo({
    required this.version,
    required this.apkUrl,
    this.releaseNotes,
    this.publishedAt,
  });
}

class VersionChecker {
  static final Dio _dio = Dio();

  static Future<VersionInfo?> getLatestRelease(String repo) async {
    try {
      final url = 'https://api.github.com/repos/$repo/releases/latest';
      final response = await _dio.get(url);

      if (response.statusCode != 200) {
        print('Failed to fetch release: ${response.statusCode}');
        return null;
      }

      final data = response.data;
      final version = data['tag_name'] as String?;
      final assets = data['assets'] as List?;
      final releaseNotes = data['body'] as String?;
      final publishedAt =
          data['published_at'] != null
              ? DateTime.parse(data['published_at'])
              : null;

      if (version == null || assets == null) {
        print('Invalid release data format');
        return null;
      }

      final apkAsset = assets.firstWhere(
        (a) => a['name'].toString().toLowerCase().endsWith('.apk'),
        orElse: () => null,
      );

      if (apkAsset == null) {
        print('No APK found in release assets');
        return null;
      }

      return VersionInfo(
        version: version,
        apkUrl: apkAsset['browser_download_url'],
        releaseNotes: releaseNotes,
        publishedAt: publishedAt,
      );
    } catch (e) {
      print('Error fetching latest release: $e');
      return null;
    }
  }

  static Future<String> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (e) {
      print('Error getting current version: $e');
      return '0.0.0';
    }
  }

  static bool isNewerVersion(String latest, String current) {
    try {
      List<int> parse(String v) {
        // Remove 'v' prefix and split by dots
        final clean = v.replaceAll(RegExp(r'[vV]'), '');
        return clean.split('.').map((s) => int.tryParse(s) ?? 0).toList();
      }

      final l = parse(latest);
      final c = parse(current);

      // Compare version numbers
      for (int i = 0; i < l.length || i < c.length; i++) {
        final lPart = i < l.length ? l[i] : 0;
        final cPart = i < c.length ? c[i] : 0;

        if (lPart > cPart) return true;
        if (lPart < cPart) return false;
      }
      return false;
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }
}
