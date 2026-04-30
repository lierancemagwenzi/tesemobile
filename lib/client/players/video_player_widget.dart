import 'dart:ui';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/playlist.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/downloads/downloaddb.dart';
import 'package:smacredit/client/downloads/permissions.dart';
import 'package:smacredit/client/downloads/service.dart';
import 'package:smacredit/client/models/downloadlink.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/client/payments/widgets/payment_widget.dart';
import 'package:smacredit/client/payments/widgets/qr_code_payment.dart';
import 'package:smacredit/client/players/ad_warning.dart';
import 'package:smacredit/client/players/contact_form.dart';
import 'package:smacredit/client/players/custom_dialog.dart';
import 'package:smacredit/client/players/media_loader.dart';
import 'package:smacredit/client/players/premium_widget.dart';
import 'package:smacredit/client/players/tese_overlay.dart';
import 'package:smacredit/client/respository/client_repositoy.dart';
import 'package:smacredit/client/services/comment_like.dart';
import 'package:smacredit/client/services/comment_service.dart';
import 'package:smacredit/main.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/models/content_rating.dart';
import 'package:smacredit/src/content-creator/models/video_stats_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:url_launcher/url_launcher.dart';

class TeseVideoPlayerWidget extends StatefulWidget {
  final Video video;
  final MediaResponse media;
  // final Channel channel;

  // final Playlist playlist;
  const TeseVideoPlayerWidget({
    super.key,
    // required this.channel,
    required this.video,
    required this.media,
    // required this.playlist,
  });

  @override
  StateMVC<TeseVideoPlayerWidget> createState() =>
      _TeseVideoPlayerWidgetState();
}

class _TeseVideoPlayerWidgetState extends StateMVC<TeseVideoPlayerWidget> {
  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();
  bool _showComments = false; // Toggle state for comments
  String? replyingToId; // Store the ID of the comment being replied to
  String? replyingToName;
  TextEditingController _controller = TextEditingController();
  final Color brandRed = const Color(0xFFFF3B30);
  final Color brandGreen = const Color(0xFF00D285);
  bool hasInitialised = false;
  bool _isAdPlaying = true;
  bool _canSkip = false;
  int _skipCount = 5;
  AdModel? _currentAd;

  int _nextAdIndex = 0;
  AdModel? _nextAd; // The ad we are currently "watching" for
  bool _showingAdWarning = false;

  Duration _lastPosition = Duration.zero;
  final List<AdModel> backendAds = [];

  bool hasFetched = false;

  bool listenerAdded = false;

  MediaResponse? media;

  bool _viewSent = false; // Flag to prevent multiple API calls

  bool _hasPlayerError = false;
  String _playerErrorMessage = '';

  late Stream<QuerySnapshot> _commentsCountStream;
  late Stream<QuerySnapshot> _commentsListStream;

  void _launchAdvertiserUrl(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showContactForm(BuildContext context, AdModel ad) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContactAdvertiserForm(
        ad: ad,
        video_id: widget.video.id,
        onSubmit: (Map<String, String> formData) async {
          Navigator.pop(context);
          final res = await _con.logLead(formData);
          if (res == true) {
            CustomMessageHandler().showSuccessSnakeBar(
              _con.scaffoldKey.currentContext!,
              "Information saved successfully.Advertiser will be in touch",
            );
          } else {
            CustomMessageHandler().showErrorSnakeBar(
              _con.scaffoldKey.currentContext!,
              "Something went wrong.Try again",
            );
          }
        },
      ),
    );
  }

  void _showAdvertisersList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A), // Dark Tese theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Featured Advertisers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: backendAds.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final ad = backendAds[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        ad.brand ?? "Partner",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        ad.description ?? "View details",
                        style: const TextStyle(color: Colors.white60),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Visit Button
                          IconButton(
                            icon: const Icon(
                              Icons.public,
                              color: Color(0xFF00D285),
                            ),
                            onPressed: () {
                              _con.logClick({
                                "video_id": widget.video.id,
                                "ad_id": ad.id,
                                "user_id": currentuser.value.user?.id ?? 0,
                                "click_type": "web",
                              });
                              _launchAdvertiserUrl(ad.advertiserActionUrl);
                            },
                          ),
                          // Contact Button
                          IconButton(
                            icon: const Icon(
                              Icons.mail_outline,
                              color: Colors.white,
                            ),
                            onPressed: () => _showContactForm(context, ad),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBetterPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
      print(event.parameters);
      if (event.parameters == null) return;
      if (_betterPlayerController.videoPlayerController == null) return;
      final targetSec = (event.parameters!['duration'] as Duration).inSeconds;
      final currentSec = _betterPlayerController
          .videoPlayerController!
          .value
          .position
          .inSeconds;
      print("we are seeking to ${targetSec}");
      // Filter all ads that were skipped in this jump
      List<AdModel> skippedAds = backendAds.where((ad) {
        print("${currentSec} ${ad.playAt} ${targetSec}");
        return !ad.hasPlayed &&
            ad.playAt > currentSec &&
            ad.playAt <= targetSec;
      }).toList();

      if (skippedAds.isNotEmpty) {
        print("skipped ads not empty");
        // Option: Play the LAST one they skipped (most relevant to where they are landing)
        final adToForce = skippedAds.last;

        // Save the final destination for AFTER the ad
        _lastPosition = Duration(seconds: targetSec);

        // Mark ALL skipped ads as 'played' so they don't trigger again
        // if the user seeks backwards later.
        for (var ad in skippedAds) {
          ad.hasPlayed = true;
        }

        _injectAd(adToForce);
      } else {
        // print("skipped ads empty");
      }
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      final error =
          event.parameters?['exception']?.toString() ??
          'Unknown playback error';
      if (kDebugMode) {
        print("BetterPlayer exception for video ${widget.video.id}: $error");
      }
      setState(() {
        _hasPlayerError = true;
        _playerErrorMessage = error;
      });
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.finished &&
        !_isAdPlaying) {
      // Main video finished — reset position so replay works cleanly
      setState(() {
        _lastPosition = Duration.zero;
      });
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.finished &&
        _isAdPlaying) {
      print("finished playing ad");
      _setupPlayer(media!);
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.progress &&
        !_isAdPlaying) {
      if (_betterPlayerController.videoPlayerController == null) return;
      final currentSec = _betterPlayerController
          .videoPlayerController!
          .value
          .position
          .inSeconds;

      for (var ad in backendAds) {
        if (currentSec == ad.playAt && !ad.hasPlayed) {
          _injectAd(ad);
          break;
        }
      }

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
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.progress &&
        _isAdPlaying &&
        _currentAd != null) {
      final Duration? progress = event.parameters?['progress'] as Duration?;
      final Duration? totalDuration =
          event.parameters?['duration'] as Duration?;

      print("about to send ad view");

      if (_currentAd?.viewSent != true &&
          progress != null &&
          totalDuration != null &&
          totalDuration.inMilliseconds > 0) {
        // 2. Calculate the percentage
        double percentage =
            progress.inMilliseconds / totalDuration.inMilliseconds;

        // 3. Trigger at 50% (0.5)
        if (percentage >= 0.3) {
          _con
              .logAdView({
                "video_id": widget.video.id,
                "user_id": currentuser.value.user?.id ?? 0,
                "ad_id": _currentAd?.id,
                "watch_time": progress.inSeconds,
              })
              .then((v) {
                if (v == true && _currentAd != null) {
                  _currentAd?.markAsViewSent();
                }
              });
        }
      }
    }

    listenerAdded = true;
  }

  void _setupViewTracker() {
    if (listenerAdded == true) {
      return;
    }
    _betterPlayerController.addEventsListener(_onBetterPlayerEvent);
  }

  void _injectAd(AdModel ad) async {
    // 1. Save current spot
    _lastPosition =
        _betterPlayerController.videoPlayerController!.value.position;
    if (kDebugMode) {
      print(
        "about to set last postion to ${_betterPlayerController.videoPlayerController!.value.position}",
      );
    }
    ad.hasPlayed = true;

    setState(() {
      _isAdPlaying = true;
      _currentAd = ad;
      _showingAdWarning = false; // Now the UI knows which ad is playing
    });

    _con.logAdImpression({"video_id": widget.video.id, "ad_id": ad.id});

    int currentIndex = backendAds.indexOf(ad);

    if (currentIndex == backendAds.length - 1) {
      _nextAdIndex = 0;
    } else {
      _nextAdIndex = currentIndex + 1;
    }
    _nextAd = backendAds[_nextAdIndex];

    setState(() {});
    // 2. Load Ad Source
    await _betterPlayerController.setupDataSource(
      BetterPlayerDataSource(BetterPlayerDataSourceType.network, ad.adUrl),
    );
    _setupViewTracker();
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

      if (kDebugMode) {
        print("Tese View Tracked: Video ${widget.video.id} watched for 20s");
      }
    } catch (e) {
      _viewSent = false; // Reset if the API call fails so it can retry
      if (kDebugMode) {
        print("Error tracking view: $e");
      }
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

  stop() async {
    if (teseAudioHandler.playbackState.value.playing) {
      await teseAudioHandler.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    stop();
    fetchSignedCookies().then((value) {
      getMedia();
    });

    _con.listenForVideoStats(widget.video.id);
    _loadExistingDownloads();

    // _con.listenForChannelPlaylists(widget.channel.id);
    _con.listenForChannel(widget.video.channelId ?? 0);

    _con.listenForPlaylistVideos(widget.video.playlistId ?? 0);

    final topLevelQuery = FirebaseFirestore.instance
        .collection('videos')
        .doc(widget.video.id.toString())
        .collection('comments')
        .where('parent_id', isEqualTo: "--");
    _commentsCountStream = topLevelQuery.snapshots();
    _commentsListStream = topLevelQuery.snapshots();
  }

  late ClientUserController _con;

  _TeseVideoPlayerWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  getMedia() async {
    MediaResponse? mediaa = widget.media;
    setState(() {
      hasFetched = true;
      media = mediaa;
      backendAds.clear();
      backendAds.addAll(mediaa.ads);
    });
    if (mediaa.hasAccess) {
      _setupPlayer(mediaa);
    } else {}
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _betterPlayerController.removeEventsListener(_onBetterPlayerEvent);
    _betterPlayerController.dispose(forceDispose: true);
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse(_con.defaultLinkModel?.shortLink ?? '');
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _setupPlayer(MediaResponse media) {
    setState(() {
      _isAdPlaying = false;
      _currentAd = null;
    });
    final BetterPlayerControlsConfiguration controlsConfiguration =
        BetterPlayerControlsConfiguration(
          progressBarPlayedColor: brandRed,
          enablePip: false,
          pipMenuIcon: Icons.minimize,
          enableMute: true,

          progressBarHandleColor: brandRed,
          loadingColor: brandGreen,
          controlBarColor: Colors.black.withOpacity(0.3),
        );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        fit: BoxFit.contain,
        handleLifecycle:
            true, // Set to false to manually control the player lifecycle
        eventListener: (event) {
          if (event.betterPlayerEventType ==
              BetterPlayerEventType.initialized) {
            if (!_isAdPlaying) {
              _betterPlayerController.seekTo(_lastPosition);
              _betterPlayerController.play();
            }
          }

          if (event.betterPlayerEventType == BetterPlayerEventType.pipStart) {
            if (kDebugMode) {
              print("PiP Started Successfully");
            }
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.pipStop) {
            if (kDebugMode) {
              print("PiP Closed");
            }
          }
        },
        controlsConfiguration: controlsConfiguration,
      ),
    );

    _betterPlayerController.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.video.output ?? "",
        headers: {
          'Cookie': cloudFrontCookieNotifier.value,
          'x-playback-token': ' ${media.playbackToken}',
        },
      ),
    );

    if (kDebugMode) {
      print("last position is ${_lastPosition.inSeconds}");
    }
    _betterPlayerController.seekTo(_lastPosition);
    _betterPlayerController.play();
    if (kDebugMode) {
      print("the_link_${media.video.output ?? ""}");
      print("Cookie ${cloudFrontCookieNotifier.value}");
    }

    if (backendAds.isNotEmpty && !hasInitialised) {
      _nextAd = backendAds[0];
      _nextAdIndex = 0;
    }
    setState(() {
      hasInitialised = true;
    });
    _setupViewTracker();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      key: _con.scaffoldKey,
      body: SafeArea(
        child: Column(
          children: [
            // 1. VIDEO PLAYER
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _hasPlayerError
                      ? _buildPlayerError()
                      : hasInitialised
                      ? BetterPlayer(
                          key: _betterPlayerKey,
                          controller: _betterPlayerController,
                        )
                      : Container(color: Colors.grey),
                ),

                // if (_nextAd != null) Text(_nextAd?.brand ?? ""),
                if ((!_isAdPlaying && _nextAd != null && _nextAd!.playAt > 0))
                  TeseAdWarningWidget(
                    nextAd: _nextAd!,
                    controller: _betterPlayerController,
                  ),
                if (_isAdPlaying && _currentAd != null)
                  TeseAdOverlay(
                    ad: _currentAd!,
                    controller: _betterPlayerController,
                    onSkip: () async {
                      await _betterPlayerController.pause();
                      _setupPlayer(media!);
                    },
                  ),
              ],
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
                        if (media?.video.rating != null) ...[
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: media?.video.rating?.icon ?? "",
                                  fit: BoxFit.cover,
                                  height: 40,
                                  width: 40,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(child: Text("Age Restricted")),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                        if (backendAds.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5,
                                sigmaY: 5,
                              ), // Glassmorphism effect
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Contains Adverts",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          _showAdvertisersList(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF00D285,
                                          ).withOpacity(0.9), // Tese Green
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          "VIEW ADVERTISERS",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_isAdPlaying && _currentAd != null) ...[
                          Text(
                            _currentAd?.description ?? "",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
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
                        ],

                        if (widget.video.trailer != null) ...[
                          const Divider(height: 10),
                          TeseWatchTrailerButton(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/VideoTrailer',
                                arguments: {'video': widget.video},
                              );
                            },
                          ),
                          const Divider(height: 10),
                        ],
                        const SizedBox(height: 20),
                        _buildActionButtons(isDark),
                        const Divider(height: 40),

                        if (_con.defaultLinkModel != null)
                          Column(
                            children: [
                              Row(
                                children: [
                                  SupportCreatorButton(
                                    onTap: () {
                                      _launchUrl();
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy_all_outlined,
                                      color: Color(0xFF00D285),
                                      size: 30,
                                    ), // The icon to display
                                    onPressed: () {
                                      _copyTextToClipboard(
                                        _con.defaultLinkModel?.shortLink ?? '-',
                                        context,
                                      );
                                    }, // The function to call when tapped
                                    tooltip:
                                        'Copy', // Optional: Text that appears on a long press
                                    color: Colors
                                        .black, // Optional: Color of the icon
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
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

  void _copyTextToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      // Optional: Show a message to the user that the text has been copied.
      // For example, using a SnackBar:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
    });
  }

  Widget _buildPlayerError() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Unable to play this video',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _playerErrorMessage,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _hasPlayerError = false;
                _playerErrorMessage = '';
              });
              getMedia();
            },
            icon: const Icon(Icons.refresh, color: Color(0xFF00D285)),
            label: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFF00D285)),
            ),
          ),
        ],
      ),
    );
  }

  // Action Buttons with Comment Toggle
  Widget _buildActionButtons(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _commentsCountStream,
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

            _actionIcon(Icons.report, "Report", () {
              UtilsHelper.ensureAuth(
                context,
                action: "to report video",
                onAuthenticated: () {
                  showDialog(
                    context: context,
                    builder: (context) => VideoReportDialog(
                      onSubmitted: (reason, comment) async {
                        // Call your controller method here
                        bool? result = await _con.reportVideo({
                          "video_id": widget.video.id,
                          "reason": reason,
                          "description": comment,
                        });

                        if (kDebugMode) {
                          print("the_response ${result}");
                        }

                        if (result == true) {
                          try {
                            return showDialog(
                              context: _con.scaffoldKey.currentContext!,
                              builder: (context) => const VideoReportedDialog(),
                            );
                          } catch (e) {
                            print("error ${e}");
                          }
                        } else {
                          CustomMessageHandler().showErrorSnakeBar(
                            _con.scaffoldKey.currentContext!,
                            "Something went wrong.Try again",
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }),
            // _actionIcon(Icons.bookmark_border, "Save", () {}),

            // _actionIcon(Icons.file_download_outlined, "Download", () {}),
            _buildDownloadButton(const Color(0xFF00D285), isDark),
          ],
        );
      },
    );
  }

  Future<void> startSecureDownload(
    BuildContext context,
    VideoDownloadLink link,
  ) async {
    final hasPermission = await TesePermissions.checkStoragePermission();

    print(link.link);
    // return;fa

    if (hasPermission) {
      int videoId = widget.video.id;
      // Proceed with your existing download logic
      await DownloadService.requestDownload(
        link.link ?? "",
        videoId,
        widget.video.title ?? "",
        widget.video.getFileName,
        type: 'video',
        artist: widget.video.artist?.fullname,
        album: widget.video.channel?.name,
      );
    } else {
      // Explain to the user why it failed
      // ignore: use_build_context_synchronously
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
        VideoDownloadLink? link = await _con.getDownloadLink(widget.video.id);
        if (link != null) {
          await startSecureDownload(context, link);
        }
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
            stream: _commentsCountStream,
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
                      "Comments",
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
          backgroundImage: CachedNetworkImageProvider(
            _con.channel?.logoUrl ?? "",
            headers: {'Cookie': cloudFrontCookieNotifier.value},
          ),
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
                  // _showPurchaseOptions(_con.channel!);
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

                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          video.thumbnailUrl ?? "",
                          headers: {'Cookie': cloudFrontCookieNotifier.value},
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
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
                  ),
                ],
              ),
            ),
          );
  }
}

class TeseWatchTrailerButton extends StatelessWidget {
  final VoidCallback onTap;

  const TeseWatchTrailerButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.play_arrow_rounded, color: Colors.amber, size: 24),
      label: const Text(
        "WATCH TRAILER",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          fontSize: 14,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        // side: const BorderSide(color: Colors.amber, width: 1.5),
        backgroundColor: Colors.black.withOpacity(
          0.4,
        ), // Semi-transparent glass
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Pill shape
        ),
      ),
    );
  }
}

class VideoReportedDialog extends StatelessWidget {
  const VideoReportedDialog({super.key});

  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryDark.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with Glow
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: brandGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: brandGreen,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  "Report Submitted",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  "Thank you for helping us keep Tese safe. Our moderation team will review this video shortly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "DONE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoReportDialog extends StatefulWidget {
  final Function(String reason, String comment) onSubmitted;

  const VideoReportDialog({super.key, required this.onSubmitted});

  @override
  _VideoReportDialogState createState() => _VideoReportDialogState();
}

class _VideoReportDialogState extends State<VideoReportDialog> {
  final List<String> _reasons = [
    'Inappropriate Content',
    'Copyright Infringement',
    'Spam or Misleading',
    'Hate Speech',
    'Low Quality / Broken',
    'Other',
  ];

  String? _selectedReason;
  final TextEditingController _commentController = TextEditingController();

  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryDark.withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Center(
                    child: Text(
                      "REPORT VIDEO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reason Dropdown Label
                  const Text(
                    "Reason for reporting",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // Custom Styled Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedReason,
                        hint: const Text(
                          "Select a reason",
                          style: TextStyle(color: Colors.white30, fontSize: 14),
                        ),
                        isExpanded: true,
                        dropdownColor: primaryDark,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: brandGreen,
                        ),
                        items: _reasons.map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(
                              reason,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedReason = val),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comment TextField Label
                  const Text(
                    "Additional details (Optional)",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // Multi-line TextField
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Describe the issue...",
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: brandGreen),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedReason == null
                              ? null
                              : () {
                                  widget.onSubmitted(
                                    _selectedReason!,
                                    _commentController.text,
                                  );
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandGreen,
                            disabledBackgroundColor: Colors.white10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "SUBMIT",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SupportCreatorButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const SupportCreatorButton({
    super.key,
    required this.onTap,
    this.label = "Support Creator",
  });

  final Color brandGreen = const Color(0xFF00D285);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: brandGreen.withOpacity(0.3),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  gradient: LinearGradient(
                    colors: [
                      brandGreen.withOpacity(0.8),
                      const Color(0xFF00B876).withOpacity(0.9),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoRatingBar extends StatelessWidget {
  final ContentRating rating;

  const VideoRatingBar({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    // Access the current theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define adaptive colors
    final warningColor = Colors.amber[700]!;
    final baseContainerColor = isDarkMode
        ? Colors.grey[900]!
        : Colors.grey[100]!;
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        // If it's a warning, use a subtle amber tint; otherwise, use theme-aware grey
        color: rating.triggerWarning
            ? warningColor.withOpacity(0.1)
            : baseContainerColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: rating.triggerWarning ? warningColor : borderColor,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Icon with a fallback
          if (rating.icon != null)
            _buildIcon(rating.icon!)
          else
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: 30,
            ),

          const SizedBox(width: 12),

          // 2. Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating.name ?? "Content Rating",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rating.triggerWarning
                        ? warningColor
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rating.message ?? "",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: Image.network(
        url,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        // Shows a loading spinner while the Amazon/CloudFront image loads
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 42,
            height: 42,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined, size: 30),
      ),
    );
  }
}
