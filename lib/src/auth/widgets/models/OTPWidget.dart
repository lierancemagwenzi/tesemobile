// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:otp_text_field/otp_field.dart';
// import 'package:otp_text_field/otp_field_style.dart';
// import 'package:otp_text_field/style.dart';
// import 'package:smacredit/src/models/UserModel.dart';
// import '../../controller/LoginController.dart';

// class OTPWidget extends StatefulWidget {
//   final UserModel userModel;
//   final String action;

//   OTPWidget({Key? key, required this.userModel, required this.action})
//     : super(key: key);

//   @override
//   _OTPWidgetState createState() => _OTPWidgetState();
// }

// class _OTPWidgetState extends StateMVC<OTPWidget> {
//   late LoginController _con;

//   _OTPWidgetState() : super(LoginController()) {
//     _con = controller as LoginController;
//   }

//   final _formKey = GlobalKey<FormState>();
//   String otp = '';
//   OtpFieldController otpController = OtpFieldController();

//   // Tese Africa Brand Colors
//   final Color brandGreen = const Color(0xFF00D285);
//   final Color primaryDark = const Color(0xFF1A0B2E);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _con.scaffoldKey,
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           // 1. FULL BACKGROUND IMAGE
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   primaryDark,
//                   const Color(0xFF2D1B4E),
//                   brandGreen.withOpacity(0.2),
//                 ],
//               ),

//               // image: DecorationImage(
//               //   image: AssetImage('assets/images/background.png'),
//               //   fit: BoxFit.cover,
//               // ),
//             ),
//           ),
//           // 2. DARK OVERLAY
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             color: Colors.black.withOpacity(0.55),
//           ),
//           // 3. APP BAR
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               leading: const BackButton(color: Colors.white),
//             ),
//           ),

//           Positioned(
//             top: -50,
//             right: -50,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: brandGreen.withOpacity(0.15),
//               ),
//             ),
//           ),
//           // 4. GLASS CARD CONTENT
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: _buildGlassCard(),
//             ),
//           ),
//           // 5. LOADING OVERLAY
//           if (_con.loading)
//             Container(
//               color: Colors.black45,
//               child: Center(
//                 child: CircularProgressIndicator(color: brandGreen),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGlassCard() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(30),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//               width: 1.5,
//             ),
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 40),
//                 _buildOtpField(),
//                 const SizedBox(height: 30),
//                 _buildResendButton(),
//                 const SizedBox(height: 40),
//                 _buildNextButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Image.asset('assets/images/logo-light.png', height: 70),
//         const SizedBox(height: 20),
//         const Text(
//           "VERIFY EMAIL",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.w900,
//             letterSpacing: 2,
//           ),
//         ),
//         const SizedBox(height: 12),
//         RichText(
//           textAlign: TextAlign.center,
//           text: TextSpan(
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//               height: 1.5,
//             ),
//             children: [
//               const TextSpan(text: "Enter the 6-digit code sent to\n"),
//               TextSpan(
//                 text: widget.userModel.user?.email ?? "",
//                 style: TextStyle(
//                   color: brandGreen,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOtpField() {
//     return OTPTextField(
//       controller: otpController,
//       length: 6,
//       width: MediaQuery.of(context).size.width,
//       textFieldAlignment: MainAxisAlignment.spaceAround,
//       fieldWidth: 40,
//       fieldStyle: FieldStyle.box,
//       outlineBorderRadius: 12,
//       style: const TextStyle(
//         fontSize: 20,
//         color: Colors.white,
//         fontWeight: FontWeight.bold,
//       ),
//       otpFieldStyle: OtpFieldStyle(
//         backgroundColor: Colors.white.withOpacity(0.05),
//         borderColor: Colors.white24,
//         disabledBorderColor: Colors.white10,
//         enabledBorderColor: Colors.white24,
//         // focusedBorderColor: brandGreen,
//       ),
//       onChanged: (pin) => setState(() => otp = pin),
//       onCompleted: (pin) => setState(() => otp = pin),
//     );
//   }

//   Widget _buildResendButton() {
//     return InkWell(
//       onTap: _con.loading
//           ? null
//           : () {
//               Map map = {
//                 "email": widget.userModel.user?.email,
//                 "token": widget.userModel.token,
//               };
//               _con.resendOTP(map, widget.userModel.token ?? '');
//             },
//       child: Text(
//         "Didn't receive code? Resend OTP",
//         style: TextStyle(
//           color: _con.loading ? Colors.white24 : brandGreen,
//           fontWeight: FontWeight.w600,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }

//   Widget _buildNextButton() {
//     bool isComplete = otp.length == 6;

//     return Container(
//       width: double.infinity,
//       height: 58,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: isComplete
//             ? LinearGradient(colors: [brandGreen, const Color(0xFF00B876)])
//             : null,
//         color: isComplete ? null : Colors.white.withOpacity(0.1),
//         boxShadow: [
//           if (isComplete)
//             BoxShadow(
//               color: brandGreen.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 8),
//             ),
//         ],
//       ),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         onPressed: isComplete
//             ? () {
//                 Map map = {
//                   "email": widget.userModel.user?.email,
//                   "otp": otp,
//                   "token": widget.userModel.token,
//                 };
//                 _con.verifyOtp(map, widget.userModel, widget.action);
//               }
//             : null,
//         child: Text(
//           "VERIFY",
//           style: TextStyle(
//             color: isComplete ? Colors.white : Colors.white24,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 2,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart'; // Using your overlay
import '../../controller/LoginController.dart';

class OTPWidget extends StatefulWidget {
  final UserModel userModel;
  final String action;

  const OTPWidget({super.key, required this.userModel, required this.action});

  @override
  _OTPWidgetState createState() => _OTPWidgetState();
}

class _OTPWidgetState extends StateMVC<OTPWidget> {
  late LoginController _con;

  _OTPWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  final _formKey = GlobalKey<FormState>();
  String otp = '';
  OtpFieldController otpController = OtpFieldController();

  // Brand Colors
  final Color brandGreen = const Color(0xFF679E4F);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomInset: true, // Allow scrolling when keyboard is up
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              // App Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Content
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
                const SizedBox(height: 40),
                _buildOtpField(),
                const SizedBox(height: 30),
                _buildResendButton(),
                const SizedBox(height: 40),
                _buildVerifyButton(),
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
              Icon(Icons.shield_outlined, color: brandGreen, size: 60),
        ),
        const SizedBox(height: 20),
        const Text(
          "VERIFY EMAIL",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: "Enter the 6-digit code sent to\n"),
              TextSpan(
                text: widget.userModel.user?.email ?? "",
                style: TextStyle(
                  color: brandGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpField() {
    return OTPTextField(
      controller: otpController,
      length: 6,
      width: MediaQuery.of(context).size.width,
      textFieldAlignment: MainAxisAlignment.spaceAround,
      fieldWidth: 38,
      fieldStyle: FieldStyle.box,
      outlineBorderRadius: 12,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      otpFieldStyle: OtpFieldStyle(
        backgroundColor: Colors.white.withOpacity(0.05),
        borderColor: Colors.white24,
        enabledBorderColor: Colors.white24,
        focusBorderColor: brandGreen, // Guide the user
      ),
      onChanged: (pin) => setState(() => otp = pin),
      onCompleted: (pin) => setState(() => otp = pin),
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: _con.loading
          ? null
          : () {
              Map map = {
                "email": widget.userModel.user?.email,
                "token": widget.userModel.token,
              };
              _con.resendOTP(map, widget.userModel.token ?? '');
            },
      child: Text(
        "Didn't receive code? Resend OTP",
        style: TextStyle(
          color: _con.loading ? Colors.white24 : brandGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    bool isComplete = otp.length == 6;

    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: isComplete
            ? LinearGradient(colors: [brandGreen, Colors.yellow.shade700])
            : null,
        color: isComplete ? null : Colors.white.withOpacity(0.1),
        boxShadow: isComplete
            ? [
                BoxShadow(
                  color: brandGreen.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextButton(
        onPressed: isComplete
            ? () {
                Map map = {
                  "email": widget.userModel.user?.email,
                  "otp": otp,
                  "token": widget.userModel.token,
                };
                _con.verifyOtp(map, widget.userModel, widget.action);
              }
            : null,
        child: Text(
          "VERIFY",
          style: TextStyle(
            color: isComplete ? Colors.white : Colors.white24,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
