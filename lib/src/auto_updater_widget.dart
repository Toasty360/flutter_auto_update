import 'package:flutter/material.dart';
import 'auto_updater.dart';
import 'auto_updater_config.dart';
import 'auto_updater_callbacks.dart';

/// A widget that automatically checks for updates
class AutoUpdaterWidget extends StatefulWidget {
  final Widget child;
  final AutoUpdaterConfig config;
  final AutoUpdaterCallbacks? callbacks;
  final bool checkOnInit;

  const AutoUpdaterWidget({
    super.key,
    required this.child,
    required this.config,
    this.callbacks,
    this.checkOnInit = true,
  });

  @override
  State<AutoUpdaterWidget> createState() => _AutoUpdaterWidgetState();
}

class _AutoUpdaterWidgetState extends State<AutoUpdaterWidget> {
  late AutoUpdater _autoUpdater;

  @override
  void initState() {
    super.initState();
    _autoUpdater = AutoUpdater(
      config: widget.config,
      callbacks: widget.callbacks ?? const AutoUpdaterCallbacks(),
    );

    if (widget.checkOnInit && widget.config.checkOnStartup) {
      // Delay the initial check to ensure the widget is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoUpdater.checkForUpdates(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Expose the auto updater instance for manual checks
  AutoUpdater get autoUpdater => _autoUpdater;
}

/// A mixin that provides auto-update functionality to any widget
mixin AutoUpdaterMixin<T extends StatefulWidget> on State<T> {
  AutoUpdater? _autoUpdater;

  /// Initialize the auto updater
  void initAutoUpdater(
    AutoUpdaterConfig config, {
    AutoUpdaterCallbacks? callbacks,
  }) {
    _autoUpdater = AutoUpdater(
      config: config,
      callbacks: callbacks ?? const AutoUpdaterCallbacks(),
    );
  }

  /// Check for updates manually
  Future<void> checkForUpdates() async {
    if (_autoUpdater != null) {
      await _autoUpdater!.checkForUpdates(context);
    }
  }

  /// Get the auto updater instance
  AutoUpdater? get autoUpdater => _autoUpdater;
}

/// A button widget that triggers update check
class UpdateCheckButton extends StatelessWidget {
  final AutoUpdater autoUpdater;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool showLoading;

  const UpdateCheckButton({
    super.key,
    required this.autoUpdater,
    this.child,
    this.onPressed,
    this.showLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final isLoading = autoUpdater.isChecking || autoUpdater.isDownloading;

        return ElevatedButton(
          onPressed:
              isLoading
                  ? null
                  : () async {
                    if (onPressed != null) {
                      onPressed!();
                    }
                    await autoUpdater.checkForUpdates(context);
                    if (showLoading && context.mounted) {
                      setState(() {}); // Rebuild to update loading state
                    }
                  },
          child:
              isLoading && showLoading
                  ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Checking...'),
                    ],
                  )
                  : child ?? const Text('Check for Updates'),
        );
      },
    );
  }
}
