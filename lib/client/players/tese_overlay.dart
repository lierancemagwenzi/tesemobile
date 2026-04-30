// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:smacredit/client/models/media_response.dart';

// class TeseAdOverlay extends StatefulWidget {
//   final AdModel ad;
//   final VoidCallback onSkip;

//   const TeseAdOverlay({super.key, required this.ad, required this.onSkip});

//   @override
//   State<TeseAdOverlay> createState() => _TeseAdOverlayState();
// }

// class _TeseAdOverlayState extends State<TeseAdOverlay> {
//   late int _secondsRemaining;
//   Timer? _timer;
//   bool _canSkip = false;

//   @override
//   void initState() {
//     super.initState();
//     _secondsRemaining = widget.ad.skipTimer;
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsRemaining > 0) {
//         setState(() {
//           _secondsRemaining--;
//         });
//       } else {
//         setState(() {
//           _canSkip = true;
//         });
//         _timer?.cancel();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       bottom: 40,
//       right: 20,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // The "Ad by Brand" label
//           Text(
//             "Ad by ${widget.ad.brand ?? 'Partner'}",
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),

//           // The Skip Button / Countdown
//           GestureDetector(
//             onTap: _canSkip ? widget.onSkip : null,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               decoration: BoxDecoration(
//                 color: _canSkip ? const Color(0xFF00D285) : Colors.black54,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white24),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     _canSkip ? "SKIP AD" : "SKIP IN $_secondsRemaining",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.1,
//                     ),
//                   ),
//                   if (_canSkip) ...[
//                     const SizedBox(width: 8),
//                     const Icon(Icons.skip_next_rounded, color: Colors.white),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/client/models/media_response.dart';

class TeseAdOverlay extends StatelessWidget {
  final AdModel ad;
  final BetterPlayerController controller; // Pass the controller in
  final VoidCallback onSkip;

  const TeseAdOverlay({
    super.key,
    required this.ad,
    required this.controller,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.videoPlayerController == null) return const SizedBox.shrink();
    // We listen to the videoPlayerController's value (position, duration, buffering)
    return ValueListenableBuilder(
      valueListenable: controller.videoPlayerController!,
      builder: (context, value, child) {
        // This is the actual time played in the ad video
        final int currentPos = value.position.inSeconds;

        // Calculate remaining time based on the ad's specific skipTimer
        final int secondsRemaining = ad.skipTimer - currentPos;
        final bool canSkip = secondsRemaining <= 0;

        return Positioned(
          bottom: 40,
          right: 20,
          child: Column(
            children: [
              Text(
                "Ad by ${ad.brand ?? 'Partner'}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: canSkip ? onSkip : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: canSkip ? const Color(0xFF00D285) : Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    canSkip ? "SKIP AD" : "SKIP IN $secondsRemaining",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
