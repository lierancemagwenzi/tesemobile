
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/models/country_model.dart';
import 'package:smacredit/src/auth/models/sign_up_type.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import '../../controller/LoginController.dart';
import '../../repository/login_repository.dart';
import '../../../helpers/Message.dart';
import '../../../helpers/Validator.dart';
import '../../../repositories/user_repository.dart';

class CheckEmailWidget extends StatefulWidget {
  final String? message;
  final SignUpType signUpType;
  final CountryModel? countryModel;

  const CheckEmailWidget({
    super.key,
    this.message,
    this.signUpType = SignUpType.supporter,
    this.countryModel,
  });

  @override
  _CheckEmailWidgetState createState() => _CheckEmailWidgetState();
}

class _CheckEmailWidgetState extends StateMVC<CheckEmailWidget> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  late LoginController _con;

  _CheckEmailWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  // Brand Colors (Standardized)
  final Color brandGreen = const Color(0xFF679E4F);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  void initState() {
    super.initState();
    if (widget.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomMessageHandler().showSuccessSnakeBar(context, widget.message!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: _con.scaffoldKey,
          resizeToAvoidBottomInset: true, // Better for email input
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildGlassCard(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned(
      top: -50,
      right: -50,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: brandGreen.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildGlassCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.05 : 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 35),
                _buildEmailField(),
                const SizedBox(height: 30),
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
        Image.asset(
          'assets/images/logo-light.png',
          height: 70,
          errorBuilder: (c, e, s) =>
              Icon(Icons.person_add_outlined, color: brandGreen, size: 60),
        ),
        const SizedBox(height: 15),
        const Text(
          "REGISTRATION",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
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
      cursorColor: brandGreen,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: Colors.white30,
          size: 22,
        ),
        hintText: "Email Address",
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brandGreen, width: 1.5),
        ),
      ),
    );
  }

Future<void> _onProceed() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _con.loading = true);
    final valid = await check_email({"email": email});
    if (!mounted) return;
    setState(() => _con.loading = false);

    if (valid != true) {
      CustomMessageHandler().showErrorSnakeBar(
        context,
        "Email is not available for use",
      );
      return;
    }

    current_registration_email.value = email;

    final country = widget.countryModel;
    if (country != null) {
      // Country already known — navigate directly to the right registration screen
      if (widget.signUpType == SignUpType.creator) {
        Navigator.of(context).pushReplacementNamed(
          '/RegistrationImages',
          arguments: country,
        );
      } else {
        Navigator.of(context).pushReplacementNamed(
          '/ClientRegistration',
          arguments: country,
        );
      }
    } else {
      // No country yet — let SelectCountry handle both country + type selection
      Navigator.of(context).pushReplacementNamed('/SelectCountry');
    }
  }

  Widget _buildProceedButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: [brandGreen, Colors.yellow.shade700]),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _onProceed,
        child: const Text(
          "PROCEED",
          style: TextStyle(
            color: Colors.white,
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

}
