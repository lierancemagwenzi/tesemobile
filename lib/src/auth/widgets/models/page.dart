import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String body;
  final bool showSkip;
  final VoidCallback onNext; // Changed from Widget button for better control

  const OnBoardingPage({
    super.key,
    required this.body,
    required this.title,
    required this.image,
    required this.onNext,
    this.showSkip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Image with Bottom Darkening
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Opaque at top (show image) -> Transparent at bottom (hide image)
                  colors: [Colors.black, Colors.transparent],
                  stops: [
                    0.3,
                    0.7,
                  ], // Adjust these to control where the fade starts/ends
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),

          // 2. Content Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  if (showSkip)
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/Login'),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),

                  // 3. Gradient Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFF5F6D),
                        Color(0xFFFFC371),
                        Color(0xFF00D285),
                        Color(0xFF00C9FF),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Required for ShaderMask to show
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 4. Body Text
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 5. Custom Pill Indicators (Hardcoded for this page example)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(true), // Active
                      const SizedBox(width: 8),
                      _buildDot(false),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 6. Vibrant Gradient Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF3D00),
                          Color(0xFFFFB300),
                          Color(0xFF00E676),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF00D285)
            : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
