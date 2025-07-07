# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-01-XX

### Added

- Initial release of the auto-update package
- Core auto-update functionality with GitHub releases integration
- Modular design with `AutoUpdaterConfig` and `AutoUpdaterCallbacks`
- Multiple integration methods:
  - `AutoUpdaterMixin` for easy widget integration
  - `AutoUpdaterWidget` for app-level integration
  - Standalone `AutoUpdater` instance
- Comprehensive error handling and retry mechanisms
- Download progress tracking with visual feedback
- Automatic permission handling for storage and installation
- Rate limiting to prevent spam update checks
- Release notes support in update dialogs
- Customizable UI and callbacks
- `UpdateCheckButton` widget for easy integration
- Example app demonstrating various usage patterns
- Comprehensive documentation and API reference

### Features

- **Version Checking**: Automatic version comparison using semantic versioning
- **Download Management**: Robust APK downloading with progress tracking
- **Installation**: Automatic APK installation after download
- **Permission Handling**: Automatic request and handling of required permissions
- **Error Recovery**: Comprehensive error handling with user-friendly messages
- **UI Customization**: Fully customizable dialogs and callbacks
- **Rate Limiting**: Configurable minimum intervals between update checks

### Technical Details

- Built with Flutter 3.7.0+
- Supports Android 6.0+ (API level 23+)
- Uses Dio for HTTP requests
- Integrates with GitHub Releases API
- Handles Android permissions automatically
- Modular architecture for easy extension
