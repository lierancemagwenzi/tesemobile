import 'dart:io';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class OfflinePlayerScreen extends StatefulWidget {
  final String videoName;
  final int videoId;
  final String fileName;
  const OfflinePlayerScreen({
    super.key,
    required this.videoName,
    required this.videoId,
    required this.fileName,
  });

  @override
  State<OfflinePlayerScreen> createState() => _OfflinePlayerScreenState();
}

class _OfflinePlayerScreenState extends State<OfflinePlayerScreen> {
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  Future<void> _setupPlayer() async {
    // 1. Locate the file in local storage
    final directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();

    final String filePath = "${directory!.path}/${widget.fileName}";
    final File videoFile = File(filePath);

    if (kDebugMode) {
      print(widget.fileName);
    }

    if (await videoFile.exists()) {
      print("file exists ${filePath}");
      // 2. Configure Player for Offline Playback
      BetterPlayerConfiguration betterPlayerConfiguration =
          BetterPlayerConfiguration(
            aspectRatio: 16 / 9,
            fit: BoxFit.contain,
            autoPlay: true,
            looping: false,

            // Match Tese Green for the progress bar
            controlsConfiguration: BetterPlayerControlsConfiguration(
              progressBarPlayedColor: const Color(0xFF00D285),
              progressBarHandleColor: const Color(0xFF00D285),
              enablePip: true,
              enableFullscreen: true,
            ),
          );

      // 3. Initialize with File Source
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file, // Set type to 'file' for offline
        filePath,
        useAsmsSubtitles: false,
      );

      _betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
      );
      _betterPlayerController!.setupDataSource(dataSource);
      setState(() {});
    } else {
      debugPrint("File not found at: $filePath");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Downloaded video",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THE PLAYER
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _betterPlayerController != null
                ? BetterPlayer(controller: _betterPlayerController!)
                : const Center(child: CircularProgressIndicator()),
          ),

          // VIDEO INFO
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Available Offline",
                  style: TextStyle(
                    color: Color(0xFF00D285),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }
}
