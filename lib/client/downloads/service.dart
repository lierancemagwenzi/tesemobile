import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/client/downloads/downloaddb.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(
    'downloader_send_port',
  );

  // This print will only show up in the "Background" console or logcat
  print('Background Isolate: Task $id is in status $status with $progress%');

  send?.send([id, status, progress]);
}

class DownloadService {
  static final ReceivePort _port = ReceivePort();

  static Map<int, String> videoToTaskMapping = {};
  // A notifier that holds a Map: { 'download_id' : progress_integer }
  static ValueNotifier<Map<String, int>> downloadProgress = ValueNotifier({});

  static void init() {
    // MUST remove first to handle Hot Restarts
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    bool registered = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    debugPrint(
      "Port Registered: $registered",
    ); // If this is false, the bridge is broken

    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];
      print("Progress: $progress");

     if (status == DownloadTaskStatus.complete) {
        debugPrint("Download $id is finished!");
      } else if (status == DownloadTaskStatus.failed) {
        debugPrint("Download $id failed.");
        // Remove from your local DB since you only want completed files
        DownloadDB.deleteTaskByTaskId(id);
      }
      // Update the Map correctly to trigger the ValueListenableBuilder
      final newMap = Map<String, int>.from(downloadProgress.value);
      newMap[id] = progress;
      downloadProgress.value = newMap;
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static Future<bool> checkIfFileExists(String videoName) async {
    final directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();

    final filePath = "${directory!.path}/$videoName";
    return File(filePath).exists();
  }

  static Future<void> deleteDownload(
    int videoId,
    String taskId,
    String videoName,
  ) async {
    // 1. Remove from Downloader Plugin
    await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);

    // 2. Remove from Local SQLite
    final db = await DownloadDB.database;
    await db.delete('tasks', where: 'videoId = ?', whereArgs: [videoId]);
  }
static Future<void> retryDownload(
    int videoId,
    String url,
    String name,
    String fileName
  ) async {
    // 1. Find the old taskId from our mapping
    String? oldTaskId = videoToTaskMapping[videoId];

    if (oldTaskId != null) {
      // 2. Remove the failed task from the downloader's internal database
      await FlutterDownloader.remove(
        taskId: oldTaskId,
        shouldDeleteContent: true,
      );
    }

    // 3. Start the download again using our existing request method
    await requestDownload(url, videoId, name,fileName);
  }
  static Future<void> requestDownload(
    String url,
    int videoId,
    String name,
    String fileName,
  ) async {
    try {
      Directory? directory;

      if (Platform.isIOS) {
        // iOS: Use ApplicationDocumentsDirectory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Android: Use ExternalStorageDirectory as we discussed
        directory = await getExternalStorageDirectory();
      }

      final String savedDir = directory!.path;
      print('downloading from ${url} to ${directory?.path}');
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        fileName: fileName,
        showNotification: true,
        allowCellular: true,
        openFileFromNotification: false,
        // iOS specific: allows downloading over cellular data
      );
      if (taskId != null) {
        await DownloadDB.saveTask(videoId, taskId, name, fileName);
        print('download task is ${taskId}');
        // CRITICAL: We need this to link the progress back to the UI button
        videoToTaskMapping[videoId] = taskId;
        // Initialize the map so the button knows it's starting
        final newMap = Map<String, int>.from(downloadProgress.value);
        newMap[taskId] = 0;
        downloadProgress.value = newMap;
      }
    } catch (e) {
      print(e);
    }
  }
}
