import 'package:flutter/material.dart';
import 'version_checker.dart';

/// Callback when an update is available
typedef UpdateAvailableCallback =
    Future<bool> Function(
      BuildContext context,
      VersionInfo versionInfo,
      String currentVersion,
    );

/// Callback for download progress
typedef DownloadProgressCallback =
    void Function(int percent, int received, int total);

/// Callback when download starts
typedef DownloadStartedCallback = void Function(String url);

/// Callback when download completes
typedef DownloadCompletedCallback = void Function(String filePath);

/// Callback when download fails
typedef DownloadFailedCallback = void Function(String error);

/// Callback when installation starts
typedef InstallStartedCallback = void Function(String filePath);

/// Callback when installation completes
typedef InstallCompletedCallback = void Function();

/// Callback when installation fails
typedef InstallFailedCallback = void Function(String error);

/// Callback when permission is denied
typedef PermissionDeniedCallback = void Function(String permission);

/// Callback when version check fails
typedef VersionCheckFailedCallback = void Function(String error);

/// Default callbacks that can be extended or overridden
class AutoUpdaterCallbacks {
  final UpdateAvailableCallback? onUpdateAvailable;
  final DownloadProgressCallback? onDownloadProgress;
  final DownloadStartedCallback? onDownloadStarted;
  final DownloadCompletedCallback? onDownloadCompleted;
  final DownloadFailedCallback? onDownloadFailed;
  final InstallStartedCallback? onInstallStarted;
  final InstallCompletedCallback? onInstallCompleted;
  final InstallFailedCallback? onInstallFailed;
  final PermissionDeniedCallback? onPermissionDenied;
  final VersionCheckFailedCallback? onVersionCheckFailed;

  const AutoUpdaterCallbacks({
    this.onUpdateAvailable,
    this.onDownloadProgress,
    this.onDownloadStarted,
    this.onDownloadCompleted,
    this.onDownloadFailed,
    this.onInstallStarted,
    this.onInstallCompleted,
    this.onInstallFailed,
    this.onPermissionDenied,
    this.onVersionCheckFailed,
  });

  /// Create a copy with modified callbacks
  AutoUpdaterCallbacks copyWith({
    UpdateAvailableCallback? onUpdateAvailable,
    DownloadProgressCallback? onDownloadProgress,
    DownloadStartedCallback? onDownloadStarted,
    DownloadCompletedCallback? onDownloadCompleted,
    DownloadFailedCallback? onDownloadFailed,
    InstallStartedCallback? onInstallStarted,
    InstallCompletedCallback? onInstallCompleted,
    InstallFailedCallback? onInstallFailed,
    PermissionDeniedCallback? onPermissionDenied,
    VersionCheckFailedCallback? onVersionCheckFailed,
  }) {
    return AutoUpdaterCallbacks(
      onUpdateAvailable: onUpdateAvailable ?? this.onUpdateAvailable,
      onDownloadProgress: onDownloadProgress ?? this.onDownloadProgress,
      onDownloadStarted: onDownloadStarted ?? this.onDownloadStarted,
      onDownloadCompleted: onDownloadCompleted ?? this.onDownloadCompleted,
      onDownloadFailed: onDownloadFailed ?? this.onDownloadFailed,
      onInstallStarted: onInstallStarted ?? this.onInstallStarted,
      onInstallCompleted: onInstallCompleted ?? this.onInstallCompleted,
      onInstallFailed: onInstallFailed ?? this.onInstallFailed,
      onPermissionDenied: onPermissionDenied ?? this.onPermissionDenied,
      onVersionCheckFailed: onVersionCheckFailed ?? this.onVersionCheckFailed,
    );
  }
}
