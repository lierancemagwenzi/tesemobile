// Use the late variable we initialized in main.dart
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/src/repositories/settings_repository.dart'
    as settingRepo;
import 'package:smacredit/src/repositories/settings_repository.dart';
import '../../main.dart' as main;

final AudioHandler audioHandler = main.teseAudioHandler;

class GlobalAudioProgressBar extends StatelessWidget {
  const GlobalAudioProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final String? currentRouteName = route?.settings.name;

    // Hide if we are on either full-player screen
    if (currentRouteName == '/TeseAudoPlayer' ||
        currentRouteName == '/OfflineAudioPlayer') {
      return const SizedBox.shrink();
    }

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final playing = playbackState?.playing ?? false;
            if (playbackState?.processingState == AudioProcessingState.idle) {
              return const SizedBox.shrink();
            }
            return Dismissible(
              key: Key(mediaItem.id),
              direction: DismissDirection.down,
              onDismissed: (_) => audioHandler.stop(),
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(
                          left: 12,
                          right: 4,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            mediaItem.artUri.toString(),
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey,
                              width: 45,
                              height: 45,
                            ),
                          ),
                        ),
                        title: Text(
                          mediaItem.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          mediaItem.artist ?? "Tese Africa",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Skip Previous
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.skip_previous_rounded,
                                size: 28,
                              ),
                              color: Colors.white70,
                              onPressed: audioHandler.skipToPrevious,
                            ),

                            // Play/Pause
                            IconButton(
                              iconSize: 32,
                              icon: Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: const Color(0xFF00D285),
                              ),
                              onPressed: playing
                                  ? audioHandler.pause
                                  : audioHandler.play,
                            ),

                            // Skip Next
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.skip_next_rounded,
                                size: 28,
                              ),
                              color: Colors.white70,
                              onPressed: audioHandler.skipToNext,
                            ),

                            const SizedBox(width: 8),

                            // Close Button
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Colors.white38,
                              ),
                              onPressed: () => audioHandler.stop(),
                            ),
                          ],
                        ),
                        onTap: () => _navigateToPlayer(context),
                      ),
                      // THE PROGRESS BAR: Linear indicator at the bottom of the tile
                      _MiniProgressLine(audioHandler: audioHandler),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToPlayer(BuildContext context) {
    if (main.teseAudioHandler.currentVideo == null) return;

    final output = main.teseAudioHandler.currentVideo?.output ?? '';
    if (output.startsWith('file://')) {
      navigatorKey.currentState?.pushNamed('/OfflineAudioPlayer');
    } else {
      navigatorKey.currentState?.pushNamed('/TeseAudoPlayer');
    }
  }
}

// Separate stateless widget for the slim progress line to avoid rebuilding the whole tile
class _MiniProgressLine extends StatelessWidget {
  final AudioHandler audioHandler;
  const _MiniProgressLine({required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration =
            audioHandler.mediaItem.value?.duration ?? Duration.zero;

        double progress = 0.0;
        if (duration.inMilliseconds > 0) {
          progress = position.inMilliseconds / duration.inMilliseconds;
        }

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D285)),
            minHeight: 2,
          ),
        );
      },
    );
  }
}
