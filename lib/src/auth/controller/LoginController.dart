import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smacredit/src/auth/models/country_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http_parser/http_parser.dart';
import 'package:smacredit/client/respository/client_repositoy.dart';
import 'package:smacredit/src/auth/models/ExtractIDModel.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/auth/models/VerifyID.dart';
import 'package:smacredit/src/auth/models/terms_response.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/payments/models/currencyModel.dart';
import 'package:smacredit/src/payments/repository/payments_repository.dart';
import 'package:smacredit/src/profile/models/account_info.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import '../../helpers/Message.dart';

import '../repository/login_repository.dart';

class LoginController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool loading = false;
  static const String _webClientId =
      '861792777675-h57k0qrh9j0qlm3nkj56p4v948q7kh7h.apps.googleusercontent.com';
  // Define your scopes in a list
  final List<String> _scopes = ['email', 'profile'];
  TermsResponse? termsResponse;
  LoginController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  List<CurrencyModel> currencies = [];
  setinstalled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('installed', true);
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? userInfo;

  Future<void> handleGoogleSignIn({bool isSignUp = false, int? countryId}) async {
    try {
      await _googleSignIn.initialize(serverClientId: _webClientId);

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: _scopes,
      );

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) return;

      String? firstName;
      String? lastName;

      if (isSignUp) {
        final nameParts = (googleUser.displayName ?? '').trim().split(' ');
        firstName = nameParts.isNotEmpty ? nameParts.first : null;
        lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;
      }

      setState(() => loading = true);

      final result = await google_sign_in(
        idToken,
        firstName: firstName,
        lastName: lastName,
        countryId: isSignUp ? countryId : null,
      );

      if (result.user != null) {
        await _finishGoogleLogin(result.user!);
      } else if (result.accountNotFound) {
        // Account doesn't exist — ask for name + country and register
        setState(() => loading = false);
        final names = await _showNameDialog(scaffoldKey.currentContext!);
        if (names == null) return; // user cancelled

        setState(() => loading = true);
        final registeredUser = await google_registration(
          idToken,
          firstName: names['firstName'] as String,
          lastName: names['lastName'] as String,
          countryId: names['countryId'] as int?,
        );

        if (registeredUser != null) {
          await _finishGoogleLogin(registeredUser);
        } else {
          setState(() => loading = false);
          CustomMessageHandler().showErrorSnakeBar(
            scaffoldKey.currentContext!,
            "Registration failed. Please try again.",
          );
        }
      } else {
        setState(() => loading = false);
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong. Try again",
        );
      }
    } catch (error) {
      setState(() => loading = false);
      debugPrint('Google Sign-In Error: $error');
      CustomMessageHandler().showErrorSnakeBar(
        scaffoldKey.currentContext!,
        "Something went wrong. Try again",
      );
    }
  }

  Future<void> _finishGoogleLogin(UserModel user) async {
    currentuser.value = user;
    try {
      await FirebaseAuth.instance.signInWithCustomToken(
        currentuser.value.user?.fireBaseToken ?? "",
      );
      debugPrint('Firebase auth completed');
    } catch (e) {
      debugPrint("Firebase sync failed: $e");
    }
    setState(() => loading = false);
    Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed('/Dashboard');
  }

  Future<void> handleAppleSignIn({bool isSignUp = false, int? countryId}) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? identityToken = credential.identityToken;
      if (identityToken == null) return;

      String? firstName;
      String? lastName;

      if (isSignUp) {
        firstName = credential.givenName;
        lastName = credential.familyName;

        // Apple only returns the name on the very first authorization.
        // If it's missing, ask the user to enter it manually.
        if ((firstName == null || firstName.isEmpty) ||
            (lastName == null || lastName.isEmpty)) {
          final names = await _showNameDialog(scaffoldKey.currentContext!);
          if (names == null) return; // user cancelled
          firstName = names['firstName'] as String?;
          lastName = names['lastName'] as String?;
        }
      }

      setState(() => loading = true);

      final result = await apple_sign_in(
        identityToken,
        firstName: firstName,
        lastName: lastName,
        countryId: isSignUp ? countryId : null,
      );

      if (result.user != null) {
        await _finishAppleLogin(result.user!);
      } else if (result.accountNotFound) {
        // Account doesn't exist — ask for name and register
        setState(() => loading = false);
        final names = await _showNameDialog(scaffoldKey.currentContext!);
        if (names == null) return; // user cancelled

        setState(() => loading = true);
        final registeredUser = await apple_registration(
          identityToken,
          firstName: names['firstName'] as String,
          lastName: names['lastName'] as String,
          countryId: names['countryId'] as int?,
        );

        if (registeredUser != null) {
          await _finishAppleLogin(registeredUser);
        } else {
          setState(() => loading = false);
          CustomMessageHandler().showErrorSnakeBar(
            scaffoldKey.currentContext!,
            "Registration failed. Please try again.",
          );
        }
      } else {
        setState(() => loading = false);
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Apple Sign-In failed. Try again",
        );
      }
    } catch (error) {
      setState(() => loading = false);
      debugPrint('Apple Sign-In Error: $error');
      CustomMessageHandler().showErrorSnakeBar(
        scaffoldKey.currentContext!,
        "Apple Sign-In was cancelled or failed",
      );
    }
  }

  Future<void> _finishAppleLogin(UserModel user) async {
    currentuser.value = user;
    try {
      await FirebaseAuth.instance.signInWithCustomToken(
        currentuser.value.user?.fireBaseToken ?? "",
      );
    } catch (e) {
      debugPrint("Firebase sync failed: $e");
    }
    setState(() => loading = false);
    Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed('/Dashboard');
  }

  /// Shows a dialog asking the user for their first name, last name, and country.
  /// Returns a map with 'firstName', 'lastName', and 'countryId', or null if cancelled.
  Future<Map<String, dynamic>?> _showNameDialog(BuildContext context) async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Load countries before showing the dialog
    final List<CountryModel> countries = await get_countries();

    if (!context.mounted) return null;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AppleRegistrationDialog(
        formKey: formKey,
        firstNameController: firstNameController,
        lastNameController: lastNameController,
        countries: countries,
      ),
    );
  }

  AccountInfo? accountInfo;
  UploadIdModel? selfie;

  UploadIdModel? idFront;
  UploadIdModel? idBack;
  Future<void> listenForCurrencies() async {
    setState(() {
      loading = true;
    });
    currencies.clear();
    final Stream<CurrencyModel> stream = await get_currencies();

    stream.listen(
      (CurrencyModel employerModel) {
        setState(() => currencies.add(employerModel));
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        print(a);
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<TermsResponse?> getCurrentTerms() async {
    setState(() {
      loading = true;
    });
   
   final terms = await  get_terms();
  
    setState(() {
      loading = false;
    });
  return terms;
  }

  void getClientAccountInfo() {
    setState(() {
      loading = true;
    });
    get_client_account_info({}).then((value) async {
      if (value != null) {
        setState(() {
          userInfo = value;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }

  Future<void> uploadProfile(File file, bool isProfile) async {
    setState(() {
      loading = true;
    });
    upload_profile(file, isProfile).then((v) {
      setState(() {
        loading = false;
      });
      if (v != null) {
        setState(() {
          userInfo = v;
        });
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  void getAccountInfo() {
    setState(() {
      loading = true;
    });
    get_account_info({}).then((value) async {
      if (value != null) {
        setState(() {
          accountInfo = value;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        // CustomMessageHandler().showErrorSnakeBar(
        //   scaffoldKey.currentContext!,
        //   "Something went wrong.Try again",
        // );
      }
    });
  }

  Future<bool?> updatePassword(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      bool? response = await update_password(map);
      setState(() {
        loading = false;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  Future<User?> updateClientAccount(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      User? response = await update_client_account(map);
      setState(() {
        loading = false;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  void deleteAccount(String reason) {
    setState(() {
      loading = true;
    });
    delete_account(reason).then((value) async {
      if (value != null) {
        Navigator.pushNamed(
          scaffoldKey.currentContext!,
          '/Login',
          arguments: 'Account deleted successfully',
        );
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  void loginUser(Map map) {
    setState(() {
      loading = true;
    });
    LoginappUser(map).then((value) async {
      if (value != null) {
        if (value.userModel != null) {
          // Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed('/Dashboard',arguments: value.userModel);

          Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed(
            '/OTP',
            arguments: {'user': value.userModel, 'action': 'login'},
          );
          // currentuser.value=value.userModel!;
          //
          // currentuser.notifyListeners();
          // Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed('/Dashboard');
        } else {
          setState(() {
            loading = false;
          });
          CustomMessageHandler().showErrorSnakeBar(
            scaffoldKey.currentContext!,
            value.message!,
          );
        }

        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  void registerTheUser(Map map) {
    setState(() {
      loading = true;
    });
    registerUser(map).then((value) async {
      print(value);
      if (value != null) {
        setState(() {
          loading = false;
        });
        Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed(
          '/ClientLogin',
          arguments:
              "Registered successfully.Please login with your credentials",
        );
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  void registerTheClient(Map map) {
    setState(() {
      loading = true;
    });
    registerClient(map).then((value) async {
      if (value != null) {
        Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed(
          '/ClientLogin',
          arguments:
              "Registered successfully.Please login with your credentials",
        );

        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> renewToken(String token) async {
    setState(() {
      loading = true;
    });

    UserModel? user = await renew_token(token);
    setState(() {
      loading = false;
    });
    if (user != null) {
      currentuser.value = user;
      try {
        await FirebaseAuth.instance.signInWithCustomToken(
          currentuser.value.user?.fireBaseToken ?? "",
        );
        print('firebase auth completed');
      } catch (e) {
        debugPrint("Firebase sync failed: $e");
      }
      Navigator.pushNamed(scaffoldKey.currentContext!, '/Dashboard');
    } else {
      CustomMessageHandler().showErrorSnakeBar(
        scaffoldKey.currentContext!,
        "Something went wrong.Try again wih email and password",
      );
    }
  }

  void verifyOtp(Map map, UserModel userModel, String action) {
    setState(() {
      loading = true;
    });
    verifyUserOtp(map, userModel.token ?? '').then((value) async {
      if (value != null) {
        currentuser.value = value;
        try {
          await FirebaseAuth.instance.signInWithCustomToken(
            currentuser.value.user?.fireBaseToken ?? "",
          );
          print('firebase auth completed');
        } catch (e) {
          debugPrint("Firebase sync failed: $e");
        }
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        currentuser.notifyListeners();

        if (action == 'resetPassword') {
          Navigator.of(
            scaffoldKey.currentContext!,
          ).pushReplacementNamed('/ResetPassword', arguments: value);
        } else if (action == 'register') {
          Navigator.of(
            scaffoldKey.currentContext!,
          ).pushReplacementNamed('/SelectCountry', arguments: value);
        } else {
          Navigator.of(
            scaffoldKey.currentContext!,
          ).pushReplacementNamed('/Dashboard');
        }

        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Failed to verify OTP.Try again",
        );
      }
    });
  }

  void resetPassword(Map map, UserModel userModel) {
    setState(() {
      loading = true;
    });
    reset_password(map, userModel.token ?? '').then((value) async {
      if (value != null) {
        Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed(
          '/Login',
          arguments: 'Password reset successfully',
        );
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Failed to reset password.Try again",
        );
      }
    });
  }

  void checkEmail(Map map) {
    setState(() {
      loading = true;
    });
    check_email(map).then((value) async {
      if (value != null && value == true) {
        // CustomMessageHandler().showSuccessSnakeBar(
        //   scaffoldKey.currentContext!,
        //   "Password reset link sent successfully",
        // );

        current_registration_email.value = map['email'];
        Navigator.of(
          scaffoldKey.currentContext!,
        ).pushReplacementNamed('/SelectCountry', arguments: map['email']);
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Email is not available for use",
        );
      }
    });
  }

  void sendForgotPassword(Map map, {String action = 'resetPassword'}) {
    setState(() {
      loading = true;
    });
    forgotPassword(map).then((value) async {
      if (value != null) {
        // CustomMessageHandler().showSuccessSnakeBar(
        //   scaffoldKey.currentContext!,
        //   "Password reset link sent successfully",
        // );

        Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed(
          '/OTP',
          arguments: {'user': value, 'action': action},
        );
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Failed to verify user.Try again",
        );
      }
    });
  }

  void resendOTP(Map map, String token) {
    setState(() {
      loading = true;
    });
    resendUserOtp(map, token).then((value) async {
      if (value != null) {
        CustomMessageHandler().showSuccessSnakeBar(
          scaffoldKey.currentContext!,
          "OTP sent successfully",
        );
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<ExtractIdModel?> extractIDDetail(Map map) async {
    setState(() {
      loading = true;
    });

    // await extractIDDetails(map).then((value) async {
    ExtractIdModel? extractIdModel = await extractIDDetails(map);
    setState(() {
      loading = false;
    });
    return extractIdModel;
    // print("value is ${value?.toJson()}");
    //   if (value != null) {
    //     print("not null");
    //     setState(() {
    //       loading = false;
    //     });
    //
    //     return value;
    //   } else {
    //     setState(() {
    //       loading = false;
    //     });
    //     CustomMessageHandler().showErrorSnakeBar(scaffoldKey.currentContext!, "Something went wrong.Try again");
    //
    //     return null;
    //   }
    // });
  }

  Future<VerifyIDModel?> VerifyID(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      var result = await verify_id(map);
      setState(() {
        loading = false;
      });
      return result;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  uploadSelfie(File files) async {
    setState(() {
      loading = true;
    });
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/registration/selfie-upload",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    request.fields['extension'] = files.path.split('.').last;
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];

    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'selfieImage',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    request.fields['uploads'] = jsonEncode(files2);

    // http.StreamedResponse response = await request.send();

    Future<http.StreamedResponse> responseFuture = request.send();
    http.StreamedResponse response = await responseFuture.timeout(
      Duration(seconds: 60),
      onTimeout: () {
        // This block is executed if the timeout occurs
        throw TimeoutException('Request timed out after  seconds.');
      },
    );
    var responseB = await http.Response.fromStream(response);

    print(responseB.body);
    if (response.statusCode == 200) {
      UploadIdModel uploadIdModel = UploadIdModel.fromJson(
        jsonDecode(responseB.body),
      );
      selfie = uploadIdModel;
      setState(() {
        loading = false;
      });

      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      setState(() {
        loading = false;
      });
      CustomMessageHandler().showErrorSnakeBar(
        scaffoldKey.currentContext!,
        "Something went wrong with the upload.Try again",
      );
    }
    print(response.statusCode);
  }

  uploadIDFront(File files, File idBack) async {
    setState(() {
      loading = true;
    });
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/registration/selfie-upload",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    // request.fields['document_id'] = id.toString();
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];
    request.fields['extension'] = files.path.split('.').last;
    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'selfieImage',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    request.fields['uploads'] = jsonEncode(files2);

    Future<http.StreamedResponse> responseFuture = request.send();
    http.StreamedResponse response = await responseFuture.timeout(
      Duration(seconds: 60),
      onTimeout: () {
        // This block is executed if the timeout occurs
        throw TimeoutException('Request timed out after  seconds.');
      },
    );
    var responseB = await http.Response.fromStream(response);

    print(responseB.body);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
      });

      UploadIdModel uploadIdModel = UploadIdModel.fromJson(
        jsonDecode(responseB.body),
      );
      idFront = uploadIdModel;

      uploadIDBack(idBack);
      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      setState(() {
        loading = false;
      });
      CustomMessageHandler().showErrorSnakeBar(
        scaffoldKey.currentContext!,
        "Something went wrong with the upload.Try again",
      );
    }
    print(response.statusCode);
  }

  uploadIDBack(File files) async {
    setState(() {
      loading = true;
    });
    var postUri = Uri.parse(
      "${GlobalConfiguration().getValue('api_base_url')}/registration/selfie-upload",
    );
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    // request.fields['document_id'] = id.toString();
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2 = [];
    request.fields['extension'] = files.path.split('.').last;
    File element = files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'selfieImage',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    request.fields['uploads'] = jsonEncode(files2);

    Future<http.StreamedResponse> responseFuture = request.send();
    http.StreamedResponse response = await responseFuture.timeout(
      Duration(seconds: 60),
      onTimeout: () {
        // This block is executed if the timeout occurs
        throw TimeoutException('Request timed out after  seconds.');
      },
    );
    var responseB = await http.Response.fromStream(response);

    print(responseB.body);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
      });

      UploadIdModel uploadIdModel = UploadIdModel.fromJson(
        jsonDecode(responseB.body),
      );
      idBack = uploadIdModel;
      Navigator.pop(scaffoldKey.currentContext!, [idFront!, idBack!]);
    } else {
      setState(() {
        loading = false;
      });
      CustomMessageHandler().showErrorSnakeBar(
        scaffoldKey.currentContext!,
        "Something went wrong with the upload.Try again",
      );
    }
    print(response.statusCode);
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    currentuser.value = UserModel();

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/Login',
        (_) => false,
      );
    }
  }
}

/// Stateful dialog widget so the country dropdown can update independently.
class _AppleRegistrationDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final List<CountryModel> countries;

  const _AppleRegistrationDialog({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.countries,
  });

  @override
  State<_AppleRegistrationDialog> createState() =>
      _AppleRegistrationDialogState();
}

class _AppleRegistrationDialogState extends State<_AppleRegistrationDialog> {
  CountryModel? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete your profile'),
      content: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please enter your details to create your account.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CountryModel>(
                value: _selectedCountry,
                decoration: const InputDecoration(labelText: 'Country'),
                isExpanded: true,
                items: widget.countries
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.flag}  ${c.name}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCountry = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (widget.formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'firstName': widget.firstNameController.text.trim(),
                'lastName': widget.lastNameController.text.trim(),
                'countryId': _selectedCountry?.id,
              });
            }
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
