// import 'package:flutter/material.dart';
// import 'package:chewie/chewie.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
// import 'package:smacredit/src/content-creator/models/channel_model.dart';
// import 'package:video_player/video_player.dart';

// class TrailerPlayerWidget extends StatefulWidget {
//   final Video video;

//   const TrailerPlayerWidget({
//     super.key,
//     required this.video,

//   });

//   @override
//   StateMVC<TrailerPlayerWidget> createState() => _TrailerPlayerWidgetState();
// }

// class _TrailerPlayerWidgetState extends StateMVC<TrailerPlayerWidget> {
//   late CreatorController _con;

//   _TrailerPlayerWidgetState() : super(CreatorController()) {
//     _con = controller as CreatorController;
//   }

//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;

//   // NEW LIGHT THEME PALETTE
//   final Color brandBackground = const Color(0xFFF4F7F6); // Soft Slate
//   final Color brandGreen = const Color(0xFF00D285); // Your Brand Green
//   final Color surfaceWhite = Colors.white; // Card surfaces
//   final Color primaryText = const Color(0xFF1A0B2E); // Deep Purple/Black text
//   final Color secondaryText = Colors.black54; // Grey text for stats

//   @override
//   void initState() {
//     super.initState();

//     _initPlayer();
//   }

//   Future<void> _initPlayer() async {
//     _videoPlayerController = VideoPlayerController.networkUrl(
//       Uri.parse(widget.video.trailer ?? ''),
//     );
//     await _videoPlayerController.initialize();

//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       autoPlay: true,
//       aspectRatio: _videoPlayerController.value.aspectRatio,
//       materialProgressColors: ChewieProgressColors(
//         playedColor: brandGreen,
//         handleColor: brandGreen,
//         // ignore: deprecated_member_use
//         backgroundColor: Colors.grey.withOpacity(0.2),
//       ),
//     );
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: brandBackground,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // 1. VIDEO SECTION
//             _buildVideoPlayer(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoPlayer() {
//     return _chewieController != null &&
//             _videoPlayerController.value.isInitialized
//         ? AspectRatio(
//             aspectRatio: _videoPlayerController.value.aspectRatio,
//             child: Chewie(controller: _chewieController!),
//           )
//         : const AspectRatio(
//             aspectRatio: 16 / 9,
//             child: Center(child: CircularProgressIndicator()),
//           );
//   }
// }
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:video_player/video_player.dart';

class TrailerPlayerWidget extends StatefulWidget {
  final Video video;

  const TrailerPlayerWidget({super.key, required this.video});

  @override
  StateMVC<TrailerPlayerWidget> createState() => _TrailerPlayerWidgetState();
}

class _TrailerPlayerWidgetState extends StateMVC<TrailerPlayerWidget> {
  late CreatorController _con;

  _TrailerPlayerWidgetState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Tese Africa Brand Colors
  final Color brandGreen = const Color(0xFF679E4F);

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final String? url = widget.video.trailer;

    // 1. Check if URL exists
    if (url == null || url.isEmpty) {
      debugPrint("Trailer URL is null or empty");
      return;
    }

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        // UI Customization
        materialProgressColors: ChewieProgressColors(
          playedColor: brandGreen,
          handleColor: brandGreen,
          bufferedColor: brandGreen.withOpacity(0.2),
          backgroundColor: Colors.white24,
        ),
        // Ensures the player doesn't stay stuck on a black screen if it fails
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              "Error loading trailer",
              style: TextStyle(color: Colors.white70),
            ),
          );
        },
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Video init error: $e");
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use Black for the scaffold here so video previews feel like a "cinema"
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        // Center the video player vertically
        child: _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_chewieController != null &&
        _videoPlayerController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: CircularProgressIndicator(color: brandGreen, strokeWidth: 2),
        ),
      );
    }
  }
}
