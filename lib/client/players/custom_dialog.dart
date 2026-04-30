import 'dart:ui';
import 'package:flutter/material.dart';

class GlassOverlayDialog extends StatelessWidget {
  final Widget child;
  final bool showCloseButton;
  final double blurSigma;

  const GlassOverlayDialog({
    super.key,
    required this.child,
    this.showCloseButton = true,
    this.blurSigma = 15.0,
  });

  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Animated Blur Background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(color: primaryDark.withOpacity(0.8)),
            ),
          ),

          // 2. The Custom Content
          SafeArea(
            child: Center(
              child: FadeInWidget(
                // Optional animation wrapper
                child: child,
              ),
            ),
          ),

          // 3. Optional Close Button
          if (showCloseButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }
}

// Simple Helper for a smooth entrance
class FadeInWidget extends StatelessWidget {
  final Widget child;
  const FadeInWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
