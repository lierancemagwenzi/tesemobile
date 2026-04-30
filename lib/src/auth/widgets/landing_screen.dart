
import 'dart:ui';
import 'package:flutter/material.dart';

class TeseLandingScreen extends StatelessWidget {
  const TeseLandingScreen({super.key});

  // Brand Colors consistent with the Auth flow
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);
  final Color brandAccent = const Color(0xFFFF416C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep Space Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4A4A4A),
                  const Color(0xFF1C1C1C),
                  Colors.black,
                ],
              ),
            ),
          ),


          // 3. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Animated/Glass Logo Container
                  _buildGlassLogo(),

                  const SizedBox(height: 40),

                  // Welcome Text with subtle shadow for readability
                  _buildWelcomeText(),

                  const SizedBox(height: 15),

                  Text(
                    "Learn from Africa's best creators.\nPremium video content at your fingertips.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 15,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Refined Stat Badges
                  _buildBadgeRow(),

                  const Spacer(flex: 3),

                  // Action Buttons
                  _buildGetStartedButton(context),

                  const SizedBox(height: 16),

                  _buildSignInButton(context),

                  const SizedBox(height: 30),

                  // Legal Text
                  Text(
                    "By continuing, you agree to our Terms and Privacy Policy",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }

  Widget _buildGlassLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Image.asset(
            "assets/images/icon.png",
            height: 80,
            width: 80,
            fit: BoxFit.contain,
            // Fallback if image isn't found
            errorBuilder: (c, e, s) =>
                Icon(Icons.play_circle_fill, color: brandGreen, size: 80),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        children: [
          const TextSpan(text: "Welcome to "),
          TextSpan(
            text: "Tese",
            style: TextStyle(
              color: brandGreen,
              shadows: [
                Shadow(color: brandGreen.withOpacity(0.5), blurRadius: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildBadge("500+ Videos", brandGreen),
        _buildBadge("100+ Creators", Colors.orangeAccent),
        _buildBadge("4K Quality", brandAccent),
      ],
    );
  }

  Widget _buildBadge(String text, Color dotColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [brandGreen, const Color(0xFF00B876)]),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/Dashboard'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "GET STARTED",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        color: Colors.white.withOpacity(0.03),
      ),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/ClientLogin'),
        child: const Text(
          "SIGN IN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
