import 'dart:ui';
import 'package:flutter/material.dart';

class TeseLandingScreen extends StatelessWidget {
  const TeseLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient (Dark Green/Red blend)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF416C), // Dark reddish/brown
                  Color(0xFF00D285), // Dark green
                ],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 3. Logo (Simplified version using Icons/Text or Image asset)
                  // Replace with: Image.asset('assets/tese_logo.png', height: 120)
                  Center(
                    child: Image.asset(
                      "assets/images/icon.png",
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 4. Welcome Text
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(text: "Welcome to "),
                        TextSpan(
                          text: "Tese",
                          style: TextStyle(color: Color(0xFFFF4B2B)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Learn from Africa's best creators.\nPremium video content at your fingertips.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 5. Stat Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge("500+ Videos", Colors.green),
                      const SizedBox(width: 10),
                      _buildBadge("100+ Creators", Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildBadge("HD Quality", Colors.redAccent),

                  const Spacer(flex: 3),

                  // 6. Action Buttons
                  _buildGetStartedButton(context),

                  const SizedBox(height: 15),

                  _buildSignInButton(context),

                  const SizedBox(height: 30),

                  // 7. Footer Legal Text
                  const Text(
                    "By continuing, you agree to our Terms and Privacy Policy",
                    style: TextStyle(color: Colors.white38, fontSize: 11),
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

  // Stat Badge Widget
  Widget _buildBadge(String text, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: dotColor),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // Primary Gradient Button
  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF416C), // Redish
            Color(0xFFFFB75E), // Orangeish
            Color(0xFF00D285), // Greenish
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/Dashboard');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Get Started",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // Secondary Outline/Glass Button
  Widget _buildSignInButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
        color: Colors.white.withOpacity(0.05),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/ClientLogin');
        },
        child: const Text(
          "Sign In",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
