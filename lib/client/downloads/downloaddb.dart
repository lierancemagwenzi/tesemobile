import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DownloadDB {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'downloads.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            videoId INTEGER PRIMARY KEY,
            taskId TEXT,
            videoName TEXT,
            fileName TEXT
          )
        ''');
      },
    );
  }
static Future<void> deleteTaskByTaskId(String taskId) async {
    final db = await database;

    // 1. Delete the record from the SQLite table
    int count = await db.delete(
      'tasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );

    // 2. Also remove it from the FlutterDownloader plugin
    // This stops the plugin from tracking the failed/canceled task
    await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);

    debugPrint('Deleted $count records for Task ID: $taskId');
  }
  static Future<List<Map<String, dynamic>>> getDownloadedVideos() async {
    final db = await database;
    return await db.query('tasks'); // Returns videoId, taskId, videoName
  }
static Future<List<Map<String, dynamic>>> getCompletedDownloads() async {
    final db = await database;

    // 1. Get all records from our local DB
    final List<Map<String, dynamic>> allTasks = await db.query('tasks');

    List<Map<String, dynamic>> completedTasks = [];

    // 2. Cross-reference with the Downloader Plugin and File System
    final tasks = await FlutterDownloader.loadTasks();

    for (var dbItem in allTasks) {
      // Find the matching task in the downloader plugin
      final task = tasks?.firstWhere(
        (t) => t.taskId == dbItem['taskId'],
        orElse: () => DownloadTask(
          taskId: '',
          status: DownloadTaskStatus.undefined,
          progress: 0,
          filename: '',
          allowCellular: true,
          savedDir: '',
          url: '',
          timeCreated: 0,
        ),
      );

      // Only add to the list if the status is 'complete' (status 3)
      if (task?.status == DownloadTaskStatus.complete) {
        completedTasks.add(dbItem);
      }
    }

    return completedTasks;
  }
  static Future<void> saveTask(
    int videoId,
    String taskId,
    String name,
    String fileName,
  ) async {
    final db = await database;
    await db.insert('tasks', {
      'videoId': videoId,
      'taskId': taskId,
      'videoName': name,
      'fileName': fileName,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<int, String>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    // Returns a map of {videoId: taskId}
    return {for (var item in maps) item['videoId']: item['taskId']};
  }
}
