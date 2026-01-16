import 'package:flutter/material.dart';

class TeseErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final double height;

  // Consistency with Tese branding
  static const Color teseGreen = Color(0xFF1B5E20);
  static const Color teseGold = Color(0xFFFFD700);

  const TeseErrorWidget({
    super.key,
    required this.onRetry,
    this.message = "Failed to load content",
    this.height = 200.0, // Default height, adjustable
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh_rounded,
            color: isDark ? teseGold : teseGreen,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isDark ? teseGold : teseGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "TRY AGAIN",
                style: TextStyle(
                  color: isDark ? teseGold : teseGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
