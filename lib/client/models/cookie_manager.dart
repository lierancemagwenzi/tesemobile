import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:smacredit/client/models/cookie_model.dart';
import 'package:smacredit/client/respository/client_repositoy.dart';

class CloudFrontCookieNotifier extends ValueNotifier<String> {
  CloudFrontCookieNotifier() : super('');

  /// Update the cookie value
  void update(String newCookie) {
    value = newCookie;
  }

  /// Clear the cookie (e.g., on logout or expiration)
  void clear() {
    value = '';
  }

  Timer? _refreshTimer;

  static const _channel = MethodChannel('com.tese/cookies');

  void setCookie(CloudFrontCookies cookie) {
    value = cookie.cookieHeader;
    _scheduleRefresh(cookie);
    if (Platform.isIOS) {
      _channel.invokeMethod('setCloudFrontCookies', {
        'keyPairId': cookie.keyPairId,
        'signature': cookie.signature,
        'policy': cookie.policy,
        'domain': 'media.tese.africa',
      });
    }
  }

  void _scheduleRefresh(CloudFrontCookies cookie) {
    _refreshTimer?.cancel();

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final refreshIn = cookie.expiresAt - now;
    print(refreshIn);

    if (refreshIn > 0) {
      if (refreshIn < 300) {
        _refreshTimer = Timer(Duration(seconds: refreshIn), () {
          refreshCookie();
        });
      }
    } else {
      _refreshTimer = Timer(Duration(seconds: refreshIn), () {
        refreshCookie();
      });
    }
  }

  Future<void> refreshCookie() async {
    final newCookie = await fetchSignedCookies();
    setCookie(newCookie);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
