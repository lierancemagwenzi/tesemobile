import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/main.dart';
import 'package:video_player/video_player.dart';

class TeseVideoAdOverlay extends StatefulWidget {
  final AdModel ad;
  final VoidCallback onAdComplete;

  const TeseVideoAdOverlay({required this.ad, required this.onAdComplete});

  @override
  _TeseVideoAdOverlayState createState() => _TeseVideoAdOverlayState();
}

class _TeseVideoAdOverlayState extends State<TeseVideoAdOverlay> {
  late VideoPlayerController _controller;
  int _secondsRemaining = 0;
  bool _canSkip = false;
  bool _isMuted = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.ad.skipTimer;

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.ad.adUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _startTimer();
      });

    _controller.addListener(() {
      if (_controller.value.hasError ||
          (_controller.value.isInitialized &&
              _controller.value.position >= _controller.value.duration)) {
        widget.onAdComplete();
      }
    });
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canSkip = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
    // teseAudioHandler.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Video
        _controller.value.isInitialized
            ? Align(
                alignment: Alignment
                    .center, // Options: center, bottomCenter, topCenter
                child: AspectRatio(
                  aspectRatio: _controller
                      .value
                      .aspectRatio, // Dynamically get the ratio
                  child: Center(child: VideoPlayer(_controller)),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
        Positioned(
          top: 50,
          right: 20,
          child: GestureDetector(
            onTap: _toggleMute,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        // 2. The Brand/Description Info
        Positioned(
          top: 40,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.ad.brand ?? "Sponsored",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(widget.ad.description),
            ],
          ),
        ),

        // 3. Skip Button
        Positioned(
          bottom: 40,
          right: 20,
          child: ElevatedButton(
            onPressed: _canSkip ? widget.onAdComplete : null,
            child: Text(_canSkip ? "Skip Ad" : "Skip in $_secondsRemaining"),
          ),
        ),

        // 4. Action URL (Visit Website)
        if (widget.ad.advertiserActionUrl != null)
          Positioned(
            bottom: 40,
            left: 20,
            child: TextButton(
              onPressed: () => _launchUrl(widget.ad.advertiserActionUrl!),
              child: const Text("Learn More"),
            ),
          ),
      ],
    );
  }

  _launchUrl(String s) {}
}
