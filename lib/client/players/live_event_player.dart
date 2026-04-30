import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smacredit/client/events/live_stream_comments.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

class TeseStreamViewer extends StatefulWidget {
  final EventModel eventModel;
  final StreamWatchUnlockModel streamUnlockModel;
  const TeseStreamViewer({
    Key? key,
    required this.eventModel,
    required this.streamUnlockModel,
  }) : super(key: key);

  @override
  _TeseStreamViewerState createState() => _TeseStreamViewerState();
}

class _TeseStreamViewerState extends State<TeseStreamViewer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    // 1. Construct the HLS Playback URL
    // Replace with your dynamic host if needed
    // String playbackUrl =
    //     "https://ams-54-167-81-151.antmedia.cloud:5443/WebRTCAppEE/streams/${widget.eventModel.streamId}.m3u8";

    // 2. Configure the Player
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
          aspectRatio: 9 / 16, // Matches mobile portrait broadcasting
          fit: BoxFit.cover, // Ensures full-screen coverage
          autoPlay: true,
          showPlaceholderUntilPlay: true,

          // Handle the "Offline" or "Loading" states
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.white70, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    "Waiting for broadcast to start...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: Colors.red),
                ],
              ),
            );
          },

          // Hide all standard controls for a clean "Live" look
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            enableFullscreen: false,
            enablePlayPause: false,
            enableProgressBar: false,
            enableSkips: false,
            showControlsOnInitialize: false,
          ),
        );

    // 3. Initialize Source
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.streamUnlockModel.playbackUrl ?? "",
      // headers: {"Authorization": "Bearer ${widget.streamUnlockModel.key}"},
      liveStream: true,
      useAsmsSubtitles: false,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 15000,
      ),
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    Future.delayed(Duration(seconds: 3), () {
      _betterPlayerController.setupDataSource(dataSource);
    });

    // Force Landscape if needed, or stick to portrait for mobile-first apps
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    // Reset orientations when leaving the player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Map<String, dynamic> userMap = {
    'id': '${currentuser.value.user?.id?.toString()}',
    'name':
        '${currentuser.value.user?.fullname ?? ''}', // Full name or Username to display
    'image':
        currentuser.value.user?.selfie ??
        '', // URL to the user's profile picture
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // THE VIDEO PLAYER
          SizedBox.expand(
            child: BetterPlayer(controller: _betterPlayerController),
          ),

          // TOP OVERLAY (Stream Status)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "LIVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // BOTTOM OVERLAY (Interaction/UI)
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Watching Stream: ${widget.eventModel.title}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${widget.eventModel.organizer?.fullname ?? ""}",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            width:
                MediaQuery.of(context).size.width *
                0.85, // Stops it being too wide
            height:
                MediaQuery.of(context).size.height *
                0.45, // Comments take 45% of height
            child: TeseLiveCommentsOverlay(
              eventId: widget.eventModel.id.toString(),
              currentUser: userMap,
            ),
          ),
        ],
      ),
    );
  }
}
