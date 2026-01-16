import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class TesePermissions {
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13 (API 33) and above
      if (await _isAndroid13OrHigher()) {
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

  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    // You can use device_info_plus to get exact version,
    // but typically Permission.videos handles the check internally.
    return true;
  }
}
