// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/models/UserModel.dart';
// import 'package:smacredit/src/models/constants.dart';
// import '../../controller/LoginController.dart';
// import '../../../helpers/Validator.dart';

// class ResetPasswordWidget extends StatefulWidget {
//   final UserModel userModel;

//   ResetPasswordWidget({required this.userModel});

//   @override
//   _ResetPasswordWidgetState createState() => _ResetPasswordWidgetState();
// }

// class _ResetPasswordWidgetState extends StateMVC<ResetPasswordWidget> {
//   final _formKey = GlobalKey<FormState>();

//   String password = '';
//   String password2 = '';
//   bool hidePassword = true;
//   late LoginController _con;

//   _ResetPasswordWidgetState() : super(LoginController()) {
//     _con = controller as LoginController;
//   }
//   final Color primaryDark = const Color(0xFF1A0B2E);
//   // Brand Colors
//   final Color brandGreen = const Color(0xFF00D285);

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
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 35),
//                 _buildPasswordField(
//                   hint: "New Password",
//                   onSaved: (v) => password = v!,
//                   onChanged: (v) => setState(() {
//                     password = v ?? '';
//                   }),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildPasswordField(
//                   hint: "Confirm Password",
//                   onSaved: (v) => password2 = v!,
//                   validator: (value) {
//                     if (password.isEmpty) return null;
//                     if (value == null || value.isEmpty) return 'Required';
//                     if (password.trim() != value.trim())
//                       return 'Passwords do not match';
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 35),
//                 _buildSubmitButton(),
//                 const SizedBox(height: 25),
//                 _buildLoginLink(),
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
//           "RESET PASSWORD",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.w900,
//             letterSpacing: 2,
//           ),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           "Set a strong new password for your account",
//           style: TextStyle(color: Colors.white70, fontSize: 13),
//         ),
//       ],
//     );
//   }

//   Widget _buildPasswordField({
//     required String hint,
//     required FormFieldSetter<String> onSaved,
//     FormFieldSetter<String>? onChanged,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       obscureText: hidePassword,
//       onSaved: onSaved,
//       onChanged: onChanged,
//       validator: validator ?? (value) => Validator.validatePassword(value),
//       style: const TextStyle(color: Colors.white),
//       cursorColor: brandGreen,
//       decoration: InputDecoration(
//         prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
//         suffixIcon: IconButton(
//           icon: Icon(
//             hidePassword ? Icons.visibility_off : Icons.visibility,
//             color: Colors.white70,
//           ),
//           onPressed: () => setState(() => hidePassword = !hidePassword),
//         ),
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.white54),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.05),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: brandGreen, width: 2),
//         ),
//         errorStyle: TextStyle(color: brandGreen.withOpacity(0.9)),
//       ),
//     );
//   }

//   Widget _buildSubmitButton() {
//     return Container(
//       width: double.infinity,
//       height: 58,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: const LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: <Color>[Constants.yellowColor, Constants.greenColor],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: brandGreen.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
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
//         onPressed: () {
//           if (_formKey.currentState!.validate()) {
//             _formKey.currentState!.save();
//             _con.resetPassword({"password": password}, widget.userModel);
//           }
//         },
//         child: const Text(
//           "RESET PASSWORD",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.5,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginLink() {
//     return TextButton(
//       onPressed: () => Navigator.pushNamed(context, '/Login'),
//       child: RichText(
//         text: TextSpan(
//           style: const TextStyle(color: Colors.white70, fontSize: 14),
//           children: [
//             const TextSpan(text: "Change your mind? "),
//             TextSpan(
//               text: "Login",
//               style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/models/constants.dart';
import '../../controller/LoginController.dart';
import '../../../helpers/Validator.dart';

class ResetPasswordWidget extends StatefulWidget {
  final UserModel userModel;

  const ResetPasswordWidget({super.key, required this.userModel});

  @override
  _ResetPasswordWidgetState createState() => _ResetPasswordWidgetState();
}

class _ResetPasswordWidgetState extends StateMVC<ResetPasswordWidget> {
  final _formKey = GlobalKey<FormState>();

  String password = '';
  String password2 = '';
  bool hidePassword = true;
  late LoginController _con;

  _ResetPasswordWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  final Color primaryDark = const Color(0xFF1A0B2E);
  final Color brandGreen = const Color(0xFF00D285);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: true, // Improved for keyboard handling
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 2. App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. Glass Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildGlassCard(),
            ),
          ),

          // 4. Loading Overlay
          if (_con.loading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(color: brandGreen),
                ),
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
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 35),
                _buildPasswordField(
                  hint: "New Password",
                  onSaved: (v) => password = v ?? '',
                  onChanged: (v) => setState(() => password = v),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  hint: "Confirm Password",
                  onSaved: (v) => password2 = v ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (password.trim() != value.trim())
                      return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 35),
                _buildSubmitButton(),
                const SizedBox(height: 25),
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
              Icon(Icons.vpn_key_outlined, color: brandGreen, size: 60),
        ),
        const SizedBox(height: 20),
        const Text(
          "RESET PASSWORD",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Ensure your new password is secure and at least 8 characters long.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required FormFieldSetter<String> onSaved,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      obscureText: hidePassword,
      onSaved: onSaved,
      onChanged: onChanged,
      validator: validator ?? (value) => Validator.validatePassword(value),
      style: const TextStyle(color: Colors.white),
      cursorColor: brandGreen,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: Colors.white38,
          size: 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            hidePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.white38,
            size: 20,
          ),
          onPressed: () => setState(() => hidePassword = !hidePassword),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brandGreen, width: 1.5),
        ),
        errorStyle: TextStyle(color: brandGreen.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [brandGreen, const Color(0xFF00B876)]),
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
            _con.resetPassword({"password": password}, widget.userModel);
          }
        },
        child: const Text(
          "UPDATE PASSWORD",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/Login'),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          children: [
            const TextSpan(text: "Back to "),
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
