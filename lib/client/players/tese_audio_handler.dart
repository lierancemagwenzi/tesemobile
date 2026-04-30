import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';

class TeseAudioHandler extends BaseAudioHandler with SeekHandler {
  // 1. The Two-Player Engine
  final _musicPlayer = AudioPlayer(); // Handles the songs/playlist
  final _adPlayer = AudioPlayer(); // Handles the unskippable interrupts

  bool _isAdActive = false;
  int _songsPlayedSinceLastAd = 0;
  final int _adInterval = 3; // Trigger ad every 3 tracks

  List<AdModel> _availableAds = [];
  List<Video> _playlistVideos = [];

  Video? currentVideo;
  List<Video> videos = [];
  List<AdModel> ads = [];

  setVideo(Video video, List<Video> videos, {List<AdModel> ads = const []}) {
    currentVideo = video;
    this.videos = videos;
    this.ads = ads;
  }

  TeseAudioHandler() {
    _initStreams();
  }

  // --- INITIALIZATION & LISTENERS ---

  void _initStreams() {
    // Listen for Ad Completion to resume music
    _adPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && _isAdActive) {
        _handleAdEnd();
      }
    });

    // Listen for Music Index changes to trigger mid-rolls
    _musicPlayer.currentIndexStream.listen((index) {
      if (index == null || _isAdActive) return;

      _songsPlayedSinceLastAd++;

      if (_songsPlayedSinceLastAd >= _adInterval && _availableAds.length > 1) {
        _triggerAd(_availableAds[1]); // Mid-roll logic
        _songsPlayedSinceLastAd = 0;
      } else {
        _syncMetadataToMusic(index);
      }
    });

    // Broadcast state to System (Lockscreen/Notification)
    CombineLatestStream.combine2<PlayerState, PlayerState, PlaybackState>(
      _musicPlayer.playerStateStream,
      _adPlayer.playerStateStream,
      (musicState, adState) => _transformToPlaybackState(),
    ).pipe(playbackState);
  }

  // --- PUBLIC CONTROL API ---

  Future<void> startTesePlaylist(
    List<Video> videos, {
    AdModel? preRoll,
    List<AdModel> ads = const [],
    initialIndex = 0,
  }) async {
    _playlistVideos = videos;
    _availableAds = ads;
    _songsPlayedSinceLastAd = 0;

    // Load music queue in background
    final musicSources = videos
        .map(
          (v) => AudioSource.uri(
            Uri.parse(v.output ?? ""),
            tag: _createMediaItem(v, isAd: false),
          ),
        )
        .toList();

    await _musicPlayer.setAudioSources(
      musicSources,
      initialIndex: initialIndex, // Jump straight to the song the user tapped
      initialPosition: Duration.zero,
      preload: true,
    );

    if (preRoll != null) {
      _triggerAd(preRoll);
    } else {
      _isAdActive = false;
      _musicPlayer.play();
    }
  }

  Future<void> _triggerAd(AdModel ad) async {
    _isAdActive = true;
    await _musicPlayer.pause();

    final adItem = _createAdMediaItem(ad);
    await _adPlayer.setAudioSource(
      AudioSource.uri(Uri.parse(ad.adUrl), tag: adItem),
    );

    mediaItem.add(adItem);
    _adPlayer.play();
  }

  void _updatePlaybackState() {
    final state = _musicPlayer.playerState;

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
        updatePosition: _musicPlayer.position,
        bufferedPosition: _musicPlayer.bufferedPosition,
        speed: _musicPlayer.speed,
      ),
    );
  }

  void _handleAdEnd() async {
    // 1. Kill the Ad "Switch" immediately
    _isAdActive = false;

    try {
      // 2. Clear the ad player entirely so it can't loop
      await _adPlayer.stop();
      // await _adPlayer.setAudioSource(null);
    } catch (e) {
      debugPrint("Tese: Error clearing ad player: $e");
    }

    // 3. Update metadata to the actual song BEFORE playing
    final currentIndex = _musicPlayer.currentIndex ?? 0;
    _syncMetadataToMusic(currentIndex);

    // 4. Give the UI and OS breathing room (200ms)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_musicPlayer.processingState != ProcessingState.idle) {
        _musicPlayer.play();
        _updatePlaybackState(); // Force a UI refresh
      }
    });
  }
  // --- OVERRIDES FOR SYSTEM COMMANDS ---

  @override
  Future<void> play() => _isAdActive ? _adPlayer.play() : _musicPlayer.play();

  @override
  Future<void> pause() =>
      _isAdActive ? _adPlayer.pause() : _musicPlayer.pause();

  @override
  Future<void> seek(Duration position) async {
    if (_isAdActive) return; // Unskippable Ads
    await _musicPlayer.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_isAdActive) return; // Can't skip during ads
    await _musicPlayer.seekToNext();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));

    // built-in LoopMode works perfectly here because it only affects the Music player
    if (repeatMode == AudioServiceRepeatMode.one) {
      await _musicPlayer.setLoopMode(LoopMode.one);
    } else if (repeatMode == AudioServiceRepeatMode.all) {
      await _musicPlayer.setLoopMode(LoopMode.all);
    } else {
      await _musicPlayer.setLoopMode(LoopMode.off);
    }
  }

  // --- POSITION & DURATION STREAMS FOR UI ---

  Stream<Duration> get tesePositionStream =>
      _isAdActive ? _adPlayer.positionStream : _musicPlayer.positionStream;

  Stream<Duration?> get teseDurationStream =>
      _isAdActive ? _adPlayer.durationStream : _musicPlayer.durationStream;

  // --- HELPERS ---

  void _syncMetadataToMusic(int index) {
    if (index < _playlistVideos.length) {
      mediaItem.add(_createMediaItem(_playlistVideos[index], isAd: false));
    }
  }

  PlaybackState _transformToPlaybackState() {
    // Determine which player is "In Charge"
    final activePlayer = _isAdActive ? _adPlayer : _musicPlayer;

    // Mapping just_audio states to audio_service states
    final processingState =
        const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[activePlayer.processingState] ??
        AudioProcessingState.idle;

    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        activePlayer.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.play,
        MediaAction.pause,
      },
      androidCompactActionIndices: const [0, 1, 2],
      playing: activePlayer.playing,
      updatePosition: activePlayer.position,
      bufferedPosition: activePlayer.bufferedPosition,
      processingState: processingState,
    );
  }

  MediaItem _createMediaItem(Video video, {required bool isAd}) {
    return MediaItem(
      id: video.output ?? video.id.toString(),
      album: "Tese Africa",
      title: video.title ?? "Unknown",
      artist: "Tese Artist",
      artUri: Uri.parse(video.thumbnailUrl ?? ""),
      extras: {'is_ad': isAd, 'video_id': video.id.toString()},
    );
  }

  MediaItem _createAdMediaItem(AdModel ad) {
    return MediaItem(
      id: ad.adUrl,
      title: "Sponsored",
      artist: "Advertisement",
      extras: {'is_ad': true, 'video_id': ad.id.toString()},
    );
  }

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // This is the critical part for iOS:
    // It ensures the session is ACTIVE before you try to load audio.
    await session.setActive(true);
  }
}
