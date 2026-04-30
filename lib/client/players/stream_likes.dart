import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LikestreamOverlay extends StatefulWidget {
  final String eventId;
  const LikestreamOverlay({super.key, required this.eventId});

  @override
  State<LikestreamOverlay> createState() => _LikestreamOverlayState();
}

class _LikestreamOverlayState extends State<LikestreamOverlay> {
  final List<Widget> _hearts = [];
  final Random _random = Random();
  Timestamp? _lastProcessedTimestamp;
  void _addHeart(Timestamp? currentTimestamp) {
    if (currentTimestamp == null ||
        currentTimestamp == _lastProcessedTimestamp) {
      return;
    }
    _lastProcessedTimestamp = currentTimestamp;
    setState(() {
      _hearts.add(
        FloatingHeart(
          key: UniqueKey(),
          startX:
              MediaQuery.of(context).size.width -
              80 +
              _random.nextDouble() * 40,
          color: [
            const Color(0xFF00D285),
            Colors.pinkAccent,
            Colors.redAccent,
          ][_random.nextInt(3)],
        ),
      );
    });

    // Clean up the widget list to keep memory low
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _hearts.isNotEmpty) {
        setState(() {
          _hearts.removeAt(0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Listen to the most recent likes globally
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .collection('likes')
              .orderBy('timestamp', descending: true)
              .limit(1) // Only watch for the newest one
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final data =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;
              final Timestamp? serverTime = data['timestamp'] as Timestamp?;
              // Trigger a heart every time the data changes
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _addHeart(serverTime),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        ..._hearts,
      ],
    );
  }
}

class FloatingHeart extends StatefulWidget {
  final double startX; // Randomize horizontal start position
  final Color color;

  const FloatingHeart({super.key, required this.startX, required this.color});

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _xAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Moves heart from bottom (1.0) to middle (0.4) of screen
    _yAnimation = Tween<double>(
      begin: 1.0,
      end: 0.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Fades out as it reaches the end
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0)),
    );

    // Slight horizontal wobble
    _xAnimation = Tween<double>(
      begin: widget.startX,
      end: widget.startX + (Random().nextDouble() * 40 - 20),
    ).animate(_controller);

    _controller.forward(); // Self-destruct when done
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: MediaQuery.of(context).size.height * (1 - _yAnimation.value),
          left: _xAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Icon(LucideIcons.heart, color: widget.color, size: 30),
          ),
        );
      },
    );
  }
}
