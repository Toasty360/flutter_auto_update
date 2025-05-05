import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

typedef ProgressCallback = void Function(int percent);

class ApkDownloader {
  static Future<String?> downloadApk(
    String url,
    String fileName, {
    ProgressCallback? onProgress,
  }) async {
    final dir = await getExternalStorageDirectory();
    final filePath = '${dir?.path}/$fileName';

    final dio = Dio();
    try {
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(((received / total) * 100).toInt());
          }
        },
      );
      return filePath;
    } catch (e) {
      print('Download failed: $e');
      return null;
    }
  }
}
