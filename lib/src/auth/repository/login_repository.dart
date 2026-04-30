import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:retry/retry.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smacredit/src/auth/models/VerifyID.dart';
import 'package:smacredit/src/auth/models/VerifyOTPModel.dart';
import 'package:smacredit/src/auth/models/WaitingPeriod.dart';
import 'package:smacredit/src/auth/models/country_model.dart';
import 'package:smacredit/src/auth/models/terms_response.dart';
import 'package:smacredit/src/auth/repository/inteceptor.dart';
import 'package:smacredit/src/profile/models/account_info.dart';

import '../../models/UserModel.dart';
import '../../repositories/user_repository.dart';
import '../controller/shared_preferences_helper.dart';
import '../models/ExtractIDModel.dart';
import '../models/LoginResponse.dart';
import '../models/SignUpModel.dart';

final http.Client client = RetryClient(
  http.Client(),
  // Or wherever your renewal endpoint is
);

Future<TermsResponse?> get_terms() async {
  final String renewUrl =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/terms-and-conditions?target=client';
  print('token is ${currentuser.value.token}');

  Map<String, String> headers = {'Content-Type': 'application/json'};

  if (currentuser.value.token != null) {
    headers[HttpHeaders.authorizationHeader] =
        'Bearer ${currentuser.value.token}';
  }
  try {
    final response = await client.get(Uri.parse(renewUrl), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(response.body);
      final TermsResponse? user = TermsResponse.fromJson(jsonResponse);

      if (user != null) {
        return user;
      }
    }
    if (kDebugMode) {
      print('Failed to renew token. User must re-login.');
    }
    return null;
  } catch (e) {
    print(e);

    return null;
  }
}

Future<UserModel?> renew_token(String token) async {
  final String renewUrl =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/renew-token';
  final response = await client.post(
    Uri.parse(renewUrl),
    headers: {
      // Send the old token for verification/renewal
      'Authorization': 'Bearer ${token}',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final UserModel? user = UserModel.fromJson(jsonResponse);

    if (user != null) {
      TokenService.setToken(user.token ?? '');

      currentuser.value = user; // Update the stored token
      return user;
    }
  }

  // Handle renewal failure (e.g., redirect to login)
  // TokenStorage.token = null;
  if (kDebugMode) {
    print('Failed to renew token. User must re-login.');
  }
  return null;
}

/// Returns `(user: UserModel, accountNotFound: false)` on success,
/// `(user: null, accountNotFound: true)` when the server says the account
/// doesn't exist (HTTP 404), or `(user: null, accountNotFound: false)` for
/// any other error.
Future<({UserModel? user, bool accountNotFound})> google_sign_in(
  String token, {
  String? firstName,
  String? lastName,
  int? countryId,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/google-sign-in';
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "idToken": token,
        if (firstName != null && firstName.isNotEmpty) "first_name": firstName,
        if (lastName != null && lastName.isNotEmpty) "last_name": lastName,
        if (countryId != null) "country_id": countryId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final UserModel? user = UserModel.fromJson(jsonResponse);
      if (user != null) {
        TokenService.setToken(user.token ?? '');
        currentuser.value = user;
        return (user: user, accountNotFound: false);
      }
    }

    if (response.statusCode == 404) {
      if (kDebugMode) print('Google sign-in: account not found');
      return (user: null, accountNotFound: true);
    }

    if (kDebugMode) {
      print('Google sign-in failed (${response.statusCode}): ${response.body}');
    }
    return (user: null, accountNotFound: false);
  } catch (e) {
    if (kDebugMode) print('Google sign-in error: $e');
    return (user: null, accountNotFound: false);
  }
}

Future<UserModel?> google_registration(
  String idToken, {
  required String firstName,
  required String lastName,
  int? countryId,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/google-register';
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "idToken": idToken,
        "first_name": firstName,
        "last_name": lastName,
        if (countryId != null) "country_id": countryId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final UserModel? user = UserModel.fromJson(jsonResponse);
      if (user != null) {
        TokenService.setToken(user.token ?? '');
        currentuser.value = user;
        return user;
      }
    }
    if (kDebugMode) {
      print('Google registration failed (${response.statusCode}): ${response.body}');
    }
    return null;
  } catch (e) {
    if (kDebugMode) print('Google registration error: $e');
    return null;
  }
}

/// Returns `(user: UserModel, accountNotFound: false)` on success,
/// `(user: null, accountNotFound: true)` when the server says the account
/// doesn't exist (HTTP 404), or `(user: null, accountNotFound: false)` for
/// any other error.
Future<({UserModel? user, bool accountNotFound})> apple_sign_in(
  String identityToken, {
  String? firstName,
  String? lastName,
  int? countryId,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/apple-sign-in';
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "identity_token": identityToken,
        "platform": "ios",
        if (firstName != null) "first_name": firstName,
        if (lastName != null) "last_name": lastName,
        if (countryId != null) "country_id": countryId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final UserModel? user = UserModel.fromJson(jsonResponse);
      if (user != null) {
        TokenService.setToken(user.token ?? '');
        currentuser.value = user;
        return (user: user, accountNotFound: false);
      }
    }

    if (response.statusCode == 404) {
      if (kDebugMode) print('Apple sign-in: account not found');
      return (user: null, accountNotFound: true);
    }

    if (kDebugMode) {
      print('Apple sign-in failed (${response.statusCode}): ${response.body}');
    }
    return (user: null, accountNotFound: false);
  } catch (e) {
    if (kDebugMode) print('Apple sign-in error: $e');
    return (user: null, accountNotFound: false);
  }
}

Future<UserModel?> apple_registration(
  String identityToken, {
  required String firstName,
  required String lastName,
  int? countryId,
}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/apple-register';
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "identity_token": identityToken,
        "platform": "ios",
        "first_name": firstName,
        "last_name": lastName,
        if (countryId != null) "country_id": countryId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final UserModel? user = UserModel.fromJson(jsonResponse);
      if (user != null) {
        TokenService.setToken(user.token ?? '');
        currentuser.value = user;
        return user;
      }
    }
    if (kDebugMode) {
      print('Apple registration failed (${response.statusCode}): ${response.body}');
    }
    return null;
  } catch (e) {
    if (kDebugMode) print('Apple registration error: $e');
    return null;
  }
}

Future<UserModel?> delete_account(String reason) async {
  final String renewUrl =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/delete-account';
  print('token is ${currentuser.value.token}');
  final response = await client.post(
    Uri.parse(renewUrl),
    headers: {
      // Send the old token for verification/renewal
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${currentuser.value.token}',
    },
    body: jsonEncode({"reason": reason}),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final UserModel? user = UserModel.fromJson(jsonResponse);

    if (user != null) {
      return user;
    }
  }
  if (kDebugMode) {
    print('Failed to renew token. User must re-login.');
  }
  return null;
}

Future<VerifyIDModel?> verify_id(Map map) async {
  print("#verify_id user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/registration/verify-id';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      VerifyIDModel userModel = VerifyIDModel.fromJson(
        json.decode(response.body),
      );
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<bool?> update_password(Map map) async {
  print("#createbank user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/update-password';
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: jsonEncode(map),
        )
        .timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e);
    }
    return null;
  }
}

Future<User?> update_client_account(Map map) async {
  print("#update_client_account user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/update-client-account';
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: jsonEncode(map),
        )
        .timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e);
    }
    return null;
  }
}

Future<AccountInfo?> update_bank(Map map) async {
  print("#createbank user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/update-bank';
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: jsonEncode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      AccountInfo userModel = AccountInfo.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e);
    return null;
  }
}

Future<AccountInfo?> create_bank(Map map) async {
  print("#createbank user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/add-bank';
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: jsonEncode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      AccountInfo userModel = AccountInfo.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e);
    return null;
  }
}

Future<AccountInfo?> update_profile_bank(Map map) async {
  print("#createbank user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/update-profile-bank';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: jsonEncode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      AccountInfo userModel = AccountInfo.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e);
    return null;
  }
}

Future<AccountInfo?> get_account_info(Map map) async {
  print("#account user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/account-info';
  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      AccountInfo userModel = AccountInfo.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e, s) {
    return null;
  } on Error catch (e, s) {
    print("error");
    print('Caught error: $e');
    print('Stack trace: $s');
    return null;
  }
}

Future<User?> get_client_account_info(Map map) async {
  print("#account user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/get-account';
  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      User userModel = User.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e, s) {
    return null;
  } on Error catch (e, s) {
    print("error");
    print('Caught error: $e');
    print('Stack trace: $s');
    return null;
  }
}

Future<AccountInfo?> get_account_banks(Map map) async {
  print("#account user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/account-banks';
  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      AccountInfo userModel = AccountInfo.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<SignUpModel?> registerClient(Map map) async {
  print("#register client");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/registration/client-register';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      SignUpModel userModel = SignUpModel.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<SignUpModel?> registerUser(Map map) async {
  print("#register user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/registration/register';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 460));

    if (response.statusCode == 200) {
      print(response.body);

      SignUpModel userModel = SignUpModel.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<UserModel?> reset_password(Map map, String token) async {
  print("#verify user");
  print(map);
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/login/reset-password';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },

          body: json.encode(map),
        )
        .timeout(Duration(seconds: 6));

    print(response.body);
    if (response.statusCode == 200) {
      UserModel userModel = UserModel.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<bool?> check_email(Map map) async {
  print("#verify user");
  print(map);
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/login/check-email';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},

          body: json.encode(map),
        )
        .timeout(Duration(seconds: 6));

    print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body)['valid'] == true;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<UserModel?> verifyUserOtp(Map map, String token) async {
  if (kDebugMode) {
    print("#verify user");
  }
  if (kDebugMode) {
    print(map);
  }
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/login/verify-otp';
  final client = http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },

          body: json.encode(map),
        )
        .timeout(Duration(seconds: 6));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      UserModel userModel = UserModel.fromJson(json.decode(response.body));
      TokenService.setToken(userModel.token ?? '');
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e.stackTrace);
    }
    return null;
  }
}

Future<VerifyOtpModel?> resendUserOtp(Map map, String token) async {
  print("#verify user");
  print(map);
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/login/resend-otp';
  final client = http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 6));

    print(response.body);
    if (response.statusCode == 200) {
      VerifyOtpModel userModel = VerifyOtpModel.fromJson(
        json.decode(response.body),
      );
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<UserModel?> forgotPassword(Map map) async {
  print("#forgotPassword user");
  print(map);
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/forgot-passowrd';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 6));

    print(response.body);
    if (response.statusCode == 200) {
      UserModel userModel = UserModel.fromJson(json.decode(response.body));
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<LoginResponseModel?> update_setting(Map map) async {
  print("#update_setting user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/update_setting';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 6));

    print(response.body);
    if (response.statusCode == 201) {
      UserModel userModel = UserModel.fromJson(
        json.decode(response.body)['data'],
      );
      return LoginResponseModel(userModel: userModel);
    } else {
      return LoginResponseModel(
        userModel: null,
        message: "Failed to update setting",
      );
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return LoginResponseModel(message: "Network timout error", userModel: null);
  } on SocketException catch (e) {
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return LoginResponseModel(
      message: "Something went wrong.Try again",
      userModel: null,
    );
  }
}

Future<int?> logoutuser() async {
  print("#logout user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/logout';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode({"user_id": currentuser.value.user?.id}),
        )
        .timeout(Duration(seconds: 5));

    print(response.body);
    if (response.statusCode == 201) {
      return 1;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    return null;
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return null;
    print(' Socket Error: $e');
  } on Error catch (e) {
    return null;
    print(' General Error: $e');
  }
}

Future<String?> change_account_password(Map map) async {
  print("#change account password");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/account_password';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 6));

    print(response.body);
    if (response.statusCode == 201) {
      return 'success';
    }
    if (response.statusCode == 202) {
      return 'New password should be different from old password';
    }
    if (response.statusCode == 401) {
      return 'Old password is wrong';
    } else {
      return 'Something went wrong.Try again';
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
  }
}

Future<LoginResponseModel?> confirmOtpCode(
  Map map,
  bool change_password,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/confirmotp';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 5));

    print(response.body);
    if (response.statusCode == 201) {
      if (change_password) {
      } else {
        await prefs.setString('user_details', response.body);
      }
      UserModel userModel = UserModel.fromJson(
        json.decode(response.body)['data'],
      );
      return LoginResponseModel(userModel: userModel, message: null);
    }

    if (response.statusCode == 401) {
      return LoginResponseModel(
        message: "Wrong OTP Code.try again",
        userModel: null,
      );
    } else {
      return LoginResponseModel(
        message: "Something went wrong",
        userModel: null,
      );
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return LoginResponseModel(message: "Network timout error", userModel: null);
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return LoginResponseModel(message: "Something went wrong", userModel: null);
  }
}

Future<ExtractIdModel?> extractIDDetails(Map map) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("#extract user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/customer/extract';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(const Duration(seconds: 20));

    print(response.body);
    if (response.statusCode == 200) {
      if (response.body.toLowerCase().contains("i can't assist with that") ||
          response.body.isEmpty) {
        print("empty value");
        return null;
      }

      try {
        ExtractIdModel userModel = ExtractIdModel.fromJson(
          json.decode(response.body),
        );
        return userModel;
      } catch (e) {
        print("error $e");
        return null;
      }
    } else if (response.statusCode == 401) {
      return null;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;

    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return null;
    print(' Socket Error: $e');
  } on Error catch (e) {
    return null;
  }
}

Future<LoginResponseModel?> LoginappUser(Map map) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("#login user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/login';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(const Duration(seconds: 60));
    print(response.body);
    if (response.statusCode == 200) {
      UserModel userModel = UserModel.fromJson(json.decode(response.body));
      await prefs.setString('user_details', response.body);
      return LoginResponseModel(userModel: userModel);
    } else if (response.statusCode == 401) {
      return LoginResponseModel(
        message: "Incorrect username or password, please contact support",
        userModel: null,
      );
    } else {
      return LoginResponseModel(
        message: "Something went wrong .Try again",
        userModel: null,
      );
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
    print(' Socket Error: $e');
  } on Error catch (e) {
    return LoginResponseModel(
      message: "Something went wrong .Try again",
      userModel: null,
    );
  }
}

Future<LoginResponseModel?> BioLoginuser(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}biometriclogin';
  final client = http.Client();
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'x-access-token': token,
      },
    );
    print(response.body);
    if (response.statusCode == 201) {
      await prefs.setString('user_details', response.body);

      UserModel userModel = UserModel.fromJson(
        json.decode(response.body)['data'],
      );
      return LoginResponseModel(userModel: userModel);
    } else {
      return LoginResponseModel(
        message: "Token expired.Please use password",
        userModel: null,
      );
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return null;
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
    print(' General Error: $e');
  }
}

Future<int?> SendOtp(Map body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/resendotp';
  final client = new http.Client();
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'x-access-token': '',
      },
      body: json.encode(body),
    );
    print(response.body);
    if (response.statusCode == 201) {
      return 1;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return null;
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
    print(' General Error: $e');
  }
}

Future<LoginResponseModel?> RefreshUser(Map condition) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/refresh';
  final client = new http.Client();
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(condition),
    );
    print(response.body);
    if (response.statusCode == 201) {
      await prefs.setString('user_details', response.body);
      UserModel userModel = UserModel.fromJson(
        json.decode(response.body)['data'],
      );
      currentuser.value = userModel;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      currentuser.notifyListeners();
      return new LoginResponseModel(userModel: userModel);
    } else {
      return new LoginResponseModel(userModel: null);
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return null;
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
    print(' General Error: $e');
  }
}

Future<LoginResponseModel?> checkaccount(Map map) async {
  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/checkaccount';

  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 5));

    print(response.body);
    if (response.statusCode == 201) {
      UserModel userModel = UserModel.fromJson(
        json.decode(response.body)['data'],
      );
      return LoginResponseModel(userModel: userModel);
    }

    if (response.statusCode == 401) {
      return LoginResponseModel(
        message: "Account does not exist",
        userModel: null,
      );
    } else {
      return LoginResponseModel(
        message: "Something went wrong",
        userModel: null,
      );
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return LoginResponseModel(message: "Something went wrong", userModel: null);
    ;
    print(' General Error: $e');
  }
}

Future<LoginResponseModel?> checkemailandphone(Map map) async {
  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/checkemailandphone';

  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 5));
    print(response.body);
    if (response.statusCode == 201) {
      return LoginResponseModel(message: null, userModel: null);
    }
    if (response.statusCode == 401) {
      final message = json.decode(response.body)['data'];
      return LoginResponseModel(message: message, userModel: null);
    } else {
      return LoginResponseModel(
        message: "Something went wrong",
        userModel: null,
      );
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return LoginResponseModel(message: "Something went wrong", userModel: null);
    ;
    print(' General Error: $e');
  }
}

Future<LoginResponseModel?> newpassword(Map map) async {
  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/changepassword';

  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 5));

    print(response.body);
    if (response.statusCode == 201) {
      UserModel userModel = UserModel.fromJson(
        json.decode(response.body)['data'],
      );
      return LoginResponseModel(userModel: userModel);
    } else {
      return LoginResponseModel(
        message: "Something went wrong",
        userModel: null,
      );
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return LoginResponseModel(
      message: "Check your network connection",
      userModel: null,
    );
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return LoginResponseModel(message: "Something went wrong", userModel: null);

    print(' General Error: $e');
  }
}

Future<int?> updatenotificationsettings(Map data) async {
  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/updatenotificationsetting';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(data),
        )
        .timeout(Duration(seconds: 5));

    print(response.body);
    if (response.statusCode == 201) {
      return 1;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return null;
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
    print(' General Error: $e');
  }
}

Future<List<CountryModel>> get_countries() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/countries';
  final client = http.Client();
  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => CountryModel.fromJson(e)).toList();
    }
    return [];
  } on TimeoutException {
    return [];
  } on SocketException {
    return [];
  } catch (e) {
    return [];
  }
}

Future<WaitingPeriodModel?> check_waiting_period() async {
  print("#check_waiting_period user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/waiting-period-setting';
  final client = new http.Client();
  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-access-token': '',
          },
        )
        .timeout(Duration(seconds: 260));
    ;
    print(response.body);
    if (response.statusCode == 200) {
      WaitingPeriodModel userModel = WaitingPeriodModel.fromJson(
        json.decode(response.body),
      );
      return userModel;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return null;
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
    print(' General Error: $e');
  }
}

Future<LoginResponseModel?> register(Map body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  print("#confirm user");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/register';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-access-token': '',
          },
          body: json.encode(body),
        )
        .timeout(Duration(seconds: 260));
    ;
    print(response.body);
    if (response.statusCode == 201) {
      UserModel userModel = UserModel.fromJson(
        json.decode(response.body)['data'],
      );
      return LoginResponseModel(userModel: userModel);
    } else if (response.statusCode == 401) {
      final message = json.decode(response.body)['message'];
      return LoginResponseModel(message: message);
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
    print(' Timeout Error: $e');
  } on SocketException catch (e) {
    return null;
    print(' Socket Error: $e');
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return null;
    print(' General Error: $e');
  }
}

Future<UserModel?> renewToken(String token) async {
  final response = await client.post(
    Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/auth/renew-token',
    ),
    headers: {
      // Send the old token for verification/renewal
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final UserModel? user = UserModel.fromJson(jsonResponse);

    if (user != null) {
      TokenService.setToken(user.token ?? '');

      currentuser.value = user; // Update the stored token
      return user;
    }
  }

  // Handle renewal failure (e.g., redirect to login)
  // TokenStorage.token = null;
  if (kDebugMode) {
    print('Failed to renew token. User must re-login.');
  }
  return null;
}
