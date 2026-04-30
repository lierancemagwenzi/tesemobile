import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:smacredit/client/downloads/download_record.dart';
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
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            videoId INTEGER PRIMARY KEY,
            taskId TEXT,
            videoName TEXT,
            fileName TEXT,
            type TEXT,
            artist TEXT,
            album TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE upload_tasks(
            videoId INTEGER PRIMARY KEY,
            taskId TEXT,
            videoName TEXT,
            fileName TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        // 2. This runs for EXISTING users updating the app
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS upload_tasks(
            videoId INTEGER PRIMARY KEY,
            taskId TEXT,
            videoName TEXT,
            fileName TEXT
          )
        ''');
          debugPrint("Database Upgraded: upload_tasks table created.");
        }

        if (oldVersion < 4) {
          await db.execute('ALTER TABLE tasks ADD COLUMN type TEXT');
          debugPrint("Database Upgraded: type column added to tasks.");
        }

        if (oldVersion < 5) {
          await db.execute('ALTER TABLE tasks ADD COLUMN artist TEXT');
          await db.execute('ALTER TABLE tasks ADD COLUMN album TEXT');
          debugPrint("Database Upgraded: artist and album columns added to tasks.");
        }
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

  static Future<List<DownloadRecord>> getDownloadedVideos() async {
    final db = await database;
    final maps = await db.query('tasks');
    return maps.map(DownloadRecord.fromMap).toList();
  }

  static Future<List<DownloadRecord>> getCompletedDownloads() async {
    final db = await database;

    final List<Map<String, dynamic>> allTasks = await db.query('tasks');
    final pluginTasks = await FlutterDownloader.loadTasks();

    return allTasks
        .where((dbItem) {
          final task = pluginTasks?.firstWhere(
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
          return task?.status == DownloadTaskStatus.complete;
        })
        .map(DownloadRecord.fromMap)
        .toList();
  }

  static Future<void> saveTask(
    int videoId,
    String taskId,
    String name,
    String fileName, {
    String type = 'video',
    String? artist,
    String? album,
  }) async {
    final db = await database;
    await db.insert('tasks', {
      'videoId': videoId,
      'taskId': taskId,
      'videoName': name,
      'fileName': fileName,
      'type': type,
      'artist': artist,
      'album': album,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> saveUploadTask(
    int videoId,
    String taskId,
    String name,
    String fileName,
  ) async {
    final db = await database;
    await db.insert('upload_tasks', {
      'videoId': videoId,
      'taskId': taskId,
      'videoName': name,
      'fileName': fileName,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getUploadTasks() async {
    final db = await database;

    // We query the upload_tasks table
    // You can also add an 'orderBy' if you want newest uploads at the top
    final List<Map<String, dynamic>> tasks = await db.query(
      'upload_tasks',
      orderBy: 'videoId DESC',
    );

    debugPrint('Fetched ${tasks.length} pending upload tasks from DB');
    return tasks;
  }

  static Future<Map<int, String>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    // Returns a map of {videoId: taskId}
    return {for (var item in maps) item['videoId']: item['taskId']};
  }

  static Future<void> deleteUploadTask(String taskId) async {
    final db = await database;
    await db.delete('upload_tasks', where: 'taskId = ?', whereArgs: [taskId]);
    debugPrint('Upload task $taskId removed from local storage.');
  }
}
