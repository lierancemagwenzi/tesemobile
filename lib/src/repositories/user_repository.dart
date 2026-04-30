import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smacredit/client/models/cookie_manager.dart';
import 'package:smacredit/src/auth/repository/inteceptor.dart';
import 'package:smacredit/src/auth/widgets/models/id_details.dart';

import '../models/UserModel.dart';

final http.Client client = RetryClient(
  http.Client(),
  // Or wherever your renewal endpoint is
);
ValueNotifier<UserModel> currentuser = ValueNotifier(UserModel());

ValueNotifier<String> current_registration_email = ValueNotifier('');
final cloudFrontCookieNotifier = CloudFrontCookieNotifier();

bool isV1=false;

ValueNotifier<IdDetails?> id_details = ValueNotifier(null);
bool initialized = false;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

Future<void> RegisterToken({required String token}) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/register_token';

  try {
    final r = RetryOptions(maxAttempts: 8);
    final response = await r.retry(
      // Make a GET request
      () => http
          .post(
            Uri.parse(url),
            body: jsonEncode({
              "token": token,
              "user_id": currentuser.value.user?.id,
            }),
            headers: {
              'Content-type': 'application/json',
              HttpHeaders.authorizationHeader:
                  'Bearer ${currentuser.value.token}',
            },
          )
          .timeout(Duration(seconds: 5)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    if (kDebugMode) {
      print("register_token ${response.body}");
    }
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 201) {
    } else {}
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(' Timeout Error: $e');
    }
  } on SocketException catch (e) {
    if (kDebugMode) {
      print(' Socket Error: $e');
    }
  } on Error catch (e) {
    if (kDebugMode) {
      print(' General Error: $e');
    }
  }
}

ValueNotifier<int> total_client_notifications = new ValueNotifier(0);
ValueNotifier<int> total_admin_notifications = new ValueNotifier(0);

showNotification(String body, String title, payload) async {
  const AndroidNotificationDetails androidNotificationDetails =
  AndroidNotificationDetails('your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin?.show(
      0, title,body, notificationDetails,
      payload: payload);
}

Future<dynamic>? myCallBackgroundMessageHandler(Map<String, dynamic> message) {
  if (kDebugMode) {
    print("backlee: $message");
  }
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }
}
