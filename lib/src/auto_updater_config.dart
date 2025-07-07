import 'package:flutter/material.dart';

class AutoUpdaterConfig {
  /// GitHub repository in format "owner/repo"
  final String githubRepo;

  /// APK filename to download (e.g., "app-release.apk")
  final String apkFileName;

  /// Whether to show release notes in the update dialog
  final bool showReleaseNotes;

  /// Whether to allow users to skip updates
  final bool allowSkip;

  /// Custom dialog title
  final String? dialogTitle;

  /// Custom dialog content
  final String? dialogContent;

  /// Custom update button text
  final String? updateButtonText;

  /// Custom skip button text
  final String? skipButtonText;

  /// Whether to check for updates automatically on app start
  final bool checkOnStartup;

  /// Minimum time between update checks (to avoid spam)
  final Duration minCheckInterval;

  /// Whether to show progress dialog during download
  final bool showProgressDialog;

  /// Custom progress dialog title
  final String? progressDialogTitle;

  /// Whether to automatically install after download
  final bool autoInstall;

  /// Custom theme for dialogs
  final ThemeData? dialogTheme;

  const AutoUpdaterConfig({
    required this.githubRepo,
    required this.apkFileName,
    this.showReleaseNotes = true,
    this.allowSkip = true,
    this.dialogTitle,
    this.dialogContent,
    this.updateButtonText,
    this.skipButtonText,
    this.checkOnStartup = true,
    this.minCheckInterval = const Duration(hours: 1),
    this.showProgressDialog = true,
    this.progressDialogTitle,
    this.autoInstall = true,
    this.dialogTheme,
  });

  /// Create a copy with modified values
  AutoUpdaterConfig copyWith({
    String? githubRepo,
    String? apkFileName,
    bool? showReleaseNotes,
    bool? allowSkip,
    String? dialogTitle,
    String? dialogContent,
    String? updateButtonText,
    String? skipButtonText,
    bool? checkOnStartup,
    Duration? minCheckInterval,
    bool? showProgressDialog,
    String? progressDialogTitle,
    bool? autoInstall,
    ThemeData? dialogTheme,
  }) {
    return AutoUpdaterConfig(
      githubRepo: githubRepo ?? this.githubRepo,
      apkFileName: apkFileName ?? this.apkFileName,
      showReleaseNotes: showReleaseNotes ?? this.showReleaseNotes,
      allowSkip: allowSkip ?? this.allowSkip,
      dialogTitle: dialogTitle ?? this.dialogTitle,
      dialogContent: dialogContent ?? this.dialogContent,
      updateButtonText: updateButtonText ?? this.updateButtonText,
      skipButtonText: skipButtonText ?? this.skipButtonText,
      checkOnStartup: checkOnStartup ?? this.checkOnStartup,
      minCheckInterval: minCheckInterval ?? this.minCheckInterval,
      showProgressDialog: showProgressDialog ?? this.showProgressDialog,
      progressDialogTitle: progressDialogTitle ?? this.progressDialogTitle,
      autoInstall: autoInstall ?? this.autoInstall,
      dialogTheme: dialogTheme ?? this.dialogTheme,
    );
  }
}
