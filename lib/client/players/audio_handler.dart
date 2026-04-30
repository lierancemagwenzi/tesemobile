import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  // 1. Initialize the JustAudio Player
  final _player = AudioPlayer();

  List<AdModel> _adSchedule = [];
  List<AdModel> ads = [];
  // Notifiers for the UI
  final activeAd = ValueNotifier<AdModel?>(null);

  bool isPlayerExpanded = false;

  Video? currentVideo;

  List<Video> videos = [];
  MediaResponse? currentMediaResponse;

  setVideo(Video video, List<Video> videos, {List<AdModel> ads = const []}) {
    currentVideo = video;
    this.videos = videos;
    this.ads = ads;
  }

  Map<String, String> _audioHeaders({bool includeUserAgent = false}) {
    return {
      'Cookie': cloudFrontCookieNotifier.value,
      if (includeUserAgent) ...{
        'User-Agent': 'TeseAfrica/1.0',
        'Accept': '*/*',
      },
    };
  }

  // Function to 'prime' the handler when a video is selected
  void prepareMedia(Video video, MediaResponse response) {
    currentVideo = video;
    currentMediaResponse = response;

    // Now load the actual audio source
    // loadAudio(response.url, response.ads);
  }

  void updatePlayerVisibility(bool isExpanded) {
    isPlayerExpanded = isExpanded;
  }

  MyAudioHandler() {
    // 2. Listen to playback events and broadcast them to the System (Lockscreen)
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek, // <--- Enabling the Seek Bar
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.play,
          MediaAction.pause,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        if (e is PlayerException) {
          print('[AudioHandler] PlayerException: code=${e.code}, message=${e.message}');
          print('[AudioHandler] Failing URL: ${currentVideo?.output}');
        }
      },
    );
    _listenToChanges();
    _listenToCurrentIndex();
    _listenToPlaybackState();
    _player.durationStream.listen((duration) {
      if (duration != null && duration.inSeconds > 0) {
        final item = mediaItem.value;
        if (item != null) {
          // This tells the iOS Control Center the "Max" length of the slider
          mediaItem.add(item.copyWith(duration: duration));

          // Update the playback state so iOS knows the "Current" position
          _updatePlaybackState();
        }
      }
    });
    // _player.playbackEventStream.listen(
    //   (PlaybackEvent event) {
    //     final state = _transformEvent(event);
    //     // Directly add to the sink
    //     playbackState.add(state);
    //   },
    //   onError: (Object e, StackTrace st) {
    //     print('Playback error: $e');
    //   },
    // );

    _player.positionStream.listen((position) {
      _checkAndTriggerAds(position.inSeconds);
    });

    // Handle song completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && _player.hasNext == false) {
        stop();
      }
    });
  }
  void setAdSchedule(List<AdModel> ads) {
    // Reset ads if loading a new track
    _adSchedule = ads;
  }

  void _checkAndTriggerAds(int currentSecond) {
    if (activeAd.value != null) return;
    if (!isPlayerExpanded) return;
    // Find an ad that should play now and hasn't played yet
    final adToPlay = _adSchedule.firstWhereOrNull(
      (ad) => ad.playAt <= currentSecond && !ad.hasPlayed,
    );

    if (adToPlay != null) {
      _player.pause(); // Pause main audio
      adToPlay.markAsPlayed(); // Prevent double triggering
      Future.microtask(
        () => activeAd.value = adToPlay,
      ); // This triggers the UI switch
    }
  }

  void resumeAfterAd(String mainUrl) async {
    activeAd.value = null; // Hide the ad UI

    // Check if the player is empty (which it will be if it was a playAt: 0 ad)
    if (_player.audioSource == null) {
      try {
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(mainUrl), headers: _audioHeaders()),
        );
      } catch (e) {
        debugPrint("Error loading audio after ad: $e");
      }
    }

    _player.play();
  }
  // --- MEDIA CONTROL OVERRIDES ---

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) async {
    final isAd = mediaItem.value?.extras?['is_ad'] ?? false;
    if (isAd) return; // Users cannot scrub through ads
    await _player.seek(position);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    // Clear the media item to hide the global mini-player
    // mediaItem.add(null);
    mediaItem.add(mediaItem.value);
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    final isAd = mediaItem.value?.extras?['is_ad'] ?? false;
    if (isAd) return; // Users cannot skip ads
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) =>
      _player.seek(Duration.zero, index: index);

  @override
  Future<void> onTaskRemoved() async {
    if (_player.playing) await _player.stop();
    // await _player.dispose();
    super.onTaskRemoved();
  }

  // --- CUSTOM LOGIC FOR TESE AFRICA ---

  /// Call this when a user clicks a song/podcast in your app
  Future<void> loadAudio1(
    String url,
    String title, {
    String? artist,
    String? album,
    String? artUrl,
  }) async {
    try {
      // 1. Set the Audio Source
      final source = AudioSource.uri(
        Uri.parse(url),
        headers: _audioHeaders(),
      );

      await _player.setAudioSource(source);

      // 2. Update the Metadata for Lockscreen/Notifications
      final item = MediaItem(
        id: url,
        album: album ?? "Tese Africa",
        title: title,
        artist: artist ?? "Unknown Artist",
        duration: _player.duration,
        artUri: artUrl != null
            ? Uri.parse(artUrl)
            : Uri.parse("https://tese.africa/logo.png"),
      );

      mediaItem.add(item);
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  Future<void> playWhenReady() async {
    try {
      await playbackState.stream
          .firstWhere(
            (state) => state.processingState == AudioProcessingState.ready,
          )
          .timeout(const Duration(seconds: 15));
      play();
    } catch (_) {
      // Timed out or stream error — attempt play anyway
      play();
    }
  }

  Future<void> loadAudio(
    String url,
    int id,
    String title, {
    String? artist,
    String? artUrl,
    List<AdModel> ads = const [],
  }) async {
    try {
      try {
        final currentTag =
            _player.audioSource?.sequence.first.tag as MediaItem?;
        final currentVideoId = currentTag?.extras?['video_id'];

        // 2. Compare the IDs
        // We check if the player is ready/playing AND the ID matches
        if (currentVideoId == currentVideo?.id.toString() &&
            (_player.playing ||
                (_player.processingState != ProcessingState.idle &&
                    _player.processingState != ProcessingState.completed))) {
          if (kDebugMode) {
            print(
              "Tese: IDs match (${currentVideo?.id}). Staying on current stream.",
            );
          }
          return;
        } else {
          await _player.stop();
          print("${currentVideoId} ==${currentVideo?.id}");
        }
      } catch (e) {}
      await _player.pause();
      final item = MediaItem(
        id: url,
        album: "Tese Africa",
        title: title,
        artist: artist ?? "Unknown",
        artUri: artUrl != null ? Uri.parse(artUrl) : null,
        extras: {
          'video_id': id.toString(), // Store your DB ID here for checking
        },
      );
      mediaItem.add(item);
      _adSchedule = ads;

      // 2. Check for immediate ads (playAt == 0)
      final preRollAd = _adSchedule.firstWhereOrNull(
        (ad) => ad.playAt == 0 && !ad.hasPlayed,
      );
      final source = AudioSource.uri(
        Uri.parse(url),
        headers: _audioHeaders(includeUserAgent: true),
        tag: item,
      );

      // 3. Update with final duration once loaded
      mediaItem.add(item.copyWith(duration: _player.duration));
      if (preRollAd != null) {
        preRollAd.markAsPlayed();
        activeAd.value = preRollAd;
        await _player.setAudioSource(source, preload: true);
        // WE STOP HERE. We do not load the audio yet to prevent background play.
        return;
      }

      await _player.setAudioSource(source);
      playWhenReady();

      // 1. Update metadata first so the UI responds immediately

      // 2. Set the source (JustAudio will now trigger the listener above)
    } catch (e) {
      print("Error in loadAudio: $e");
      rethrow;
    }
  }

  void _listenToCurrentIndex() {
    _player.currentIndexStream.listen((index) {
      if (index != null && videos.isNotEmpty && index < videos.length) {
        // 1. Update your tracking variable to the REAL current song
        currentVideo = videos[index];

        // 2. Update the MediaItem so the UI/Notification updates
        final targetVideo = videos[index];
        mediaItem.add(
          MediaItem(
            id: targetVideo.output ?? "",
            album: targetVideo.playlist?.title ?? "Tese Africa",
            title: targetVideo.title ?? "",
            artist: targetVideo.artist?.fullname ?? "Tese Artist",
            artUri: Uri.parse(targetVideo.thumbnailUrl ?? ""),
            duration: _player.duration,
            extras: {
              'video_id': targetVideo.id.toString(),
            }, // Essential for your check!
          ),
        );
      }
    });
  }

  MediaItem _createAdMediaItem(AdModel item) {
    return MediaItem(
      id: item.adUrl,
      album: item.brand ?? "",
      title: "Sponsored",
      artist: "Advertisement",

      extras: {'is_ad': true, 'video_id': item.id},
    );
  }

  MediaItem _createAudioMediaItem(Video video) {
    final thumb = video.thumbnailUrl;
    return MediaItem(
      id: video.output ?? "",
      album: video.playlist?.title ?? "Tese Africa",
      title: video.title ?? "",
      artist: video.artist?.fullname ?? "Unknown Artist",
      artUri: (thumb != null && thumb.isNotEmpty) ? Uri.parse(thumb) : null,
      extras: {'video_id': video.id, 'is_ad': false},
    );
  }

  Future<void> startPlaylist(
    List<Video> videos, {
    int initialIndex = 0,
    List<AdModel> ads = const [],
  }) async {
    try {
      final targetVideo = videos[initialIndex];

      // 2. Get what is currently loaded in the player's memory
      final currentSource = _player.audioSource;
      // We check the tag of the current index in the sequence
      final currentTag = _player.sequenceState.currentSource?.tag as MediaItem?;
      final currentVideoIdInPlayer = currentTag?.extras?['video_id']
          ?.toString();

      // 3. The "Smart Check":
      // If the ID matches AND the player isn't dead/idle, just exit.
      if (currentVideoIdInPlayer == targetVideo.id.toString() &&
          _player.processingState != ProcessingState.idle) {
        if (kDebugMode) {
          print(
            "Tese: Song ${targetVideo.id} already loaded. Resuming UI only.",
          );
        }

        if (!_player.playing) {
          if (_player.processingState == ProcessingState.completed) {
            await _player.seek(Duration.zero);
          }
          _player.play();
        }
        return;
      }
      if (kDebugMode) {
        print("$currentVideoIdInPlayer===${currentVideo?.id}");
      }

      List<AudioSource> sources = [];

      if (ads.isNotEmpty) {
        sources.add(
          AudioSource.uri(
            Uri.parse(ads[0].adUrl),
            tag: _createAdMediaItem(ads[0]),
          ),
        );
      }

      // 2. Add the songs, injecting remaining ads every 3 tracks
      int adCounter = 1;
      for (int i = 0; i < videos.length; i++) {
        sources.add(
          AudioSource.uri(
            Uri.parse(videos[i].output ?? ""),
            headers: _audioHeaders(includeUserAgent: true),
            tag: _createAudioMediaItem(videos[i]),
          ),
        );

        if ((i + 1) % 1 == 0 && adCounter < ads.length) {
          sources.add(
            AudioSource.uri(
              Uri.parse(ads[adCounter].adUrl),
              tag: _createAdMediaItem(ads[adCounter]),
            ),
          );
          adCounter++;
        }
      }

      // final sources1 = _createPlaylistSources(videos);
      // _adSchedule = ads;

      // sources.addAll(sources1);

      await _player.setAudioSources(
        sources,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      _updatePlaybackState();
      await _player.setLoopMode(LoopMode.off);
      _player.play();
    } catch (e) {
      print(e);
    }
  }

  Future<void> startOfflinePlaylist(
    List<Video> videos, {
    int initialIndex = 0,
  }) async {
    try {
      await initAudioSession();

      final playlist = ConcatenatingAudioSource(
        children: videos.map((video) {
          final uri = Uri.parse(video.output ?? "");
          if (kDebugMode) print('[Offline] loading uri=$uri');
          return AudioSource.uri(uri, tag: _createAudioMediaItem(video));
        }).toList(),
      );

      await _player.setAudioSource(
        playlist,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      _updatePlaybackState();
      await _player.setLoopMode(LoopMode.off);
      _player.play();
    } catch (e) {
      if (kDebugMode) print('[Offline] startOfflinePlaylist error: $e');
    }
  }

  List<AudioSource> _createPlaylistSources(List<Video> videos) {
    return videos.map((video) {
      return AudioSource.uri(
        Uri.parse(video.output ?? ""),
        headers: _audioHeaders(includeUserAgent: true),

        // Store the MediaItem in the tag for easy retrieval later
        tag: MediaItem(
          id: video.output ?? "",
          album: "Tese Africa",
          title: video.title ?? "",
          artist: "Unknown Artist",
          artUri: Uri.parse(video.thumbnailUrl ?? ""),
          extras: {'video_id': video.id, 'is_ad': false},
        ),
      );
    }).toList();
  }

  void _listenToChanges() {
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // 1. Get all items in the current playlist
      final queueItems = sequenceState.effectiveSequence
          .map((source) => source.tag as MediaItem)
          .toList();

      // 2. Broadcast the queue to iOS
      // WITHOUT THIS, THE SKIP BUTTONS STAY GREY OR HIDDEN
      queue.add(queueItems);

      // 3. Update the current media item
      final currentItem = sequenceState.currentSource?.tag as MediaItem?;
      if (currentItem != null) {
        // Attach the player's current duration to the item
        mediaItem.add(currentItem.copyWith(duration: _player.duration));
      }
    });
  }

  void _listenToPlaybackState() {
    // 1. Listen to the combined Player State (playing + processingState)
    _player.playerStateStream.listen((state) {
      _updatePlaybackState();
    });

    // 2. Listen to position changes to keep the seek bar moving
    _player.positionStream.listen((position) {
      _updatePlaybackState();
    });

    // 3. Listen to buffered position changes
    _player.bufferedPositionStream.listen((buffered) {
      _updatePlaybackState();
    });
  }

  void _updatePlaybackState() {
    final state = _player.playerState;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious, // Index 0
          if (state.playing)
            MediaControl.pause
          else
            MediaControl.play, // Index 1
          MediaControl.skipToNext, // Index 2
          MediaControl.stop, // Index 3
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        // Show Prev, Play/Pause, and Next in the collapsed notification
        androidCompactActionIndices: const [0, 1, 2],

        processingState:
            const {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[state.processingState] ??
            AudioProcessingState.idle,

        playing: state.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // This is the critical part for iOS:
    // It ensures the session is ACTIVE before you try to load audio.
    await session.setActive(true);
  }
  // --- HELPER: MAP JUST_AUDIO STATE TO AUDIO_SERVICE STATE ---

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // 1. Broadcast the new state so the UI updates its icons
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));

    // 2. Tell the actual player to change its behavior
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;

    // 1. Broadcast state to UI
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));

    // 2. Tell the player to shuffle
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
  }
}
