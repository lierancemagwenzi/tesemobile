import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/client/downloads/downloaddb.dart';
import 'package:storage_space/storage_space.dart';

class StorageHelper {
  // We'll set a hard limit for the app, e.g., 10 GB
  static const double maxStorageGB = 10.0;

  static Future<double> getUsedStorageGB() async {
    double totalBytes = 0;

    // 1. Get the list of all recorded videos from DB
    final savedVideos = await DownloadDB.getDownloadedVideos();

    // 2. Locate the directory
    final directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();

    // 3. Loop through and add up the sizes of the actual files
    for (var video in savedVideos) {
      final String filePath = "${directory!.path}/${video['fileName']}";
      final file = File(filePath);

      if (await file.exists()) {
        totalBytes += await file.length();
      }
    }

    // Convert bytes to GB: bytes / 1024 / 1024 / 1024
    return totalBytes;
  }

  static double toGig(double totalBytes) {
    print("received bytes ${totalBytes}");
    return totalBytes / (1024 * 1024 * 1024);
  }


  static Future<StorageSpace> getDeviceStorageInfo() async {
    // This fetches the actual hardware storage info
    return await getStorageSpace(
      lowOnSpaceThreshold: 1024 * 1024 * 500, fractionDigits: 1, // 500MB threshold
    );
  }
}
