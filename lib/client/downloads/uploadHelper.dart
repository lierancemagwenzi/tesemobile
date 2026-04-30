import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:background_transfer/background_transfer.dart';
import 'package:smacredit/client/downloads/downloaddb.dart';

class UploadManager {
  // Singleton pattern so you can access it anywhere
  static final UploadManager _instance = UploadManager._internal();
  factory UploadManager() => _instance;
  UploadManager._internal();

  final transfer = getBackgroundTransfer();

  // The global map of { taskId: progress_double }
  final ValueNotifier<Map<String, double>> progressNotifier = ValueNotifier({});

  /// Call this in your main.dart or home screen's initState
  Future<void> initialize() async {
    final tasks = await DownloadDB.getUploadTasks();
    for (var task in tasks) {
      _attachListener(task['taskId']);
    }
  }

  /// Use this instead of the raw listener in transferFile
  void _attachListener(String taskId) {
    transfer
        .getUploadProgress(taskId)
        .listen(
          (progress) {
            // 1. Create a NEW map instance (cloning)
            final newMap = Map<String, double>.from(progressNotifier.value);

            // 2. Update the specific task
            newMap[taskId] = progress;

            // 3. Assign the new map to the notifier
            // This forces ValueListenableBuilder to rebuild
            progressNotifier.value = newMap;

            if (kDebugMode) print('Progress for $taskId: $progress');
          },
          onDone: () async {
            await DownloadDB.deleteUploadTask(taskId);
            final newMap = Map<String, double>.from(progressNotifier.value);
            newMap.remove(taskId);
            progressNotifier.value = newMap;
          },
        );
  }

  /// Call this in your transferFile function
  void trackNewUpload(String taskId) {
    _attachListener(taskId);
  }

  Future<bool> cancelAndCleanup(String taskId) async {
    // 1. Tell the plugin to stop the background task
    final bool success = await transfer.cancelTask(taskId);

    if (success) {
      // 2. Remove from SQLite
      await DownloadDB.deleteUploadTask(taskId);

      // 3. Remove from the live progress map
      final updatedMap = Map<String, double>.from(progressNotifier.value);
      updatedMap.remove(taskId);
      progressNotifier.value = updatedMap;

      debugPrint('Task $taskId cancelled and cleaned up.');
      return true;
    }

    return false;
  }
}

// Global instance for easy access
final uploadManager = UploadManager();
