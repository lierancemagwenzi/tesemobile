import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:smacredit/src/content-creator/events/widgets/creator_events.dart';
import 'package:smacredit/src/models/UserModel.dart'; // The screen we just built

class ViewLiveEventsButton extends StatelessWidget {
  final  User artist;
 final bool isLiveNow;
  const ViewLiveEventsButton({
    super.key,
    required this.artist,
    this.isLiveNow=false

  });

  @override
  Widget build(BuildContext context) {
    const Color teseGreen = Color(0xFF00D285);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatorEventsScreen(
                artist:artist
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: teseGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: teseGreen.withOpacity(0.5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PULSING ICON INDICATOR
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isLiveNow) const _PulseCircle(color: Colors.red),
                  Icon(
                    LucideIcons.calendarRange,
                    size: 18,
                    color: isLiveNow ? Colors.red : teseGreen,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Text(
                isLiveNow ? "VIEW UPCOMING LIVE EVENTS" : "VIEW UPCOMING LIVE EVENTS",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple internal helper for the "Live" pulse effect
class _PulseCircle extends StatefulWidget {
  final Color color;
  const _PulseCircle({required this.color});

  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.8).animate(_controller),
      child: FadeTransition(
        opacity: Tween(begin: 0.5, end: 0.0).animate(_controller),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
