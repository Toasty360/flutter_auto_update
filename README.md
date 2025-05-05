# Autoupdate

A Flutter package to automatically check for updates and install them. The package uses GitHub releases to determine if an update is available.

## Andriod

You need to request permission for READ_EXTERNAL_STORAGE to read the apk file. You can handle the storage permission using flutter_permission_handler.

```xml
 <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

In Android version >= 8.0 , You need to request permission for REQUEST_INSTALL_PACKAGES to install the apk file

```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

In Android version <= 6.0 , You need to request permission for WRITE_EXTERNAL_STORAGE to copy the apk from the app private location to the download directory

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Usage

```dart
final updater = SimpleAutoUpdater(
  context: context,
  githubRepo: 'yourusername/yourrepo',
  apkFileName: 'your_app.apk',
);

await updater.checkAndUpdate();
```
