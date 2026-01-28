import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TesePermissions {
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13 (API 33) and above
      if (await isAndroid13OrHigher()) {
        final status = await Permission.videos.request();
        return status.isGranted;
      } else {
        // For older Android versions
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // On iOS, the app usually has permission to write to its own
      // Documents folder, but requesting 'photos' is good if you plan to save there.
      return true;
    }
    return false;
  }

  static Future<bool> isAndroid13OrHigher() async {
    // 1. Ensure we are on Android to avoid crashes on other platforms
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

      // 2. Android 13 is SDK level 33
      // We check if sdkInt is greater than or equal to 33
      return androidInfo.version.sdkInt >= 33;
    }

    return false;
  }
}
