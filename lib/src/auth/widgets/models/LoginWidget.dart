import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smacredit/src/auth/controller/auth_service.dart';
import 'package:smacredit/src/auth/controller/shared_preferences_helper.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../../../helpers/Message.dart';
import '../../../helpers/Validator.dart';
import '../../../scanner/IDScanner.dart';
import '../../../widgets/CustomButtons.dart';
import '../../controller/LoginController.dart';
import 'package:local_auth/local_auth.dart';

class LoginWidget extends StatefulWidget {
  String? message;

  LoginWidget({this.message});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
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

  _LoginWidgetState() : super(LoginController()) {
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
      child: CustomOverlay(
        loading: _con.loading,
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _con.scaffoldKey,
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/CheckEmail');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: Constants.greyColor),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "Register",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: Constants.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Login",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge!.copyWith(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    onSaved: (value) {
                      phone = value!;
                    },
                    validator: (value) {
                      return Validator.validateRequired(value);
                    },
                    initialValue: '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Constants.greyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Constants.greyColor,
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "Email or phone",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    obscureText: hidePassword,
                    onSaved: (value) {
                      password = value!;
                    },
                    initialValue: '',
                    validator: (value) {
                      return Validator.validatePassword(value);
                    },
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        child: Icon(Icons.remove_red_eye),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Constants.greyColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Constants.greyColor,
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "Password",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButtons.filledButton(
                    text: 'Sign In',
                    callback: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _con.loginUser({"email": phone, "password": password});
                      }
                    },
                  ),
                  const SizedBox(height: 48),

                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/ForgotPassword');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, color: Constants.greyColor),
                        const SizedBox(width: 8),
                        Text(
                          "Forgot password",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: Constants.greyColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (canAuthenticate == true && token != null)
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
                          foregroundColor: Constants.greenColor,
                          side: const BorderSide(color: Constants.greenColor),
                        ),
                      ),
                    )
                  else
                    // Show a message if biometrics aren't available
                    const Text(
                      'Biometrics not available on this device.',
                      style: TextStyle(color: Colors.grey),
                    ),

                  SizedBox(height: 16),
                  CustomButtons.googleButton(() {
                    _con.handleGoogleSignIn();
                  }),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
