import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smacredit/client/players/video_player_widget.dart';

class TesePremiumPaywall extends StatelessWidget {
  final String thumbnailUrl;
  final String videoTitle;
  final String price;
  final String currency;
  final String reason;
  final VoidCallback onPurchase;
  final VoidCallback onExit;

  final VoidCallback watchTrailer;

  final bool hasTrailer;

  const TesePremiumPaywall({
    super.key,
    required this.thumbnailUrl,
    required this.videoTitle,
    required this.price,
    required this.currency,
    required this.onPurchase,
    required this.onExit,
    required this.watchTrailer,
    required this.hasTrailer,
    required this.reason,
  });

  // Tese Africa Branding Colors
  static const Color teseGreen = Color(0xFF1B5E20);
  static const Color teseGold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Thumbnail with Blur
          Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.black),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gold Lock Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: teseGold.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: teseGold,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title and Subtitle
                  Text(
                    videoTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "PREMIUM CONTENT",
                    style: TextStyle(
                      color: teseGold,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Price Display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      " $price",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reason.replaceAll("_", " "),
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 50),

                  // Purchase Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teseGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onPurchase,
                      child: Text(
                        getPurchaseButtonText(reason),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  if (hasTrailer) ...[
                    const Divider(height: 10),
                    TeseWatchTrailerButton(
                      onTap: () {
                        watchTrailer();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 3. Exit Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black45,
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
              onPressed: onExit,
            ),
          ),
        ],
      ),
    );
  }

  String getPurchaseButtonText(String? accessReason) {
    switch (accessReason) {
      case 'LOCKED_PREMIUM_VIDEO':
        return "Purchase Video";

      case 'LOCKED_CHANNEL_SUBSCRIPTION_REQUIRED':
        return "Subscribe to Channel";

      case 'LOCKED_PLAYLIST_PURCHASE_REQUIRED':
        return "Subscribe to Playlist";

      case 'LOCKED_RESTRICTED':
      case 'LOCKED_UNKNOWN':
        return "Access Restricted";

      default:
        return "Get Access";
    }
  }
}
