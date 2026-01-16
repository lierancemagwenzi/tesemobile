import 'package:flutter/material.dart';

class AuthPromptModal extends StatelessWidget {
  final String actionText; // e.g., "to like this video"

  const AuthPromptModal({super.key, this.actionText = "to continue"});

  // Tese Africa Branding
  static const Color teseGreen = Color(0xFF52B681);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: teseGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_person_outlined,
              color: teseGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Heading
          Text(
            "Authentication Required",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),

          // Subtext
          Text(
            "Please sign in or create an account $actionText.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 30),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: teseGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushNamed(context, '/Login');
                // Navigate to your Login Screen
              },
              child: const Text(
                "SIGN IN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Close/Guest Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Maybe Later",
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
