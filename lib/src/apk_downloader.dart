import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

typedef ProgressCallback = void Function(int percent, int received, int total);

class DownloadResult {
  final bool success;
  final String? filePath;
  final String? error;

  DownloadResult({required this.success, this.filePath, this.error});
}

class ApkDownloader {
  static final Dio _dio = Dio();

  static Future<DownloadResult> downloadApk(
    String url,
    String fileName, {
    ProgressCallback? onProgress,
    Duration timeout = const Duration(minutes: 10),
  }) async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        return DownloadResult(
          success: false,
          error: 'Could not access external storage',
        );
      }

      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      // Delete existing file if it exists
      if (await file.exists()) {
        await file.delete();
      }

      await _dio.download(
        url,
        filePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final percent = ((received / total) * 100).toInt();
            onProgress(percent, received, total);
          }
        },
      );

      // Validate downloaded file
      if (!await file.exists()) {
        return DownloadResult(
          success: false,
          error: 'Downloaded file not found',
        );
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        await file.delete();
        return DownloadResult(
          success: false,
          error: 'Downloaded file is empty',
        );
      }

      return DownloadResult(success: true, filePath: filePath);
    } on DioException catch (e) {
      String errorMessage = 'Download failed';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout';
      } else if (e.response != null) {
        errorMessage = 'HTTP ${e.response!.statusCode}';
      }

      print('Download error: $errorMessage - ${e.message}');
      return DownloadResult(success: false, error: errorMessage);
    } catch (e) {
      print('Unexpected download error: $e');
      return DownloadResult(success: false, error: 'Unexpected error: $e');
    }
  }

  static Future<bool> deleteDownloadedApk(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting APK: $e');
      return false;
    }
  }
}
