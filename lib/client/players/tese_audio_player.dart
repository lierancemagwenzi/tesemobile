import 'dart:async';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:smacredit/client/downloads/downloaddb.dart';
import 'package:smacredit/client/downloads/permissions.dart';
import 'package:smacredit/client/downloads/service.dart';
import 'package:smacredit/client/models/downloadlink.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/libary/add_to_playlist.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/players/ad_overlay.dart';
import 'package:smacredit/client/players/global_audio_player.dart';
import 'package:smacredit/client/respository/client_repositoy.dart';
import 'package:smacredit/client/services/comment_like.dart';
import 'package:smacredit/client/services/comment_service.dart';
import 'package:smacredit/main.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';

class TeseAudioPlayerScreen extends StatefulWidget {
  // final Video video;
  // // final MediaResponse mediaResponse;
  // List<Video> videos;
  // List<AdModel> ads;
  TeseAudioPlayerScreen({
    super.key,
    // required this.video,
    // // required this.mediaResponse,
    // this.videos = const [],
    // this.ads = const [],
  });

  @override
  StateMVC<TeseAudioPlayerScreen> createState() =>
      _TeseAudioPlayerScreenState();
}

class _TeseAudioPlayerScreenState extends StateMVC<TeseAudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    teseAudioHandler.updatePlayerVisibility(true);
    if (kDebugMode) {
      print("initState");
    }
    if (kDebugMode) {
      print("output is ${teseAudioHandler.currentVideo?.output}");
    }

    fetchSignedCookies().then((value) {
      getMedia();
    });
    _loadExistingDownloads();

    _positionSubscription = AudioService.position.listen((position) {
      final duration =
          teseAudioHandler.mediaItem.value?.duration ?? Duration.zero;
      if (duration.inMilliseconds == 0) return;

      final currentId = teseAudioHandler.currentVideo?.id;

      // Reset flag when the track changes
      if (currentId != _trackedVideoId) {
        _viewSent = false;
        _trackedVideoId = currentId;
      }

      if (!_viewSent) {
        final percentage = position.inMilliseconds / duration.inMilliseconds;
        if (percentage >= 0.1) {
          _sendVideoView();
        }
      }
    });
  }

  double? _dragValue;
  bool _showComments = false;
  String? replyingToId;
  String? replyingToName;
  final TextEditingController _commentController = TextEditingController();

  bool _viewSent = false;
  int? _trackedVideoId; // track which video the view was sent for
  StreamSubscription? _positionSubscription;

  // Cached comment streams — recreated only when videoId changes
  int? _commentStreamVideoId;
  Stream<QuerySnapshot>? _commentsCountStream;
  Stream<QuerySnapshot>? _commentsListStream;

  void _ensureCommentStreams(int videoId) {
    if (_commentStreamVideoId == videoId) return;
    _commentStreamVideoId = videoId;
    final topLevelQuery = FirebaseFirestore.instance
        .collection('videos')
        .doc(videoId.toString())
        .collection('comments')
        .where('parent_id', isEqualTo: "--");
    _commentsCountStream = topLevelQuery.snapshots();
    _commentsListStream = topLevelQuery.snapshots();
  }

  @override
  void dispose() {
    teseAudioHandler.updatePlayerVisibility(false);
    _commentController.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  MediaResponse? media;

  late ClientUserController _con;

  _TeseAudioPlayerScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }
  getMedia() async {
    if (teseAudioHandler.videos.isNotEmpty) {
      int index = teseAudioHandler.videos.indexWhere(
        (video) => video.id == teseAudioHandler.currentVideo?.id,
      );

      if (index != -1) {
        if (kDebugMode) {
          print('The video is at index: $index');
        }
        teseAudioHandler.startPlaylist(
          teseAudioHandler.videos,
          initialIndex: index,
          ads: teseAudioHandler.ads,
        );
        // Output: The video is at index: 1
      } else {
        print('Video not found in the list.');
        Navigator.pop(context);
      }
    } else {
      _setupAndPlay();
    }
    // MediaResponse? mediaa = widget.mediaResponse;
    // setState(() {
    //   media = mediaa;
    // });
    // if (mediaa.hasAccess == true) {
    // teseAudioHandler.setAdSchedule(mediaa?.ads ?? []);

    //   print(mediaa.ads.length);
    // } else {}
  }

  Future<void> _sendVideoView() async {
    final videoId = teseAudioHandler.currentVideo?.id;
    if (videoId == null) return;
    _viewSent = true; // set immediately to prevent duplicate calls
    try {
      final data = await _con.logView(videoId);
      if (data != null) {
        setState(() {
          _con.videoStatsModel = data;
        });
      }
      if (kDebugMode) {
        print("Tese View Tracked: Audio $videoId");
      }
    } catch (e) {
      _viewSent = false; // reset so it can retry
      if (kDebugMode) {
        print("Error tracking audio view: $e");
      }
    }
  }

  Future<void> _setupAndPlay() async {
    try {
      // 1. Check if something is already playing and stop it
      if (teseAudioHandler.playbackState.value.playing) {
        // await teseAudioHandler.stop();
      }
      // https: //www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3
      await teseAudioHandler.initAudioSession();
      // 2. Load the new video.output as audio
      await teseAudioHandler.loadAudio(
        teseAudioHandler.currentVideo?.output ?? "",
        teseAudioHandler.currentVideo?.id ?? 0,
        teseAudioHandler.currentVideo?.title ?? "Tese Audio",
        artist: "Tese Africa",
        artUrl: teseAudioHandler.currentVideo?.thumbnailUrl,
        // ads: teseAudioHandler.ads,
      );

      // 3. Start playback immediately
      ;
    } catch (e) {
      debugPrint("Final attempt error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<MediaItem?>(
      stream: teseAudioHandler.mediaItem,
      builder: (context, snapshot) {
        if (kDebugMode) {
          print("Stream Snapshot: ${snapshot.data}");
        } // Debug here
        final mediaItem = snapshot.data;

        // Show a styled loader while the initState logic is finishing
        if (mediaItem == null) {
          return Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.white,
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text("Media item is null"),
                  Center(
                    child: CircularProgressIndicator(color: Color(0xFF00D285)),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: [
              if (teseAudioHandler.currentVideo != null)
                IconButton(
                  icon: const Icon(LucideIcons.listPlus),
                  onPressed: () {
                    // Just pass the current context and the video object
                    AddToPlaylistSheet.show(
                      context,
                      teseAudioHandler.currentVideo!,
                    );
                  },
                ),
            ],
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white : Colors.black,
                size: 35,
              ),

              onPressed: () {
                if (_showComments) {
                  setState(() => _showComments = false);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: ValueListenableBuilder<AdModel?>(
            valueListenable: teseAudioHandler.activeAd,
            builder: (context, ad, _) {
              print("ad_is ${ad}");
              if (ad != null) {
                return TeseVideoAdOverlay(
                  ad: ad,
                  onAdComplete: () {
                    // Log view to your backend here using ad.id
                    teseAudioHandler.resumeAfterAd(
                      teseAudioHandler.currentVideo?.output ?? "",
                    );
                  },
                );
              }

              return Stack(
                children: [
                  // 1. Blurred Background
                  Positioned.fill(
                    child: Image.network(
                      mediaItem.artUri.toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.black),
                    ),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        color: isDark
                            ? Colors.black.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),

                  // 2. Main Content
                  SafeArea(
                    child: Column(
                      children: [
                        const Spacer(),
                        _buildArtwork(context, mediaItem),
                        const Spacer(),
                        _buildMetadata(isDark, mediaItem),
                        const SizedBox(height: 40),
                        _buildProgressBar(isDark, mediaItem),
                        const SizedBox(height: 20),
                        _buildControls(isDark, mediaItem),
                        const SizedBox(height: 16),
                        _buildCommentButton(isDark),
                        const SizedBox(height: 12),
                        _buildDownloadButton(isDark),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),

                  // 3. Comments overlay
                  if (_showComments) _buildCommentsSection(isDark),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildArtwork(BuildContext context, MediaItem mediaItem) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(mediaItem.artUri.toString(), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildMetadata(bool isDark, MediaItem mediaItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mediaItem.artist ?? "Unknown Title",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            mediaItem.title,
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark, MediaItem mediaItem) {
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration =
            teseAudioHandler.mediaItem.value?.duration ?? Duration.zero;

        // Use the drag value if it exists, otherwise use the stream position
        double currentPosition =
            _dragValue ?? position.inMilliseconds.toDouble();
        double totalDuration = duration.inMilliseconds.toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: SliderComponentShape.noThumb,
                  activeTrackColor: const Color(0xFF00D285),
                  inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                ),
                child: Slider(
                  min: 0,
                  max: totalDuration,
                  value: currentPosition.clamp(0, totalDuration),
                  // 1. Update local state while dragging
                  onChanged: (val) {
                    setState(() {
                      _dragValue = val;
                    });
                  },
                  // 2. Only seek and clear local state when the user lets go
                  onChangeEnd: (val) {
                    teseAudioHandler.seek(Duration(milliseconds: val.toInt()));
                    _dragValue = null;
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // Update the timestamp text to match the drag position
                      _formatDuration(
                        _dragValue != null
                            ? Duration(milliseconds: _dragValue!.toInt())
                            : position,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(bool isDark, MediaItem mediaItem) {
    return StreamBuilder<PlaybackState>(
      stream: teseAudioHandler.playbackState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;

        // Get current modes
        final repeatMode = state?.repeatMode ?? AudioServiceRepeatMode.none;
        final shuffleMode = state?.shuffleMode ?? AudioServiceShuffleMode.none;

        final baseColor = isDark ? Colors.white : Colors.black;
        final activeColor = Colors.orange; // Color when shuffle/repeat is ON

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle Button
            IconButton(
              icon: Icon(
                shuffleMode == AudioServiceShuffleMode.all
                    ? Icons.shuffle_on_rounded
                    : Icons.shuffle,
                color: shuffleMode == AudioServiceShuffleMode.all
                    ? activeColor
                    : baseColor,
              ),
              onPressed: () {
                final newMode = shuffleMode == AudioServiceShuffleMode.all
                    ? AudioServiceShuffleMode.none
                    : AudioServiceShuffleMode.all;
                teseAudioHandler.setShuffleMode(newMode);
              },
            ),

            IconButton(
              iconSize: 45,
              icon: Icon(Icons.skip_previous_rounded, color: baseColor),
              onPressed: teseAudioHandler.skipToPrevious,
            ),

            // Play/Pause
            GestureDetector(
              onTap: playing ? teseAudioHandler.pause : teseAudioHandler.play,
              child: Container(
                height: 85,
                width: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: baseColor,
                ),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 50,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),

            IconButton(
              iconSize: 45,
              icon: Icon(Icons.skip_next_rounded, color: baseColor),
              onPressed: teseAudioHandler.skipToNext,
            ),

            // Repeat Button
            IconButton(
              icon: Icon(
                repeatMode == AudioServiceRepeatMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat,
                color: repeatMode != AudioServiceRepeatMode.none
                    ? activeColor
                    : baseColor,
              ),
              onPressed: () {
                print("pressed2");
                // Simple toggle: None -> All -> One -> None
                AudioServiceRepeatMode nextMode;
                if (repeatMode == AudioServiceRepeatMode.none) {
                  nextMode = AudioServiceRepeatMode.all;
                } else if (repeatMode == AudioServiceRepeatMode.all) {
                  nextMode = AudioServiceRepeatMode.one;
                } else {
                  nextMode = AudioServiceRepeatMode.none;
                }
                teseAudioHandler.setRepeatMode(nextMode);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) =>
      "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  /// Checks the DB for the actual saved fileName, then verifies it exists on disk.
  /// This is reliable regardless of file extension (.mp3, .mp4, etc.).
  Future<bool> _isActuallyDownloaded(int videoId) async {
    final db = await DownloadDB.database;
    final rows = await db.query(
      'tasks',
      columns: ['fileName'],
      where: 'videoId = ?',
      whereArgs: [videoId],
    );
    if (rows.isEmpty) return false;
    final fileName = rows.first['fileName'] as String?;
    if (fileName == null || fileName.isEmpty) return false;
    return DownloadService.checkIfFileExists(fileName);
  }

  Future<void> _loadExistingDownloads() async {
    final savedTasks = await DownloadDB.getAllTasks();
    DownloadService.videoToTaskMapping = savedTasks;
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

  Future<void> _startSecureDownload(
    BuildContext context,
    VideoDownloadLink link,
    Video video,
  ) async {
    final hasPermission = await TesePermissions.checkStoragePermission();
    if (hasPermission) {
      final url = link.link ?? "";
      final urlPath = Uri.tryParse(url)?.path ?? '';
      final dotIndex = urlPath.lastIndexOf('.');
      final ext = dotIndex != -1 ? urlPath.substring(dotIndex) : '.mp3';
      final fileName = '${video.slug}_${video.id}$ext';

      await DownloadService.requestDownload(
        url,
        video.id,
        video.title ?? "",
        fileName,
        type: 'music',
        artist: video.artist?.fullname,
        album: video.playlist?.title,
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Permission denied. We need storage access to save audio for offline listening.",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  Widget _buildDownloadButton(bool isDark) {
    final video = teseAudioHandler.currentVideo;
    if (video == null) return const SizedBox.shrink();

    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: DownloadService.downloadProgress,
      builder: (context, progressMap, child) {
        final String? taskId = DownloadService.videoToTaskMapping[video.id];
        final int progress = (taskId != null) ? (progressMap[taskId] ?? 0) : 0;

        if (progress == 100) {
          return FutureBuilder<bool>(
            future: _isActuallyDownloaded(video.id),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return _buildStatusBadge(
                  Icons.check_circle,
                  "Downloaded",
                  const Color(0xFF00D285),
                );
              }
              return _buildDownloadIconButton(video);
            },
          );
        }

        // Also show "Downloaded" for files saved in a previous session
        // (task may be complete but not in current progress map)
        if (taskId == null) {
          return FutureBuilder<bool>(
            future: _isActuallyDownloaded(video.id),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return _buildStatusBadge(
                  Icons.check_circle,
                  "Downloaded",
                  const Color(0xFF00D285),
                );
              }
              return _buildDownloadIconButton(video);
            },
          );
        }

        if (taskId != null && progress > 0 && progress < 100) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress / 100,
                color: const Color(0xFF00D285),
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

        return _buildDownloadIconButton(video);
      },
    );
  }

  Widget _buildDownloadIconButton(Video video) {
    return GestureDetector(
      onTap: () async {
        VideoDownloadLink? link = await _con.getDownloadLink(video.id);
        if (link != null && mounted) {
          await _startSecureDownload(context, link, video);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.file_download_outlined,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 6),
          const Text(
            'Download',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentButton(bool isDark) {
    final videoId = teseAudioHandler.currentVideo?.id;
    if (videoId == null) return const SizedBox.shrink();
    _ensureCommentStreams(videoId);
    return StreamBuilder<QuerySnapshot>(
      stream: _commentsCountStream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return GestureDetector(
          onTap: () => setState(() => _showComments = true),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: isDark ? Colors.white60 : Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '$count comments',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection(bool isDark) {
    final videoId = teseAudioHandler.currentVideo?.id;
    if (videoId == null) return const SizedBox.shrink();
    _ensureCommentStreams(videoId);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _commentsCountStream,
            builder: (context, snapshot) {
              final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return SafeArea(
                child: Padding(
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
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _commentController,
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty) {
                        UtilsHelper.ensureAuth(
                          context,
                          action: "to add a comment",
                          onAuthenticated: () {
                            CommentService().postComment(
                              videoId,
                              currentuser.value.user?.id ?? 0,
                              currentuser.value.user?.fullname ?? 'tese user',
                              value,
                              parentCommentId: replyingToId,
                            );
                            setState(() {
                              replyingToId = null;
                              replyingToName = "";
                              _commentController.clear();
                            });
                          },
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      filled: true,
                      labelText:
                          replyingToName != null &&
                              replyingToName!.isNotEmpty &&
                              replyingToId?.isNotEmpty == true
                          ? "Replying to $replyingToName"
                          : null,
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _commentsListStream,
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
                    final String name = data['username'] ?? 'Tese User';
                    final String text = data['comment'] ?? '';
                    final Timestamp? ts = data['time'] as Timestamp?;
                    final String timeStr = ts != null
                        ? _formatTimestamp(ts)
                        : "Just now";
                    final String id = snapshot.data!.docs[index].id;
                    return _commentTile(videoId, name, text, timeStr, id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentTile(
    int videoId,
    String name,
    String text,
    String time,
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
                        if (currentuser.value.user?.id != null)
                          _commentLikeButton(
                            commentId,
                            videoId,
                            currentuser.value.user!.id!,
                          ),
                        const SizedBox(width: 15),
                        InkWell(
                          onTap: () => setState(() {
                            replyingToId = commentId;
                            replyingToName = name;
                          }),
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
            padding: const EdgeInsets.only(left: 40.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('videos')
                  .doc(videoId.toString())
                  .collection('comments')
                  .where('parent_id', isEqualTo: commentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox();
                }
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final Timestamp? ts = data['time'] as Timestamp?;
                    final String timeStr = ts != null
                        ? _formatTimestamp(ts)
                        : "Just now";
                    return _commentTile(
                      videoId,
                      data['username'],
                      data['comment'],
                      timeStr,
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
      stream: FirebaseFirestore.instance
          .collection('videos')
          .doc(videoId.toString())
          .collection('comments')
          .doc(commentId)
          .snapshots(),
      builder: (context, commentSnapshot) {
        final data = commentSnapshot.data?.data() as Map<String, dynamic>?;
        final int likesCount = data?['likes_count'] ?? 0;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('videos')
              .doc(videoId.toString())
              .collection('comments')
              .doc(commentId)
              .collection('likes')
              .doc(userId.toString())
              .snapshots(),
          builder: (context, userLikeSnapshot) {
            final bool isLiked = userLikeSnapshot.data?.exists ?? false;
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

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());
    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    return "${difference.inDays}d ago";
  }
}
