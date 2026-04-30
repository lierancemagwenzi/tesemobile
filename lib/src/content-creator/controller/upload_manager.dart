import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

class TeseUploadManager {
  static final TeseUploadManager instance = TeseUploadManager._();
  TeseUploadManager._();

  // ValueNotifier is great because it only rebuilds what's necessary
  final ValueNotifier<Map<String, TaskRecord>> uploads = ValueNotifier({});

  Future<void> loadHistory() async {
    final records = await FileDownloader().database.allRecords();
    final Map<String, TaskRecord> historyMap = {};
    for (var record in records) {
      historyMap[record.taskId] = record;
    }
    uploads.value = historyMap;
  }

  void handleUpdate(TaskUpdate update) {
    // 1. Create the new map instance immediately to ensure reference change
    final currentMap = Map<String, TaskRecord>.from(uploads.value);
    final String taskId = update.task.taskId;

    if (update is TaskStatusUpdate) {
      print("🎉 Status change detected: $taskId is now ${update.status}");

      final oldRecord = currentMap[taskId];
      if (oldRecord != null) {
        // 2. FORCE the status in our memory map immediately
        currentMap[taskId] = oldRecord.copyWith(status: update.status);

        // 3. Trigger the ValueNotifier NOW so the listener wakes up
        uploads.value = currentMap;
      }

      // 4. Update the DB in the background to keep everything in sync
      _updateLocalRecord(taskId);

      if (update.status == TaskStatus.complete) {
        print("Upload finished completely!");
      }
    } else if (update is TaskProgressUpdate) {
      final oldRecord = currentMap[taskId];
      if (oldRecord != null) {
        currentMap[taskId] = oldRecord.copyWith(
          progress: update.progress,
          status: TaskStatus.running,
        );
        uploads.value = currentMap;
      }
    }
  }

  Future<void> _updateLocalRecord(String taskId) async {
    final record = await FileDownloader().database.recordForId(taskId);
    if (record != null) {
      // We MUST create a new map instance to trigger listeners
      final currentMap = Map<String, TaskRecord>.from(uploads.value);
      currentMap[taskId] = record;

      // This assignment (=) is what "pings" your listener and the UI
      uploads.value = currentMap;

      print("Manager updated status for $taskId to: ${record.status}");
    }
  }

  Future<void> _updateLocalRecord1(String taskId) async {
    final record = await FileDownloader().database.recordForId(taskId);
    if (record != null) {
      final currentMap = Map<String, TaskRecord>.from(uploads.value);
      currentMap[taskId] = record;
      uploads.value = currentMap;
    }
  }

  Future<void> cleanFailedUploads() async {
    // 1. Get all records from the database
    final allRecords = await FileDownloader().database.allRecords();

    // 2. Filter for failed or canceled tasks
    final failedRecords = allRecords.where(
      (r) => r.status == TaskStatus.failed || r.status == TaskStatus.canceled,
    );

    for (var record in failedRecords) {
      try {
        // 3. Delete the local file
        // The 'task' object contains the directory and filename
        final filePath = await record.task.filePath();
        final file = File(filePath);

        if (await file.exists()) {
          await file.delete();
          print("Deleted failed file: $filePath");
        }

        // 4. Remove the record from the downloader's database
        // so it stops showing up in loadHistory()
        await FileDownloader().database.deleteRecordWithId(record.taskId);
      } catch (e) {
        print("Error cleaning up task ${record.taskId}: $e");
      }
    }

    // 5. Refresh your UI map
    await loadHistory();
  }
}
