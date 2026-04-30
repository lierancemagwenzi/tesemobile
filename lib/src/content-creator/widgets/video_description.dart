// import 'package:flutter/material.dart';
// import 'package:chewie/chewie.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/client/respository/client_repositoy.dart';
// import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
// import 'package:smacredit/src/content-creator/models/channel_model.dart';
// import 'package:smacredit/src/repositories/user_repository.dart';
// import 'package:smacredit/src/utils/xhelper.dart';
// import 'package:video_player/video_player.dart';

// class FullVideoDetailView extends StatefulWidget {
//   final String videoUrl =
//       "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";

//   final Video video;

//   final Playlist playlist;
//   final Channel channel;

//   final bool isTrailer;

//   const FullVideoDetailView({
//     super.key,
//     required this.video,
//     required this.playlist,
//     required this.channel,
//     required this.isTrailer,
//   });

//   @override
//   StateMVC<FullVideoDetailView> createState() => _FullVideoDetailViewState();
// }

// class _FullVideoDetailViewState extends StateMVC<FullVideoDetailView> {
//   late CreatorController _con;

//   _FullVideoDetailViewState() : super(CreatorController()) {
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

//     fetchSignedCookies().then((value) {
//       _initPlayer();
//     });
//     _con.listenForVideoStats(widget.video.id);
//   }

//   Future<void> _initPlayer() async {
//     _videoPlayerController = VideoPlayerController.networkUrl(
//       Uri.parse(
//         widget.isTrailer
//             ? widget.video.trailer ?? ''
//             : widget.video.output ?? '',
//       ),
//       httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},
//     );
//     await _videoPlayerController.initialize();

//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       autoPlay: true,
//       aspectRatio: _videoPlayerController.value.aspectRatio,
//       materialProgressColors: ChewieProgressColors(
//         playedColor: brandGreen,
//         handleColor: brandGreen,
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

//             // 2. SCROLLABLE CONTENT
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 20,
//                 ),
//                 children: [
//                   Text(
//                     widget.video.title ?? "",
//                     style: TextStyle(
//                       color: primaryText,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   _buildStatsRow(),
//                   const SizedBox(height: 20),

//                   _buildActionButtons(),
//                   const SizedBox(height: 20),

//                   _buildArtistCard(),
//                   const SizedBox(height: 25),
//                   Text(
//                     "Description",
//                     style: TextStyle(
//                       color: primaryText,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     widget.video.description ?? "",
//                     style: TextStyle(
//                       color: secondaryText,
//                       fontSize: 12,
//                       // height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   _buildCommentHeader(),
//                   _buildCommentPreview(),
//                   const SizedBox(height: 30),

//                   Text(
//                     "Playlist Videos",
//                     style: TextStyle(
//                       color: primaryText,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   _buildRelatedVideosList(),
//                 ],
//               ),
//             ),
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

//   Widget _buildStatsRow() {
//     return Row(
//       children: [
//         _statItem(
//           Icons.visibility_outlined,
//           "${_con.videoStatsModel?.views ?? 0}",
//         ),
//         const SizedBox(width: 15),
//         _statItem(
//           _con.videoStatsModel?.liked == true
//               ? Icons.favorite
//               : Icons.favorite_border,
//           "${_con.videoStatsModel?.likes ?? 0}",
//           showActive: _con.videoStatsModel?.liked == true,
//         ),
//         const SizedBox(width: 15),
//         _statItem(
//           Icons.file_download_outlined,
//           "${_con.videoStatsModel?.downloads ?? 0}",
//         ),
//       ],
//     );
//   }

//   Widget _statItem(IconData icon, String val, {bool showActive = false}) {
//     return Row(
//       children: [
//         Icon(icon, color: showActive ? Colors.green : secondaryText, size: 18),
//         const SizedBox(width: 4),
//         Text(val, style: TextStyle(color: secondaryText)),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         CircleAvatar(
//           backgroundColor: Colors.grey[200],
//           radius: 20,
//           child: Icon(Icons.reply, color: primaryText, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//             color: surfaceWhite,
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.file_download_outlined, color: primaryText, size: 18),
//               const SizedBox(width: 8),
//               Text(
//                 "Download",
//                 style: TextStyle(
//                   color: primaryText,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const Spacer(),
//         // ElevatedButton(
//         //   onPressed: () {},
//         //   style: ElevatedButton.styleFrom(
//         //     backgroundColor: brandGreen,
//         //     elevation: 0,
//         //     shape: RoundedRectangleBorder(
//         //       borderRadius: BorderRadius.circular(8),
//         //     ),
//         //   ),
//         //   child: const Row(
//         //     children: [
//         //       Text(
//         //         "Purchase ",
//         //         style: TextStyle(
//         //           color: Colors.white,
//         //           fontWeight: FontWeight.bold,
//         //         ),
//         //       ),
//         //       Icon(Icons.chevron_right, color: Colors.white, size: 18),
//         //     ],
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Widget _buildArtistCard() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: surfaceWhite,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 50,
//             width: 50,
//             padding: const EdgeInsets.all(2),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: brandGreen, width: 1.5),
//               image: DecorationImage(
//                 image: NetworkImage(
//                   widget.channel.logoUrl ?? "",
//                   headers: {'Cookie': cloudFrontCookieNotifier.value},
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             // child: CircleAvatar(
//             //   radius: 22,
//             //   backgroundColor: Colors.black12,
//             //   child: Image.network(
//             //     widget.channel.logoUrl ?? "",
//             //     fit: BoxFit.cover,
//             //   ),
//             // ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "${widget.channel.name}",
//                 style: TextStyle(
//                   color: primaryText,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Text(
//                 "Channel",
//                 style: TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           ),
//           const Spacer(),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryText,
//               foregroundColor: Colors.white,
//               shape: const StadiumBorder(),
//             ),
//             child: const Text("Manage"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           "Comments 1",
//           style: TextStyle(
//             color: primaryText,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         GestureDetector(
//           onTap: () => _showFullComments(context),
//           child: Text(
//             "SEE MORE",
//             style: TextStyle(
//               color: brandGreen,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCommentPreview() {
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: surfaceWhite,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 16,
//             backgroundColor: brandGreen.withOpacity(0.1),
//             child: Icon(Icons.person, color: brandGreen, size: 18),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       "Anshika kushwaha",
//                       style: TextStyle(
//                         color: primaryText,
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       "4 days ago",
//                       style: TextStyle(color: Colors.grey, fontSize: 11),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 const Text("👍", style: TextStyle(fontSize: 14)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRelatedVideosList() {
//     return SizedBox(
//       height: 150,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: widget.playlist.videos?.length ?? 0,
//         itemBuilder: (context, index) {
//           Video video = widget.playlist.videos![index];
//           return InkWell(
//             onTap: () {
//               Navigator.pushReplacementNamed(
//                 context,
//                 '/VideoDetails',
//                 arguments: {
//                   'video': video,
//                   'playlist': widget.playlist,
//                   'channel': widget.channel,
//                 },
//               );
//             },
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 200,
//                   height: 120,
//                   margin: const EdgeInsets.only(right: 12),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.grey[300],
//                     image: DecorationImage(
//                       image: NetworkImage(
//                         video.thumbnailUrl ?? "",
//                         headers: {'Cookie': cloudFrontCookieNotifier.value},
//                       ),

//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       // Align(
//                       //   alignment: AlignmentGeometry.center,
//                       //   child: Text(
//                       //     video.title ?? "",
//                       //     style: TextStyle(color: Colors.black),
//                       //     overflow: TextOverflow.fade,
//                       //   ),
//                       // ),
//                       Positioned(
//                         bottom: 8,
//                         right: 8,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black87,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.play_arrow,
//                                 color: brandGreen,
//                                 size: 12,
//                               ),
//                               const SizedBox(width: 2),
//                               Text(
//                                 UtilsHelper.formatLongDuration(
//                                   video.durationSeconds ?? 0,
//                                 ),
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   video.title ?? "",
//                   style: TextStyle(color: Colors.black),
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.fade,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showFullComments(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // Allows the sheet to take more space
//       backgroundColor:
//           Colors.transparent, // We use a container for rounded corners
//       builder: (context) {
//         return Container(
//           height:
//               MediaQuery.of(context).size.height * 0.75, // Covers 75% of screen
//           decoration: BoxDecoration(
//             color: surfaceWhite,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
//           ),
//           child: Column(
//             children: [
//               // Handle bar at the top
//               const SizedBox(height: 12),
//               Container(
//                 width: 40,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),

//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Comments",
//                       style: TextStyle(
//                         color: primaryText,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close, color: primaryText),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),

//               // Scrollable List of Comments
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: 15, // Example count
//                   itemBuilder: (context, index) => _buildCommentRow(
//                     "User $index",
//                     "This is an example of a longer comment to show how the scrolling works in this new modal view!",
//                     "2 hours ago",
//                   ),
//                 ),
//               ),

//               // Bottom Input Field (Sticky inside the modal)
//               _buildCommentInput(),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCommentInput() {
//     return Container(
//       padding: EdgeInsets.only(
//         left: 16,
//         right: 8,
//         top: 8,
//         // This padding ensures the input stays above the keyboard when it opens
//         bottom: MediaQuery.of(context).viewInsets.bottom + 8,
//       ),
//       decoration: BoxDecoration(
//         color: surfaceWhite,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -2), // Shadow appears at the top
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // User Avatar next to input
//           CircleAvatar(
//             radius: 18,
//             backgroundColor: brandGreen.withOpacity(0.1),
//             child: Icon(Icons.person, color: brandGreen, size: 20),
//           ),
//           const SizedBox(width: 12),

//           // The Input Field
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: brandBackground, // Soft slate background
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               child: TextField(
//                 style: TextStyle(color: primaryText),
//                 decoration: const InputDecoration(
//                   hintText: "Add a comment...",
//                   hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),

//           // Send Button
//           IconButton(
//             icon: Icon(Icons.send_rounded, color: brandGreen),
//             onPressed: () {
//               // Add your logic to save the comment here
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper for rows inside the Modal
//   Widget _buildCommentRow(String user, String msg, String time) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             backgroundColor: brandGreen.withOpacity(0.1),
//             child: Text(user[0], style: TextStyle(color: brandGreen)),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       user,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 13,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       time,
//                       style: const TextStyle(color: Colors.grey, fontSize: 11),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(msg, style: const TextStyle(fontSize: 14, height: 1.3)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/respository/client_repositoy.dart';
import 'package:smacredit/client/services/comment_like.dart';
import 'package:smacredit/client/services/comment_service.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/video_review_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:video_player/video_player.dart';

class FullVideoDetailView extends StatefulWidget {
  final Video video;
  final Playlist playlist;
  final Channel channel;
  final bool isTrailer;

  const FullVideoDetailView({
    super.key,
    required this.video,
    required this.playlist,
    required this.channel,
    required this.isTrailer,
  });

  @override
  StateMVC<FullVideoDetailView> createState() => _FullVideoDetailViewState();
}

class _FullVideoDetailViewState extends StateMVC<FullVideoDetailView> {
  late CreatorController _con;

  _FullVideoDetailViewState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  // THEME COLORS (Optimized for Visibility)
  final Color brandGreen = const Color(0xFF679E4F);
  bool _showComments = false; // Toggle state for comments
  String? replyingToId; // Store the ID of the comment being replied to
  String? replyingToName;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSignedCookies().then((value) {
      _initPlayer();
    });
    _con.listenForVideoStats(widget.video.id);
    _con.listenForReports(widget.video.id);
  }

  Future<void> _initPlayer() async {
    final videoUrl = widget.isTrailer
        ? widget.video.trailer
        : widget.video.output;
    if (videoUrl == null || videoUrl.isEmpty) return;

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},
    );

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: brandGreen,
        handleColor: brandGreen,
        bufferedColor: brandGreen.withOpacity(0.2),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1A0B2E);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final bgColor = isDark ? Colors.black : const Color(0xFFF4F7F6);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: primaryTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // 1. VIDEO SECTION
          _buildVideoPlayer(),

          // 2. SCROLLABLE CONTENT
          if (_showComments)
            _buildCommentsSection(isDark)
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    widget.video.title ?? "Untitled Video",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildStatsRow(secondaryTextColor),
                  const SizedBox(height: 20),

                  _buildActionButtons(primaryTextColor, cardColor),
                  const SizedBox(height: 20),

                  _buildArtistCard(primaryTextColor, cardColor),
                  const SizedBox(height: 25),

                  Text(
                    "Description",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description ?? "No description provided.",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // _buildCommentHeader(primaryTextColor),
                  // const SizedBox(height: 30),
                  Text(
                    "Playlist Videos",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildRelatedVideosList(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child:
            _chewieController != null &&
                _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            : const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsRow(Color secondaryColor) {
    return Row(
      children: [
        _statItem(
          Icons.visibility_outlined,
          "${_con.videoStatsModel?.views ?? 0}",
          secondaryColor,
        ),
        const SizedBox(width: 15),
        _statItem(
          _con.videoStatsModel?.liked == true
              ? Icons.favorite
              : Icons.favorite_border,
          "${_con.videoStatsModel?.likes ?? 0}",
          secondaryColor,
          active: _con.videoStatsModel?.liked == true,
        ),
        const SizedBox(width: 15),
        _statItem(
          Icons.person,
          "${_con.videoStatsModel?.unique_views ?? 0}",
          secondaryColor,
        ),
        const SizedBox(width: 15),

        InkWell(
          onTap: () {
            setState(() {
              _showComments = !_showComments;
            });
          },
          child: Icon(Icons.chat),
        ),
      ],
    );
  }

  Widget _statItem(
    IconData icon,
    String val,
    Color color, {
    bool active = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: active ? Colors.redAccent : color, size: 18),
        const SizedBox(width: 4),
        Text(val, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }

  Widget _buildActionButtons(Color textColor, Color cardColor) {
    return Row(
      children: [
        // _circleActionButton(Icons.reply, textColor, cardColor),
        // const SizedBox(width: 12),
        // _roundedActionButton(
        //   Icons.file_download_outlined,
        //   "Download",
        //   textColor,
        //   cardColor,
        // ),
        ViewEarningsButton(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor:
                  Colors.transparent, // Required for the glass effect
              isScrollControlled: true,
              builder: (context) => VideoEarningsSheet(
                totalEarnings: (_con.videoStatsModel?.total_earnings ?? 0)
                    .toDouble(),
                totalSales: (_con.videoStatsModel?.total_sales ?? 0),
                monthlyEarnings: (_con.videoStatsModel?.monthly_earnings ?? 0)
                    .toDouble(),
                monthlySales: (_con.videoStatsModel?.monthly_sales ?? 0),
              ),
            );
          },
        ),
        const Spacer(),
        ViewReportsButton(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque:
                    false, // Essential for the blur to show the previous screen
                pageBuilder: (context, _, __) =>
                    VideoReportsReviewWidget(reports: _con.reports),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildArtistCard(Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
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
          CircleAvatar(
            radius: 24,
            backgroundColor: brandGreen,
            backgroundImage: NetworkImage(
              widget.channel.logoUrl ?? "",
              headers: {'Cookie': cloudFrontCookieNotifier.value},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.channel.name ?? "Channel",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Content Creator",
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: cardColor,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              "Manage",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedVideosList(bool isDark) {
    final list = widget.playlist.videos ?? [];
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          Video v = list[index];
          return InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/VideoDetails',
                arguments: {
                  'video': v,
                  'playlist': widget.playlist,
                  'channel': widget.channel,
                },
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          v.thumbnailUrl ?? "",
                          height: 100,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              UtilsHelper.formatLongDuration(
                                v.durationSeconds ?? 0,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    v.title ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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

  // --- Helper Widgets ---

  Widget _circleActionButton(IconData icon, Color color, Color bg) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _roundedActionButton(
    IconData icon,
    String label,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Comments",
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _showComments = !_showComments;
            });
          },
          child: Text(
            "VIEW ALL",
            style: TextStyle(
              color: brandGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentPreview(Color textColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: brandGreen.withOpacity(0.1),
            child: Icon(Icons.person, color: brandGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Add a comment...",
              style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FullCommentsModal(brandGreen: brandGreen),
    );
  }

  Widget _buildCommentsSection(bool isDark) {
    return Container(
      height: 500,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header with dynamic count
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('videos')
                .doc(widget.video.id.toString())
                .collection('comments')
                // .where('parent_id', isEqualTo: "--") // <--- ADD THIS FILTER
                // .orderBy('time', descending: true)
                .snapshots(),

            builder: (context, snapshot) {
              final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Comments ($count)",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _showComments = false),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          // Input Box (Keeping your logic)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                const SizedBox(width: 10),
                // if (currentuser.value.user?.id != null)
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        // CommentService().postComment(
                        //   widget.video.id,
                        //   currentuser.value.user?.id ?? 0,
                        //   currentuser.value.user?.fullname ?? 'tese user',
                        //   value,
                        // );
                        // _showPurchaseOptions(_con.channel!);

                        UtilsHelper.ensureAuth(
                          context,
                          action: "to add a comment",
                          onAuthenticated: () {
                            CommentService().postComment(
                              widget.video.id,
                              currentuser.value.user?.id ?? 0,
                              currentuser.value.user?.fullname ?? 'tese user',
                              value,
                              parentCommentId:
                                  replyingToId, // Pass the parent ID here
                            );
                            setState(() {
                              replyingToId = null;
                              replyingToName = "";
                              _controller.clear();
                            });

                            _controller.clear();
                          },
                        );

                        // Reset reply state
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      filled: true,
                      labelText:
                          replyingToName != null &&
                              replyingToName?.isNotEmpty == true &&
                              replyingToId?.isNotEmpty == true
                          ? "Replying to $replyingToName"
                          : null,
                      // labelText:
                      fillColor: isDark
                          ? const Color(0xFF1C1C1E)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // REAL-TIME Scrollable Comments List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('videos')
                  .doc(widget.video.id.toString())
                  .collection('comments')
                  .where('parent_id', isEqualTo: "--") // <--- ADD THIS FILTER
                  // .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No comments yet. Be the first!"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                    // Extracting data safely
                    String name = data['username'] ?? 'Tese User';
                    String text = data['comment'] ?? '';
                    Timestamp? ts = data['time'] as Timestamp?;
                    String timeStr = ts != null
                        ? _formatTimestamp(ts)
                        : "Just now";

                    String id = snapshot.data!.docs[index].id;
                    return _commentTile(name, text, timeStr, 0, id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    return "${difference.inDays}d ago";
  }

  Widget _commentLikeButton(String commentId, int videoId, int userId) {
    return StreamBuilder<DocumentSnapshot>(
      // Listen to the comment for the total count
      stream: FirebaseFirestore.instance
          .collection('videos')
          .doc(videoId.toString())
          .collection('comments')
          .doc(commentId)
          .snapshots(),
      builder: (context, commentSnapshot) {
        var data = commentSnapshot.data?.data() as Map<String, dynamic>?;
        int likesCount = data?['likes_count'] ?? 0;

        return StreamBuilder<DocumentSnapshot>(
          // Listen to see if THIS user liked THIS specific comment
          stream: FirebaseFirestore.instance
              .collection('videos')
              .doc(videoId.toString())
              .collection('comments')
              .doc(commentId)
              .collection('likes')
              .doc(userId.toString())
              .snapshots(),
          builder: (context, userLikeSnapshot) {
            bool isLiked = userLikeSnapshot.data?.exists ?? false;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => CommentLikeService().toggleCommentLike(
                    videoId,
                    commentId,
                    userId,
                  ),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  likesCount > 0 ? likesCount.toString() : "",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _commentTile(
    String name,
    String text,
    String time,
    int likes,
    String commentId,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$name • $time",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(text, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // const Icon(
                        //   Icons.thumb_up_outlined,
                        //   size: 14,
                        //   color: Colors.grey,
                        // ),
                        // const SizedBox(width: 4),

                        // Text(
                        //   "$likes",
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        if (currentuser.value.user?.id != null)
                          _commentLikeButton(
                            commentId,
                            widget.video.id,
                            currentuser.value.user?.id ?? 0,
                          ), // Pass current user ID
                        const SizedBox(width: 15),
                        const SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            setState(() {
                              replyingToId = commentId;
                              replyingToName = name;
                            });
                          },
                          child: const Text(
                            "Reply",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 40.0), // Indent replies
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('videos')
                  .doc(widget.video.id.toString())
                  .collection('comments')
                  .where('parent_id', isEqualTo: commentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const SizedBox();

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    Timestamp? ts = data['time'] as Timestamp?;
                    String timeStr = ts != null
                        ? _formatTimestamp(ts)
                        : "Just now";
                    return _commentTile(
                      data['username'],
                      data['comment'],
                      timeStr,
                      0,
                      doc.id,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Separate widget for the modal to manage its own state/keyboard padding
class _FullCommentsModal extends StatelessWidget {
  final Color brandGreen;
  const _FullCommentsModal({required this.brandGreen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "No comments yet.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          _buildCommentInput(context, cardColor),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context, Color cardColor) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type something...",
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send_rounded, color: brandGreen),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class VideoReportsReviewWidget extends StatelessWidget {
  final List<VideoReviewModel> reports;

  const VideoReportsReviewWidget({super.key, required this.reports});

  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Full Screen Blur Background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: primaryDark.withOpacity(0.85)),
            ),
          ),

          // 2. The Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: reports.isEmpty
                      ? _buildEmptyState()
                      : _buildReportsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Video Reports",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${reports.length} total flags submitted",
                style: TextStyle(color: brandGreen, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(VideoReviewModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: brandGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.reason?.toUpperCase() ?? "OTHER",
                  style: TextStyle(
                    color: brandGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _formatDate(report.createdAt),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.description ?? "No additional comments provided.",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.05)),
          Text(
            "User ID: ${report.userId}",
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: brandGreen.withOpacity(0.3),
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            "No Reports Found",
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Unknown";
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

class ViewReportsButton extends StatelessWidget {
  final VoidCallback onTap;
  final int reportCount;

  const ViewReportsButton({
    super.key,
    required this.onTap,
    this.reportCount = 0,
  });

  final Color brandGreen = const Color(0xFF00D285);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.flag_outlined, color: brandGreen, size: 20),
              label: const Text(
                "VIEW REPORTS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                backgroundColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),

        // Notification Badge (Only shows if there are reports)
        if (reportCount > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                reportCount > 99 ? '99+' : '$reportCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class ViewEarningsButton extends StatelessWidget {
  final VoidCallback onTap;
  final int reportCount;

  const ViewEarningsButton({
    super.key,
    required this.onTap,
    this.reportCount = 0,
  });

  final Color brandGreen = const Color(0xFF00D285);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.money, color: brandGreen, size: 20),
              label: const Text(
                "VIEW EARNINGS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                backgroundColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VideoEarningsSheet extends StatelessWidget {
  final double totalEarnings;
  final int totalSales;
  final double monthlyEarnings;
  final int monthlySales;

  const VideoEarningsSheet({
    super.key,
    required this.totalEarnings,
    required this.totalSales,
    required this.monthlyEarnings,
    required this.monthlySales,
  });

  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryDark.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 25),

                _buildHeader(),
                const SizedBox(height: 30),

                // Lifetime Section
                _buildSectionTitle("LIFETIME PERFORMANCE"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        "Total Earnings",
                        "\$${totalEarnings.toStringAsFixed(2)}",
                        Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        "Total Sales",
                        "$totalSales",
                        Icons.shopping_bag_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Monthly Section
                _buildSectionTitle("THIS MONTH"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        "Earnings",
                        "\$${monthlyEarnings.toStringAsFixed(2)}",
                        Icons.trending_up_rounded,
                        color: brandGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        "Sales",
                        "$monthlySales",
                        Icons.analytics_rounded,
                        color: brandGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                _buildCloseButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white10,
          child: Icon(Icons.insights_rounded, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Text(
          "Revenue Insights",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Colors.white38, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "CLOSE",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
