import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      final osVersion = Platform.operatingSystemVersion.toLowerCase();

      // Look for "android 13", "android 14", or the SDK levels 33, 34+
      if (osVersion.contains("android 13") || osVersion.contains("android 14")) {
        return true;
      }

      // Fallback: Try to parse the SDK level if it appears as "API 33"
      final apiMatch = RegExp(r'api\s+(\d+)').firstMatch(osVersion);
      if (apiMatch != null) {
        int sdk = int.parse(apiMatch.group(1)!);
        return sdk >= 33;
      }
    }

    return false;
  }
}
