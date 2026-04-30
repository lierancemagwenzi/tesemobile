import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:smacredit/src/auth/controller/LoginController.dart';
import 'package:smacredit/src/auth/models/country_model.dart';
import 'package:smacredit/src/auth/models/sign_up_type.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class SignUpMethodScreen extends StatefulWidget {
  final CountryModel? countryModel;
  const SignUpMethodScreen({super.key, required this.countryModel});

  @override
  StateMVC<SignUpMethodScreen> createState() => _SignUpMethodScreenState();
}

class _SignUpMethodScreenState extends StateMVC<SignUpMethodScreen> {
  static const Color brandGreen = Color(0xFF679E4F);
  static const Color primaryDark = Color(0xFF1A0B2E);

  late LoginController _con;

  _SignUpMethodScreenState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        body: Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),

                    const Spacer(flex: 2),

                    // Logo + heading
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/icon.png',
                              height: 64,
                              width: 64,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.play_circle_fill,
                                color: brandGreen,
                                size: 64,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Center(
                      child: Text(
                        'Create your account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Choose how you'd like to get started",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Sign up with Email
                    _PrimaryButton(
                      icon: Icons.alternate_email_rounded,
                      label: 'Sign up with Email',
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/CheckEmail',
                        arguments: {
                          'signUpType': SignUpType.supporter,
                          'countryModel': widget.countryModel,
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Sign up with Google
                    _OutlineButton(
                      icon: Image.asset(
                        "assets/images/google.png",
                        height: 20,
                        width: 20,
                      ),
                      iconSize: 28,
                      label: 'Sign up with Google',
                      onPressed: () => _con.handleGoogleSignIn(
                        isSignUp: true,
                        countryId: widget.countryModel?.id,
                      ),
                    ),

                    // Sign up with Apple (iOS only)
                    if (Platform.isIOS) ...[
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SignInWithAppleButton(
                          onPressed: () => _con.handleAppleSignIn(
                            isSignUp: true,
                            countryId: widget.countryModel?.id,
                          ),
                          text: 'Apple',
                          style: SignInWithAppleButtonStyle.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ],

                    const SizedBox(height: 36),

                    // Already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/ClientLogin'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: brandGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF679E4F), Color(0xFF4E7A3A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF679E4F).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final Widget icon;
  final double iconSize;
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.15)),
          backgroundColor: Colors.white.withOpacity(0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
