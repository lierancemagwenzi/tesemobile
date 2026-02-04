import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/client/downloads/downloaddb.dart';
import 'package:smacredit/client/downloads/file_helper.dart';
import 'package:smacredit/client/downloads/service.dart';
import 'package:smacredit/client/downloads/storage_helper.dart';
import 'package:smacredit/client/players/offline_player.dart';
import 'package:storage_space/storage_space.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  Directory? directory;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getDirectory();
  }

  Future<Directory?> getDirectory() async {
    final directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();

    setState(() {
      this.directory = directory;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Downloads',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 1. STORAGE INDICATOR
            _buildStorageCard(isDark),

            // 2. DOWNLOADED VIDEOS LIST
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DownloadDB.getCompletedDownloads(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Completed videos will appear here. Check you downloads on the system notifications",
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return _buildDownloadItem(item, cardColor, isDark);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(bool isDark) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        StorageHelper.getUsedStorageGB(),
        StorageHelper.getDeviceStorageInfo(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        if (kDebugMode) {
          print("total is ${snapshot.data}");
        }
        final double usedGB = StorageHelper.toGig(snapshot.data![0]);

        if (kDebugMode) {
          print("used ${usedGB}");
        }

        final StorageSpace systemStorage = snapshot.data![1];

        // Total device capacity (e.g. 128GB)
        final int freeBytesOnPhone = systemStorage.free;
        final double progress =
            usedGB / StorageHelper.toGig(freeBytesOnPhone.toDouble());
        // final double totalUsedPercent =
        //     1.0 - (systemStorage.freeSize / systemStorage.totalSize);
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storage, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Storage Used",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // Displaying formatted string (e.g., "1.24 GB / 10 GB")
                  Text(
                    "${FileSizeFormatter.formatBytes((snapshot.data?[0] ?? 0).toInt())} / ${systemStorage.freeSize}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.clamp(
                  0.0,
                  1.0,
                ), // Ensure it stays between 0 and 1
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                color: const Color(0xFF00D285), // Tese Green
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStorageCard1(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.storage, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  const Text(
                    "Storage Used",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Text(
                "3.6 GB / 10 GB",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.36,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF00D285), // Tese Green
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(
    Map<String, dynamic> item,
    Color cardColor,
    bool isDark,
  ) {
    return FutureBuilder<int>(
      future: File("${directory?.path}/${item['fileName']}").length(),
      builder: (context, sizeSnapshot) {
        final mb = (sizeSnapshot.data ?? 0) / (1024 * 1024);
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OfflinePlayerScreen(
                  videoName: item['videoName'],
                  videoId: item['videoId'],
                  fileName: item['fileName'],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Thumbnail with Play Overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white70,
                      child: Icon(Icons.play_arrow, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['videoName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const Text(
                      //   "Nature Films Africa",
                      //   style: TextStyle(color: Colors.grey, fontSize: 13),
                      // ),
                      const SizedBox(height: 4),
                      FutureBuilder<int>(
                        future: File(
                          File("${directory?.path}/${item['fileName']}").path,
                        ).length(), // filePath from our previous step
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text(
                              "Calculating...",
                              style: TextStyle(fontSize: 12),
                            );
                          }

                          // This will now show "450 KB" or "1.2 GB" automatically
                          final String sizeText = FileSizeFormatter.formatBytes(
                            snapshot.data!,
                          );

                          return Row(
                            children: [
                              const Icon(
                                Icons.file_download_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sizeText,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  onPressed: () => _confirmDelete(item),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFF3B30),
                  ), // Tese Red
                ),
              ],
            ),
          ),
        );
        ;
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Download?"),
        content: const Text(
          "This video will be removed from your offline storage.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await DownloadService.deleteDownload(
                item['videoId'],
                item['taskId'],
                item['videoName'],
              );
              setState(() {}); // Refresh list
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
