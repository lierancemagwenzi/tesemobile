import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/src/content-creator/controller/upload_manager.dart';

class UploadProgressScreen extends StatelessWidget {
  const UploadProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uploads in Progress')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UploadManagementCard(
              onClearJunk: () {
                TeseUploadManager.instance.cleanFailedUploads();
              },
            ),
            ValueListenableBuilder<Map<String, TaskRecord>>(
              valueListenable: TeseUploadManager.instance.uploads,
              builder: (context, allUploads, child) {
                final list = allUploads.values
                    .toList()
                    .reversed
                    .toList(); // Newest first

                return list.isEmpty
                    ? TeseEmptyWidget()
                    : ListView.builder(
                        itemCount: list.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final record = list[index];
                          final status = record.status;

                          return ListTile(
                            leading: _getStatusIcon(status),
                            title: Text(
                              record.task.displayName,
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: record.progress,
                                  color: _getStatusColor(status),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Status: ${status.name} - ${(record.progress * 100).toInt()}%",
                                ),
                              ],
                            ),
                            // trailing: status == TaskStatus.failed
                            //     ? IconButton(
                            //         icon: Icon(Icons.refresh),
                            //         onPressed: () {
                            //           // _retry(record.task);
                            //         },
                            //       )
                            //     : null,
                          );
                        },
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.complete:
        return Colors.green;
      case TaskStatus.failed:
        return Colors.red;
      case TaskStatus.canceled:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Icon _getStatusIcon(TaskStatus status) {
    if (status == TaskStatus.complete)
      return Icon(Icons.check_circle, color: Colors.green);
    if (status == TaskStatus.failed)
      return Icon(Icons.error, color: Colors.red);
    return Icon(Icons.cloud_upload);
  }
}

class UploadTile extends StatelessWidget {
  final Task task;
  const UploadTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.filename,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<TaskUpdate>(
              // Filter the global stream for just this task
              stream: FileDownloader().updates.where(
                (update) => update.task.taskId == task.taskId,
              ),
              builder: (context, snapshot) {
                double progress = 0.0;
                String status = "Waiting...";

                if (snapshot.hasData) {
                  final update = snapshot.data!;
                  if (update is TaskProgressUpdate) progress = update.progress;
                  if (update is TaskStatusUpdate)
                    status = update.status.toString().split('.').last;
                }

                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(status, style: const TextStyle(fontSize: 12)),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UploadManagementCard extends StatelessWidget {
  final VoidCallback onClearJunk;

  const UploadManagementCard({super.key, required this.onClearJunk});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Keep the app open: Closing or swiping away the app may terminate active uploads.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onClearJunk,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text("Clear Failed Upload Files"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade100),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
