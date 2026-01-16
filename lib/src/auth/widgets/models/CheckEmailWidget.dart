import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/widgets/models/terms_widget2.dart';
import '../../controller/LoginController.dart';
import '../../../helpers/Message.dart';
import '../../../helpers/Validator.dart';

// Assuming these are your previously created screens
// import 'tese_terms_screen.dart';

class CheckEmailWidget extends StatefulWidget {
  final String? message;
  CheckEmailWidget({this.message});

  @override
  _CheckEmailWidgetState createState() => _CheckEmailWidgetState();
}

class _CheckEmailWidgetState extends StateMVC<CheckEmailWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isTermsAccepted = false;
  String email = '';
  late LoginController _con;

  _CheckEmailWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

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
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. FULL BACKGROUND IMAGE (Matches Login Theme)
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
                //   image: AssetImage('assets/images/bg.png'),
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            // 2. DARK OVERLAY
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
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
            // 3. MAIN CONTENT
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildGlassCard(),
              ),
            ),
            // 4. LOADING OVERLAY
            if (_con.loading)
              Container(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(color: brandGreen),
                ),
              ),
          ],
        ),
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
                const SizedBox(height: 35),
                _buildEmailField(),
                const SizedBox(height: 25),
                _buildLegalSection(),
                const SizedBox(height: 35),
                _buildProceedButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
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
        Image.asset('assets/images/logo-light.png', height: 70),
        const SizedBox(height: 15),
        const Text(
          "REGISTRATION",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const Text(
          "Enter your email to get started",
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      onSaved: (value) => email = value!,
      validator: (value) => Validator.validateRequired(value),
      style: const TextStyle(color: Colors.white),
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

  Widget _buildLegalSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _navigateToTerms,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: _isTermsAccepted ? brandGreen : Colors.white12,
            child: Icon(
              _isTermsAccepted ? Icons.check_circle : Icons.gavel_rounded,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Legal Agreement",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _isTermsAccepted
              ? "Terms Accepted"
              : "Review and accept terms to proceed",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _isTermsAccepted ? brandGreen : Colors.white60,
            fontSize: 12,
          ),
        ),
        if (!_isTermsAccepted)
          TextButton(
            onPressed: _navigateToTerms,
            child: Text(
              "VIEW TERMS",
              style: TextStyle(color: brandGreen, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [brandGreen, const Color(0xFF00B876)]),
        boxShadow: [
          if (_isTermsAccepted)
            BoxShadow(
              color: brandGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        onPressed: _isTermsAccepted
            ? () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _con.checkEmail({"email": email});
                }
              }
            : null,
        child: Text(
          "PROCEED",
          style: TextStyle(
            color: _isTermsAccepted ? Colors.white : Colors.white38,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/ClientLogin'),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          children: [
            const TextSpan(text: "Already have an account? "),
            TextSpan(
              text: "Login",
              style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTerms() {
    // Navigates to the TeseTermsScreen you built earlier
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeseTermsScreen(
          shouldAccept: true,
          onAcceptanceChanged: (bool p1) {
            setState(() {
              _isTermsAccepted = p1;
            });
          },
          // Pass any arguments needed for your terms screen
          // e.g., onAccept: () => setState(() => _isTermsAccepted = true)
        ),
      ),
    );
  }
}
