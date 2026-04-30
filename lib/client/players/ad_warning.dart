import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/client/models/media_response.dart';

class TeseAdWarningWidget extends StatelessWidget {
  final AdModel nextAd;
  final BetterPlayerController controller;

  const TeseAdWarningWidget({
    super.key,
    required this.nextAd,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.videoPlayerController == null) return const SizedBox.shrink();
    // ValueListenableBuilder listens to the player's progress automatically
    return ValueListenableBuilder(
      valueListenable: controller.videoPlayerController!,
      builder: (context, value, child) {
        final currentSec = value.position.inSeconds;
        final secondsUntilAd = nextAd.playAt - currentSec;

        print(secondsUntilAd);
        print(nextAd.brand);
        // Only show if we are within the 5-second window
        if (secondsUntilAd > 0 && secondsUntilAd <= 5) {
          return Positioned(
            top: 60,
            right: 20,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF00D285),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Color(0xFF00D285),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Ad in $secondsUntilAd...",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily:
                                'Montserrat', // Matching Tese Africa branding
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
        return const SizedBox.shrink();
      },
    );
  }
}
