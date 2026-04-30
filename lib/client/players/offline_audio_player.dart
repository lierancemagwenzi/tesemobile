import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/client/downloads/download_record.dart';
import 'package:smacredit/main.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';

class OfflineAudioPlayerScreen extends StatefulWidget {
  final List<DownloadRecord> records;
  final int initialIndex;

  const OfflineAudioPlayerScreen({
    super.key,
    required this.records,
    required this.initialIndex,
  });

  @override
  State<OfflineAudioPlayerScreen> createState() =>
      _OfflineAudioPlayerScreenState();
}

class _OfflineAudioPlayerScreenState extends State<OfflineAudioPlayerScreen> {
  List<Video> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _showQueue = false;
  double? _dragValue;

  @override
  void initState() {
    super.initState();
    teseAudioHandler.updatePlayerVisibility(true);
    _initPlayback();
  }

  @override
  void dispose() {
    teseAudioHandler.updatePlayerVisibility(false);
    super.dispose();
  }

  Future<void> _initPlayback() async {
    final directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();

    final dirPath = directory?.path ?? '';

    final videos = widget.records.map((r) {
      final file = File('$dirPath/${r.fileName}');
      if (kDebugMode) {
        debugPrint('[Offline] path=${file.path} exists=${file.existsSync()}');
      }
      return Video(
        id: r.videoId,
        title: r.videoName,
        output: file.uri.toString(),
        isAudio: true,
      );
    }).toList();

    setState(() {
      _videos = videos;
      _currentIndex = widget.initialIndex;
      _isLoading = false;
    });

    final alreadyLoaded =
        teseAudioHandler.currentVideo?.id == videos[widget.initialIndex].id;

    teseAudioHandler.setVideo(videos[widget.initialIndex], videos);

    if (!alreadyLoaded) {
      await teseAudioHandler.startOfflinePlaylist(
        videos,
        initialIndex: widget.initialIndex,
      );
    }
  }

  Future<void> _playAt(int index) async {
    setState(() {
      _currentIndex = index;
      _showQueue = false;
    });
    teseAudioHandler.setVideo(_videos[index], _videos);
    await teseAudioHandler.startOfflinePlaylist(_videos, initialIndex: index);
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D285)),
        ),
      );
    }

    return StreamBuilder<MediaItem?>(
      stream: teseAudioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _showQueue ? Icons.queue_music : Icons.queue_music_outlined,
                  color: _showQueue
                      ? const Color(0xFF00D285)
                      : Colors.white,
                ),
                onPressed: () => setState(() => _showQueue = !_showQueue),
              ),
            ],
          ),
          body: Stack(
            children: [
              // --- Blurred background ---
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),

              // --- Main content ---
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(),
                    _buildArtwork(context),
                    const Spacer(),
                    _buildMetadata(mediaItem),
                    const SizedBox(height: 40),
                    _buildProgressBar(mediaItem),
                    const SizedBox(height: 20),
                    _buildControls(),
                    const Spacer(flex: 2),
                  ],
                ),
              ),

              // --- Queue overlay ---
              if (_showQueue) _buildQueueOverlay(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtwork(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.8;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00D285), Color(0xFF007AFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: const Icon(
          Icons.music_note_rounded,
          size: 100,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildMetadata(MediaItem? mediaItem) {
    final record = widget.records[_currentIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mediaItem?.artist ?? record.artist ?? '',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            mediaItem?.title ?? record.videoName,
            style: const TextStyle(fontSize: 18, color: Colors.white60),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(MediaItem? mediaItem) {
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration =
            teseAudioHandler.mediaItem.value?.duration ?? Duration.zero;

        final double currentPosition =
            _dragValue ?? position.inMilliseconds.toDouble();
        final double totalDuration = duration.inMilliseconds.toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: SliderComponentShape.noThumb,
                  activeTrackColor: const Color(0xFF00D285),
                  inactiveTrackColor: Colors.white12,
                ),
                child: Slider(
                  min: 0,
                  max: totalDuration > 0 ? totalDuration : 1,
                  value: currentPosition.clamp(
                    0,
                    totalDuration > 0 ? totalDuration : 1,
                  ),
                  onChanged: (val) => setState(() => _dragValue = val),
                  onChangeEnd: (val) {
                    teseAudioHandler.seek(Duration(milliseconds: val.toInt()));
                    setState(() => _dragValue = null);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(
                        _dragValue != null
                            ? Duration(milliseconds: _dragValue!.toInt())
                            : position,
                      ),
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
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

  Widget _buildControls() {
    return StreamBuilder<PlaybackState>(
      stream: teseAudioHandler.playbackState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;
        final repeatMode =
            state?.repeatMode ?? AudioServiceRepeatMode.none;
        final shuffleMode =
            state?.shuffleMode ?? AudioServiceShuffleMode.none;
        const activeColor = Colors.orange;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                shuffleMode == AudioServiceShuffleMode.all
                    ? Icons.shuffle_on_rounded
                    : Icons.shuffle,
                color: shuffleMode == AudioServiceShuffleMode.all
                    ? activeColor
                    : Colors.white,
              ),
              onPressed: () {
                final newMode =
                    shuffleMode == AudioServiceShuffleMode.all
                        ? AudioServiceShuffleMode.none
                        : AudioServiceShuffleMode.all;
                teseAudioHandler.setShuffleMode(newMode);
              },
            ),
            IconButton(
              iconSize: 45,
              icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
              onPressed: teseAudioHandler.skipToPrevious,
            ),
            GestureDetector(
              onTap: playing ? teseAudioHandler.pause : teseAudioHandler.play,
              child: Container(
                height: 85,
                width: 85,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 50,
                  color: Colors.black,
                ),
              ),
            ),
            IconButton(
              iconSize: 45,
              icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
              onPressed: teseAudioHandler.skipToNext,
            ),
            IconButton(
              icon: Icon(
                repeatMode == AudioServiceRepeatMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat,
                color: repeatMode != AudioServiceRepeatMode.none
                    ? activeColor
                    : Colors.white,
              ),
              onPressed: () {
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

  Widget _buildQueueOverlay(bool isDark) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showQueue = false),
        child: Container(
          color: Colors.black54,
          child: GestureDetector(
            onTap: () {}, // prevent dismissal when tapping inside
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Queue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: widget.records.length,
                          itemBuilder: (context, index) =>
                              _buildTrackTile(index, isDark),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackTile(int index, bool isDark) {
    final record = widget.records[index];
    final isPlaying = index == _currentIndex;

    return InkWell(
      onTap: () => _playAt(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isPlaying
              ? const Color(0xFF00D285).withOpacity(0.1)
              : (isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying
                ? const Color(0xFF00D285).withOpacity(0.4)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPlaying
                    ? const Color(0xFF00D285).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying
                    ? Icons.equalizer_rounded
                    : Icons.music_note_rounded,
                size: 20,
                color: isPlaying ? const Color(0xFF00D285) : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.videoName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isPlaying ? const Color(0xFF00D285) : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (record.artist != null)
                    Text(
                      record.artist!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isPlaying)
              const Icon(
                Icons.volume_up_rounded,
                color: Color(0xFF00D285),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
