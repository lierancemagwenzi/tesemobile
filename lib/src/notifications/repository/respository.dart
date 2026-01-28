import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:http/http.dart' as http;
import 'package:smacredit/src/auth/repository/inteceptor.dart';
import 'package:smacredit/src/helpers/Helper.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

final http.Client client = RetryClient(
  http.Client(),
  // Or wherever your renewal endpoint is
);
Future<Stream<NotificationModel>> getnotifications() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/notifications';
  if (kDebugMode) {
    print(url);
  }
  http.Request request = http.Request('get', Uri.parse(url));

  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';

  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
        NotificationModel notificationModel = NotificationModel.fromJson(data);
        return notificationModel;
      });
}

Future<int?> deletenotification(var body) async {
  if (kDebugMode) {
    print("#adding new meeting");
  }
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/notification/delete';
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${currentuser.value.token}',
      },
      body: json.encode(body),
    );
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return 1;
    } else {
      return null;
    }
  } on TimeoutException {
    return null;
  } on SocketException {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print(' General Error: $e');
    }

    return null;
  }
}

Future<bool?> markasread(Map condition) async {
  if (kDebugMode) {
    print("#adding new meeting");
  }
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/notification/read';
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${currentuser.value.token}',
      },
      body: json.encode(condition),
    );
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  } on TimeoutException {
    return null;
  } on SocketException {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print(' General Error: $e');
    }

    return null;
  }
}
