import 'package:better_player_plus/better_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/downloads/downloaddb.dart';
import 'package:smacredit/client/downloads/permissions.dart';
import 'package:smacredit/client/downloads/service.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/client/players/media_loader.dart';
import 'package:smacredit/client/players/premium_widget.dart';
import 'package:smacredit/client/services/comment_like.dart';
import 'package:smacredit/client/services/comment_service.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/video_stats_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';

class TeseVideoPlayerWidget extends StatefulWidget {
  final Video video;
  // final Channel channel;

  // final Playlist playlist;
  const TeseVideoPlayerWidget({
    super.key,
    // required this.channel,
    required this.video,
    // required this.playlist,
  });

  @override
  StateMVC<TeseVideoPlayerWidget> createState() =>
      _TeseVideoPlayerWidgetState();
}

class _TeseVideoPlayerWidgetState extends StateMVC<TeseVideoPlayerWidget> {
  late BetterPlayerController _betterPlayerController;
  bool _showComments = false; // Toggle state for comments
  String? replyingToId; // Store the ID of the comment being replied to
  String? replyingToName;
  TextEditingController _controller = TextEditingController();
  final Color brandRed = const Color(0xFFFF3B30);
  final Color brandGreen = const Color(0xFF00D285);

  bool hasFetched = false;

  MediaResponse? media;

  bool _viewSent = false; // Flag to prevent multiple API calls

  void _setupViewTracker() {
    _betterPlayerController.addEventsListener((BetterPlayerEvent event) {
      // Only track if we haven't sent the view yet
      final Duration? progress = event.parameters?['progress'] as Duration?;
      final Duration? totalDuration =
          event.parameters?['duration'] as Duration?;

      if (!_viewSent &&
          progress != null &&
          totalDuration != null &&
          totalDuration.inMilliseconds > 0) {
        // 2. Calculate the percentage
        double percentage =
            progress.inMilliseconds / totalDuration.inMilliseconds;

        // 3. Trigger at 50% (0.5)
        if (percentage >= 0.1) {
          _sendVideoView();
        }
      }
    });
  }

  Future<void> _sendVideoView() async {
    try {
      VideoStatsModel? data = await _con.logView(widget.video.id);

      if (data != null) {
        setState(() {
          _con.videoStatsModel = data;
          _viewSent = true; // Mark as sent immediately to avoid duplicate calls
        });
      }

      print("Tese View Tracked: Video ${widget.video.id} watched for 20s");
    } catch (e) {
      _viewSent = false; // Reset if the API call fails so it can retry
      print("Error tracking view: $e");
    }
  }

  Future<void> _sendVideoLike() async {
    try {
      VideoStatsModel? data = await _con.logLike(widget.video.id);
      if (data != null) {
        setState(() {
          _con.videoStatsModel = data;
        });
      }
      // print("Tese View Tracked: Video ${widget.video.id} watched for 20s");
    } catch (e) {
      // _viewSent = false; // Reset if the API call fails so it can retry
      // print("Error tracking view: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getMedia();
    _con.listenForVideoStats(widget.video.id);
    _loadExistingDownloads();

    // _con.listenForChannelPlaylists(widget.channel.id);
    _con.listenForChannel(widget.video.channelId ?? 0);

    _con.listenForPlaylistVideos(widget.video.playlistId ?? 0);
  }

  late ClientUserController _con;

  _TeseVideoPlayerWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  getMedia() async {
    MediaResponse? mediaa = await _con.getMedia(widget.video.id);
    setState(() {
      hasFetched = true;
      media = mediaa;
    });
    if (mediaa != null) {
      if (mediaa.hasAccess) {
        _setupPlayer();
      } else {}
    } else {}
  }

  Future<void> _loadExistingDownloads() async {
    // 1. Fetch mapping from DB
    final savedTasks = await DownloadDB.getAllTasks();

    // 2. Update the Service mapping
    DownloadService.videoToTaskMapping = savedTasks;

    // 3. Sync with FlutterDownloader to get actual current status
    final allTasks = await FlutterDownloader.loadTasks();

    if (allTasks != null) {
      final newProgressMap = Map<String, int>.from(
        DownloadService.downloadProgress.value,
      );
      for (var task in allTasks) {
        newProgressMap[task.taskId] = task.progress;
      }
      DownloadService.downloadProgress.value = newProgressMap;
    }
  }

  void _setupPlayer() {
    final BetterPlayerControlsConfiguration controlsConfiguration =
        BetterPlayerControlsConfiguration(
          progressBarPlayedColor: brandRed,

          progressBarHandleColor: brandRed,
          loadingColor: brandGreen,
          controlBarColor: Colors.black.withOpacity(0.3),
        );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: false,
        fit: BoxFit.contain,
        controlsConfiguration: controlsConfiguration,
      ),
    );

    _betterPlayerController.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.video.output ?? "",
      ),
    );

    _setupViewTracker();
  }

  void _showVideoPurchaseOptions(Video video) async {
    final PaymentSelection? result =
        await showModalBottomSheet<PaymentSelection>(
          context: context,
          isScrollControlled: true, // Important for the keyboard
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => const PaymentModal(),
        );

    if (result != null) {
      print("Selected: ${result.method}");
      if (result.ecoCashNumber != null) {
        print("EcoCash Number: ${result.ecoCashNumber}");
      }

      Map map = {
        "wallet": "Visa",
        "amount": video.price ?? 1,
        "currency": "USD",
        "paymentDescription": "Video Purchase payment",
        "payer": "${currentuser.value.user?.fullname}",
        "user_id": currentuser.value.user?.id,
        "video_id": video.id,
        "payerMobile": result.ecoCashNumber ?? "",
      };
      PaymentResponseWrapper? res = await _con.buyVideo(map);

      if (res != null) {
        if (result.method.toLowerCase() == 'visa' ||
            result.method.toLowerCase() == 'mastercard') {
          Navigator.pushNamed(
            context,
            '/VisaMastercardPayment',
            arguments:
                res.response?.paymentInitiationResponse?.paymentCode ?? "",
          ).then((e) {
            getMedia();
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            getMedia();
          });
        }
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          context,
          "Something went wrong.Try again",
        );
      }

      // TODO: Trigger your Paynow / Paynow_flutter integration here
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: !hasFetched || media == null
          ? TeseMediaLoader(
              onExit: () {
                Navigator.pop(context);
              },
            )
          : hasFetched && media != null && media?.hasAccess != true
          ? TesePremiumPaywall(
              onExit: () {
                Navigator.pop(context);
              },
              onPurchase: () {
                UtilsHelper.ensureAuth(
                  context,
                  action: "to purchase the video",
                  onAuthenticated: () {
                    _showVideoPurchaseOptions(widget.video);
                  },
                );
              },

              videoTitle: widget.video.title ?? "",
              price: (widget.video.price ?? 0).toString(),
              currency: widget.video.currency ?? "USD",
              thumbnailUrl: widget.video.thumbnailUrl ?? "",
            )
          : SafeArea(
              child: Column(
                children: [
                  // 1. VIDEO PLAYER
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: BetterPlayer(controller: _betterPlayerController),
                  ),

                  // 2. STACKED CONTENT (Main UI vs Comments)
                  Expanded(
                    child: Stack(
                      children: [
                        // MAIN UI LAYER
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.video.title ?? "",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),
                              Text(
                                widget.video.description ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),
                              _buildActionButtons(isDark),
                              const Divider(height: 40),
                              if (_con.channel != null) _buildCreatorSection(),
                              const SizedBox(height: 20),

                              if (_con.videos
                                  .where((e) => e.id != widget.video.id)
                                  .toList()
                                  .isNotEmpty) ...[
                                const Text(
                                  "Related Videos",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                ...(_con.videos).map(
                                  (e) => _buildRelatedVideo(isDark, e),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // COMMENT OVERLAY LAYER
                        if (_showComments) _buildCommentsSection(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Action Buttons with Comment Toggle
  Widget _buildActionButtons(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      // We listen to the same collection, but only for the count
      stream: FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.video.id.toString())
          .collection('comments')
          .snapshots(),
      builder: (context, snapshot) {
        // Show '0' while loading or if empty
        String count = "0";
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length.toString();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionIcon(
              _con.videoStatsModel?.liked == true
                  ? Icons.favorite
                  : Icons.favorite_border,
              "${_con.videoStatsModel?.likes ?? 0}",
              () {
                UtilsHelper.ensureAuth(
                  context,
                  action: "to purchase this video",
                  onAuthenticated: () {
                    _sendVideoLike();
                  },
                );
              },
            ),
            // TOGGLE TRIGGER
            _actionIcon(Icons.chat_bubble_outline, count, () {
              setState(() => _showComments = true);
            }),
            _actionIcon(
              Icons.visibility,
              "${_con.videoStatsModel?.views ?? 0}",
              () {},
            ),
            // _actionIcon(Icons.bookmark_border, "Save", () {}),

            // _actionIcon(Icons.file_download_outlined, "Download", () {}),
            _buildDownloadButton(const Color(0xFF00D285), isDark),
          ],
        );
      },
    );
  }

  Future<void> startSecureDownload(BuildContext context) async {
    final hasPermission = await TesePermissions.checkStoragePermission();

    print(widget.video.sourceFileUrl);
    // return;fa

    if (hasPermission) {
      int videoId = widget.video.id!;
      // Proceed with your existing download logic
      await DownloadService.requestDownload(
        widget.video.sourceFileUrl ?? "",
        videoId,
        widget.video.title ?? "",
        widget.video.getFileName,
      );
    } else {
      // Explain to the user why it failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Permission denied. We need storage access to save videos for offline viewing.",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Optional: Open app settings so they can enable it manually
      // await openAppSettings();
    }
  }

  Widget _buildStatusBadge(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return InkWell(
      onTap: () async {
        await startSecureDownload(context);
      },
      child: Column(
        children: [
          Icon(Icons.file_download_outlined, color: Colors.grey),
          Text(
            'Download',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(Color teseGreen, bool isDark) {
    int videoId = (widget.video.id);
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: DownloadService.downloadProgress,
      builder: (context, progressMap, child) {
        // Check if this specific video is currently downloading
        String? taskId = DownloadService.videoToTaskMapping[videoId];

        // 2. Look up the progress using that Task ID
        int progress = (taskId != null) ? (progressMap[taskId] ?? 0) : 0;

        // 3. Determine if we should show the progress or the button
        bool isDownloading = taskId != null && progress >= 0 && progress < 100;

        print(progress);

        if (progress == 100) {
          return FutureBuilder<bool>(
            future: DownloadService.checkIfFileExists(widget.video.getFileName),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return _buildStatusBadge(
                  Icons.check_circle,
                  "Downloaded",
                  teseGreen,
                );
              }
              // If progress is 100 but file is missing, show the download button again
              return _buildActionButton();
            },
          );
        }
        if (taskId != null && progress > 0 && progress < 100) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Circular Progress matching Tese Green
              CircularProgressIndicator(
                value: progress / 100,
                color: teseGreen,
                strokeWidth: 3,
              ),
              Text(
                "$progress%",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          );
        }

        return _buildActionButton();
        return Container(
          width: 100,
          height: 40,
          child: isDownloading
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular Progress matching Tese Green
                    CircularProgressIndicator(
                      value: progress / 100,
                      color: teseGreen,
                      strokeWidth: 3,
                    ),
                    Text(
                      "$progress%",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                )
              : 1 == 1
              ? InkWell(
                  onTap: () async {
                    // await startSecureDownload(context, "$videoId.mp4");
                  },
                  child: Column(
                    children: [
                      Icon(Icons.file_download_outlined, color: Colors.grey),
                      Text(
                        'Download',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: () async {
                    // Trigger the download
                    // await startSecureDownload(context, "$videoId.mp4");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teseGreen,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Purchase',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
        );
      },
    );
  }

  createDownloadDirectory() {}

  downloadFile() async {
    final taskId = await FlutterDownloader.enqueue(
      url: widget.video.output ?? "",
      headers: {}, // optional: header send with url (auth token etc)
      savedDir: 'the path of directory where you want to save downloaded files',
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          false, // click on notification to open downloaded file (for Android)
    );
  }

  Widget _buildCommentsSection(bool isDark) {
    return Container(
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

  // Helper to format the Firestore Timestamp
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    return "${difference.inDays}d ago";
  }

  Widget _buildCommentsSection1(bool isDark) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header with Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Comments (234)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showComments = false),
                ),
              ],
            ),
          ),
          const Divider(),
          // Input Box
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        CommentService().postComment(
                          widget.video.id,
                          currentuser.value.user?.id ?? 0,
                          currentuser.value.user?.fullname ?? 'tese user',
                          value,
                        );

                        _controller.clear();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      filled: true,

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

          // Scrollable Comments List
        ],
      ),
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

  // --- Helper Widgets from Previous Design ---
  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.grey),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCreatorSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(_con.channel?.logoUrl ?? ""),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _con.channel?.name ?? "",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_con.channel?.shouldShowButton['status'] == 'not_subscribed') {
              UtilsHelper.ensureAuth(
                context,
                action: "to subscribe to channel",
                onAuthenticated: () {
                  _showPurchaseOptions(_con.channel!);
                },
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _con.channel?.shouldShowButton['positive'] == true
                ? brandGreen
                : brandRed,
            shape: const StadiumBorder(),
          ),
          child: Text(
            _con.channel?.shouldShowButton['message'] ?? "",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedVideo(bool isDark, Video video) {
    return video.id == widget.video.id
        ? SizedBox(height: 0, width: 0)
        : InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/Player',
                arguments: {'video': video, 'channel': _con.channel},
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        UtilsHelper.formatLongDuration(
                          video.durationSeconds ?? 0,
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  void _showPurchaseOptions(Channel video) async {
    final PaymentSelection? result =
        await showModalBottomSheet<PaymentSelection>(
          context: context,
          isScrollControlled: true, // Important for the keyboard
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => const PaymentModal(),
        );

    if (result != null) {
      print("Selected: ${result.method}");
      if (result.ecoCashNumber != null) {
        print("EcoCash Number: ${result.ecoCashNumber}");
      }

      Map map = {
        "wallet": "Visa",
        "amount": video.subscriptionPrice ?? 1,
        "currency": "USD",
        "paymentDescription": "Channel  subscription payment",
        "payer": "${currentuser.value.user?.fullname}",
        "user_id": currentuser.value.user?.id,
        "channel_id": video.id,
        "payerMobile": result.ecoCashNumber ?? "",
      };
      PaymentResponseWrapper? res = await _con.buyChannel(map);

      if (res != null) {
        if (result.method.toLowerCase() == 'visa' ||
            result.method.toLowerCase() == 'mastercard') {
          Navigator.pushNamed(
            context,
            '/VisaMastercardPayment',
            arguments:
                res.response?.paymentInitiationResponse?.paymentCode ?? "",
          ).then((e) {
            _con.listenForChannel(widget.video.channelId ?? 0);
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            _con.listenForChannel(widget.video.channelId ?? 0);
          });
        }
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          context,
          "Something went wrong.Try again",
        );
      }

      // TODO: Trigger your Paynow / Paynow_flutter integration here
    }
  }
}
