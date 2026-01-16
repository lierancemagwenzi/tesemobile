import 'package:flutter/material.dart';

class TeseEmptyWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? actionButton;

  const TeseEmptyWidget({
    super.key,
    this.title = "No data found",
    this.subtitle = "There is nothing to show here at the moment.",
    this.icon = Icons.inbox_outlined,
    this.actionButton,
  });

  // Tese Africa Branding
  static const Color teseGreen = Color(0xFF52B681);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered Icon with subtle background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: isDark ? Colors.white30 : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),

            // Optional Action (e.g., "Go Home" or "Explore")
            if (actionButton != null) ...[
              const SizedBox(height: 32),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
