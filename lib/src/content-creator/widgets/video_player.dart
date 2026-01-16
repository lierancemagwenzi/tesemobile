import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:video_player/video_player.dart';

class AntMediaVideoPlayer extends StatefulWidget {
  final Video video;

  const AntMediaVideoPlayer({super.key, required this.video});

  @override
  State<AntMediaVideoPlayer> createState() => _AntMediaVideoPlayerState();
}

class _AntMediaVideoPlayerState extends State<AntMediaVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Ant Media VoD URL construction
    final videoUrl = widget.video.output ?? "";
    if (kDebugMode) {
      print(videoUrl);
    }
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {}); // Refresh to show video
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getCurrentQualityLabel(VideoPlayerValue value) {
    if (!value.isInitialized) return "Loading...";

    double height = value.size.height;

    if (height >= 1000) return "1080p";
    if (height >= 700) return "720p";
    if (height >= 400) return "480p";

    return "Auto";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The Video
            _controller.value.isInitialized
                ? SizedBox.expand(
                    // 1. Force the container to be the size of the screen
                    child: FittedBox(
                      fit: BoxFit
                          .cover, // 2. Scale the video to cover the entire space
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.green),

            // Interactive Green UI Overlay
            if (_showControls) ...[
              _buildHeader(),
              _buildCenterControls(),
              _buildBottomBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 40,
      left: 20,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.green, size: 30),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.green, size: 40),
            onPressed: () => _controller.seekTo(
              _controller.value.position - const Duration(seconds: 10),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) {
                return Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                );
              },
            ),
            onPressed: () {
              setState(
                () => _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.green, size: 40),
            onPressed: () => _controller.seekTo(
              _controller.value.position + const Duration(seconds: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, VideoPlayerValue value, child) {
              return Text(
                _getCurrentQualityLabel(value),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),

          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.green,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_controller.value.position),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDuration(_controller.value.duration),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
