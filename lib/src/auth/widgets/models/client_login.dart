import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smacredit/src/auth/controller/LoginController.dart';
import 'package:smacredit/src/auth/controller/shared_preferences_helper.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/helpers/Validator.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/widgets/CustomButtons.dart';

class TeseLoginScreen extends StatefulWidget {
  String? message;

  TeseLoginScreen({this.message});

  @override
  StateMVC<TeseLoginScreen> createState() => _TeseLoginScreenState();
}

class _TeseLoginScreenState extends StateMVC<TeseLoginScreen> {
  // Tese Africa Brand Colors
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  final LocalAuthentication auth = LocalAuthentication();
  // ···
  bool? canAuthenticate;

  bool? hasBioMetric;
  String? token;

  checkDevice() async {
    try {
      setState(() {
        _con.loading = true;
      });

      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      final List<BiometricType> availableBiometrics = await auth
          .getAvailableBiometrics();

      token = await TokenService.getToken();

      if (availableBiometrics.isNotEmpty) {
        setState(() {
          hasBioMetric = true;
        });
      }

      setState(() {
        _con.loading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error checking biometrics: $e");
      }
    }
  }

  setInstalled() async {
    SharedPreferences pres = await SharedPreferences.getInstance();

    pres.setBool('installed', true);
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    bool isFaceIdAvailable = false;
    try {
      List<BiometricType> availableBiometrics = await auth
          .getAvailableBiometrics();

      // 2. Check specifically for FaceID (iOS) or Face (Android)
      if (availableBiometrics.contains(BiometricType.face)) {
        isFaceIdAvailable = true;
      }
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your finger/face to quickly sign in',
        options: AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
          // If you set this to true, it will NOT allow the
          // user to use the PIN/Passcode as a fallback.
          biometricOnly: Platform.isIOS && isFaceIdAvailable,
        ),
      );
    } catch (e) {
      print("Authentication error: $e");
    }

    if (authenticated) {
      _con.renewToken(token ?? '');
      // TODO: Navigate to the home screen or set the user session
      print("Authentication Successful! User is logged in.");
    } else {
      print("Authentication Failed or Cancelled.");
    }
  }

  final _formKey = GlobalKey<FormState>();

  String password = '';
  String phone = '';
  bool hidePassword = true;
  late LoginController _con;

  _TeseLoginScreenState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInstalled();
    checkDevice();
    if (widget.message != null) {
      Future.delayed(const Duration(seconds: 1), () {
        CustomMessageHandler().showSuccessSnakeBar(
          _con.scaffoldKey.currentContext!,
          widget.message!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        // Prevents the background from jumping when the keyboard appears
        resizeToAvoidBottomInset: false,
        key: _con.scaffoldKey,
        body: Form(
          key: _formKey,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              // image: DecorationImage(image: AssetImage("assets/images/bg.png")),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryDark,
                  const Color(0xFF2D1B4E),
                  brandGreen.withOpacity(0.2),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Container(
                //   width: double.infinity,
                //   height: double.infinity,
                //   decoration: const BoxDecoration(
                //     image: DecorationImage(
                //       // Replace with your actual background image path
                //       image: AssetImage('assets/images/bg.png'),
                //       fit: BoxFit.cover, // Ensures it covers the entire screen
                //     ),
                //   ),
                // ),
                // Floating background decorative element
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: brandGreen.withOpacity(0.15),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildGlassCard(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        // The blur intensity for the frosted glass effect
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBranding(),
              const SizedBox(height: 35),
              _buildInputField(Icons.alternate_email_rounded, "Email Address"),
              const SizedBox(height: 18),
              _buildPasswodInputField(Icons.lock, "Password", isPassword: true),
              _buildForgotPassword(),
              const SizedBox(height: 25),

              CustomButtons.filledButton(
                text: 'Sign In',
                callback: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _con.loginUser({"email": phone, "password": password});
                  }
                },
              ),
              // _buildLoginButton(),
              const SizedBox(height: 24),
              _buildSocialLoginSection(),

              if (canAuthenticate == true && token != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.fingerprint,
                    ), // Use Icons.face_unlock for face ID
                    label: const Text('Sign in with Biometrics'),
                    onPressed: _authenticate,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildSignUpPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        // Using your specific asset path
        Image.asset(
          'assets/images/logo-light.png',
          height: 80,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if the image isn't found during development
            return Icon(Icons.bolt, color: brandGreen, size: 60);
          },
        ),
        const SizedBox(height: 15),
        const Text(
          "Welcome back",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        Text(
          "Sign in to your account to continue",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    IconData icon,
    String label, {
    bool isPassword = false,
  }) {
    return TextFormField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      cursorColor: brandGreen,
      onSaved: (value) {
        phone = value!;
      },
      validator: (value) {
        return Validator.validateRequired(value);
      },
      initialValue: '',
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white30, size: 22),
        // labelText: label,
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white, fontSize: 12),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        floatingLabelStyle: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  Widget _buildPasswodInputField(
    IconData icon,
    String label, {
    bool isPassword = false,
  }) {
    return TextFormField(
      obscureText: hidePassword,
      style: const TextStyle(color: Colors.white),
      onSaved: (value) {
        password = value!;
      },
      initialValue: '',
      validator: (value) {
        return Validator.validatePassword(value);
      },
      cursorColor: brandGreen,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white30, size: 22),
        // labelText: label,
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white, fontSize: 12),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        floatingLabelStyle: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
        ),
        filled: true,
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              hidePassword = !hidePassword;
            });
          },
          child: Icon(Icons.remove_red_eye, color: Colors.white30),
        ),
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/ForgotPassword');
        },
        child: Text(
          "Forgot Password?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(colors: [brandGreen, const Color(0xFF00B876)]),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {},
        child: const Text(
          "SIGN IN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Expanded(child: Divider(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_mobiledata, "Google"),
            // const SizedBox(width: 16),
            // _buildSocialButton(Icons.apple, "Apple"),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        _con.handleGoogleSignIn();
      },

      child: Container(
        width: 130,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Expanded(
        //   child: Text(
        //     "Don't have an account?",
        //     style: TextStyle(color: Colors.white.withOpacity(0.6)),
        //   ),
        // ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/CheckEmail');
          },
          child: Text(
            "Create an account",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
