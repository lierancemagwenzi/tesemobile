import 'package:flutter/material.dart';

class TeseMediaLoader extends StatefulWidget {
  final VoidCallback onExit;

  const TeseMediaLoader({super.key, required this.onExit});

  @override
  State<TeseMediaLoader> createState() => _TeseMediaLoaderState();
}

class _TeseMediaLoaderState extends State<TeseMediaLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define Shimmer Colors based on Tese Dark/Light Theme
    final Color baseColor = isDark
        ? const Color(0xFF161B22)
        : Colors.grey[200]!;
    final Color highlightColor = isDark
        ? const Color(0xFF1B5E20).withOpacity(0.3)
        : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Shimmer Background Content
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.1, 0.5, 0.9],
                      colors: [baseColor, highlightColor, baseColor],
                      transform: _SlidingGradientTransform(
                        offset: _controller.value,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Centered Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Iconic Tese Play Placeholder
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white24,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                // "Fetching Media" Message
                Text(
                  "Fetching Media...",
                  style: theme.textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Optimizing for your connection",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),

          // 3. Exit Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
              onPressed: widget.onExit,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for the shimmer movement
class _SlidingGradientTransform extends GradientTransform {
  final double offset;
  const _SlidingGradientTransform({required this.offset});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset, 0.0, 0.0);
  }
}
