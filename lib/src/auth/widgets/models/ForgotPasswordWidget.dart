import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/models/constants.dart';
import '../../controller/LoginController.dart';
import '../../../helpers/Message.dart';
import '../../../helpers/Validator.dart';

class ForgotPasswordWidget extends StatefulWidget {
  final String? message;

  ForgotPasswordWidget({this.message});

  @override
  _ForgotPasswordWidgetState createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends StateMVC<ForgotPasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  late LoginController _con;

  _ForgotPasswordWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  // Brand Colors
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. FULL BACKGROUND IMAGE
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryDark,
                  const Color(0xFF2D1B4E),
                  brandGreen.withOpacity(0.2),
                ],
              ),
              // image: DecorationImage(
              //   image: AssetImage('assets/images/background.png'),
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          // 2. DARK OVERLAY
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.55),
          ),
          // 3. APP BAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const BackButton(color: Colors.white),
            ),
          ),

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
          // 4. GLASS CARD CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildGlassCard(),
            ),
          ),
          // 5. LOADING OVERLAY
          if (_con.loading)
            Container(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(color: brandGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 35),
                _buildSubmitButton(),
                const SizedBox(height: 25),
                _buildBackToLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/images/logo.png', height: 70),
        const SizedBox(height: 20),
        const Text(
          "FORGOT PASSWORD",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Enter your email address to receive a password reset code.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      onSaved: (value) => email = value!,
      validator: (value) => Validator.validateRequired(value),
      style: const TextStyle(color: Colors.white),
      cursorColor: brandGreen,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
        hintText: "Email Address",
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brandGreen, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Constants.yellowColor, Constants.greenColor],
        ),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _con.sendForgotPassword({"email": email});
          }
        },
        child: const Text(
          "CHECK ACCOUNT",
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

  Widget _buildBackToLogin() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/Login'),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          children: [
            const TextSpan(text: "Remember account? "),
            TextSpan(
              text: "Login",
              style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
