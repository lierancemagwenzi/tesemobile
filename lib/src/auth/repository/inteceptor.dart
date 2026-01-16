import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:smacredit/src/auth/controller/shared_preferences_helper.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

class RetryClient extends http.BaseClient {
  final http.Client _inner;
  final String renewUrl =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/renew-token';

  RetryClient(this._inner);

  // Helper method to safely renew and update the token
  Future<UserModel?> _renewToken(String token) async {
    final response = await _inner.post(
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

  // Helper method to clone a request (handles both Request and MultipartRequest)
  http.BaseRequest _cloneRequest(http.BaseRequest original, String newToken) {
    // 1. Update the Authorization header in the new request's headers
    final Map<String, String> newHeaders = Map.from(original.headers);
    newHeaders['Authorization'] = 'Bearer $newToken';

    // 2. Handle cloning based on type
    if (original is http.MultipartRequest) {
      // For MultipartRequest, we must create a brand new instance
      final http.MultipartRequest newRequest = http.MultipartRequest(
        original.method,
        original.url,
      );

      // Copy fields and files
      newRequest.fields.addAll(original.fields);
      newRequest.files.addAll(
        original.files,
      ); // Files are StreamedBody objects, safe to reuse
      newRequest.headers.addAll(newHeaders);

      return newRequest;
    } else if (original is http.Request) {
      // For standard Request, we use the original logic
      final http.Request newRequest = http.Request(
        original.method,
        original.url,
      );
      newRequest.bodyBytes = original.bodyBytes;
      newRequest.headers.addAll(newHeaders);
      return newRequest;
    }

    // Fallback for other request types (unlikely but safe)
    final http.Request newRequest = http.Request(original.method, original.url);
    newRequest.headers.addAll(newHeaders);
    return newRequest;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Send the original request
    var response = await _inner.send(request);

    // 2. Check for 403/401 error
    if (response.statusCode == 403 || response.statusCode == 401) {
      print('Token expired. Attempting to renew...');

      // Consume the body of the failed response before renewal
      await response.stream.bytesToString();

      // 3. Try to renew the token
      final UserModel? renewalSuccess = await _renewToken(
        currentuser.value.token ?? '',
      );

      if (renewalSuccess != null) {
        print('Renewal successful. Retrying original request...');

        // 4. Clone the request with the new token
        final http.BaseRequest retriedRequest = _cloneRequest(
          request,
          currentuser.value.token!,
        );

        // 5. Send the retried request
        return _inner.send(retriedRequest);
      }
    }

    // Return the original response (or unhandled error response)
    // Convert StreamedResponse back to a standard response structure for return
    return http.StreamedResponse(
      response.contentLength == null ? Stream.empty() : response.stream,
      response.statusCode,
      headers: response.headers,
      request: response.request,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
