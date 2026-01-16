import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:video_player/video_player.dart';

class TrailerPlayerWidget extends StatefulWidget {
  final String videoUrl =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";

  final Video video;

  final Playlist playlist;
  final Channel channel;

  const TrailerPlayerWidget({
    super.key,
    required this.video,
    required this.playlist,
    required this.channel,
  });

  @override
  StateMVC<TrailerPlayerWidget> createState() => _TrailerPlayerWidgetState();
}

class _TrailerPlayerWidgetState extends StateMVC<TrailerPlayerWidget> {
  late CreatorController _con;

  _TrailerPlayerWidgetState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  // NEW LIGHT THEME PALETTE
  final Color brandBackground = const Color(0xFFF4F7F6); // Soft Slate
  final Color brandGreen = const Color(0xFF00D285); // Your Brand Green
  final Color surfaceWhite = Colors.white; // Card surfaces
  final Color primaryText = const Color(0xFF1A0B2E); // Deep Purple/Black text
  final Color secondaryText = Colors.black54; // Grey text for stats

  @override
  void initState() {
    super.initState();

    _initPlayer();
    _con.listenForVideoStats(widget.video.id);
  }

  Future<void> _initPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.trailer ?? ''),
    );
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: brandGreen,
        handleColor: brandGreen,
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. VIDEO SECTION
            _buildVideoPlayer(),

            // 2. SCROLLABLE CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  Text(
                    widget.video.title ?? "",
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildStatsRow(),
                  const SizedBox(height: 20),

                  _buildActionButtons(),
                  const SizedBox(height: 20),

                  _buildArtistCard(),
                  const SizedBox(height: 25),
                  Text(
                    "Description",
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.video.description ?? "",
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // _buildCommentHeader(),
                  // _buildCommentPreview(),
                  // const SizedBox(height: 30),

                  // Text(
                  //   "Playlist Videos",
                  //   style: TextStyle(
                  //     color: primaryText,
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 15),
                  // _buildRelatedVideosList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return _chewieController != null &&
            _videoPlayerController.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          )
        : const AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(child: CircularProgressIndicator()),
          );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statItem(
          Icons.visibility_outlined,
          "${_con.videoStatsModel?.views ?? 0}",
        ),
        const SizedBox(width: 15),
        _statItem(
          _con.videoStatsModel?.liked == true
              ? Icons.favorite
              : Icons.favorite_border,
          "${_con.videoStatsModel?.likes ?? 0}",
          showActive: _con.videoStatsModel?.liked == true,
        ),
        const SizedBox(width: 15),
        _statItem(
          Icons.file_download_outlined,
          "${_con.videoStatsModel?.downloads ?? 0}",
        ),
      ],
    );
  }

  Widget _statItem(IconData icon, String val, {bool showActive = false}) {
    return Row(
      children: [
        Icon(icon, color: showActive ? Colors.green : secondaryText, size: 18),
        const SizedBox(width: 4),
        Text(val, style: TextStyle(color: secondaryText)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 20,
          child: Icon(Icons.reply, color: primaryText, size: 20),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: surfaceWhite,
          ),
          child: Row(
            children: [
              Icon(Icons.file_download_outlined, color: primaryText, size: 18),
              const SizedBox(width: 8),
              Text(
                "Download",
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: brandGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Row(
            children: [
              Text(
                "Purchase ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArtistCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: brandGreen, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black12,
              child: Image.network(widget.channel.logoUrl ?? ""),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.channel.name}",
                style: TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Channel",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryText,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text("Manage"),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Comments 1",
          style: TextStyle(
            color: primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => _showFullComments(context),
          child: Text(
            "SEE MORE",
            style: TextStyle(
              color: brandGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentPreview() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: brandGreen.withOpacity(0.1),
            child: Icon(Icons.person, color: brandGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Anshika kushwaha",
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "4 days ago",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text("👍", style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedVideosList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.playlist.videos?.length ?? 0,
        itemBuilder: (context, index) {
          Video video = widget.playlist.videos![index];
          return InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/VideoDetails',
                arguments: {
                  'video': video,
                  'playlist': widget.playlist,
                  'channel': widget.channel,
                },
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: NetworkImage(video.thumbnailUrl ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, color: brandGreen, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            UtilsHelper.formatLongDuration(
                              video.durationSeconds ?? 0,
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take more space
      backgroundColor:
          Colors.transparent, // We use a container for rounded corners
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.75, // Covers 75% of screen
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle bar at the top
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Comments",
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: primaryText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Scrollable List of Comments
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 15, // Example count
                  itemBuilder: (context, index) => _buildCommentRow(
                    "User $index",
                    "This is an example of a longer comment to show how the scrolling works in this new modal view!",
                    "2 hours ago",
                  ),
                ),
              ),

              // Bottom Input Field (Sticky inside the modal)
              _buildCommentInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        // This padding ensures the input stays above the keyboard when it opens
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2), // Shadow appears at the top
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar next to input
          CircleAvatar(
            radius: 18,
            backgroundColor: brandGreen.withOpacity(0.1),
            child: Icon(Icons.person, color: brandGreen, size: 20),
          ),
          const SizedBox(width: 12),

          // The Input Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: brandBackground, // Soft slate background
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                style: TextStyle(color: primaryText),
                decoration: const InputDecoration(
                  hintText: "Add a comment...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Send Button
          IconButton(
            icon: Icon(Icons.send_rounded, color: brandGreen),
            onPressed: () {
              // Add your logic to save the comment here
            },
          ),
        ],
      ),
    );
  }

  // Helper for rows inside the Modal
  Widget _buildCommentRow(String user, String msg, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: brandGreen.withOpacity(0.1),
            child: Text(user[0], style: TextStyle(color: brandGreen)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(msg, style: const TextStyle(fontSize: 14, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
