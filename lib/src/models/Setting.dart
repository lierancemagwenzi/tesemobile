import 'dart:ui';

import 'package:flutter/foundation.dart';

class Setting{

  String appName = '';
  num? defaultTax;
  String ?defaultCurrency;
  String? distanceUnit;
  bool currencyRight = false;
  int currencyDecimalDigits = 2;
  int? meeting_time;
  String? mainColor;
  String? mainDarkColor;
  String? secondColor;
  String? secondDarkColor;
  String? accentColor;
  String? accentDarkColor;
  String? scaffoldDarkColor;
  String? scaffoldColor;
  String? googleMapsKey;
  String? chat_url;
  num? delivery_fee;
  String? fcmKey;
  ValueNotifier<Locale> mobileLanguage = new ValueNotifier(Locale('en', ''));
  String? appVersion;
  bool enableVersion = true;
  String? helpline;
  String? enable_images;
  String? paystack_url;
  String? payfast_url;
  String? invoice_url;
String?privacy_link;
  String? email;
  String? service_payment_url;
  String? wallet_topup_url;
  ValueNotifier<Brightness> brightness = new ValueNotifier(Brightness.light);

   Setting();

  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      appName = jsonMap['app_name'] ?? null;
      chat_url = jsonMap['chat_url'] ?? null;
      mainColor = jsonMap['main_color'] ?? null;
      mainDarkColor = jsonMap['main_dark_color'] ?? '';
      secondColor = jsonMap['second_color'] ?? '';
      secondDarkColor = jsonMap['second_dark_color'] ?? '';
      accentColor = jsonMap['accent_color'] ?? '';
      accentDarkColor = jsonMap['accent_dark_color'] ?? '';
      scaffoldDarkColor = jsonMap['scaffold_dark_color'] ?? '';
      scaffoldColor = jsonMap['scaffold_color'] ?? '';
      paystack_url = jsonMap['paystack_url'] ?? '';
      payfast_url = jsonMap['payfast_url'] ?? '';
      invoice_url = jsonMap['invoice_url'] ?? '';
      privacy_link = jsonMap['privacy_link'] ?? '';
      service_payment_url = jsonMap['service_payment_url'] ?? '';
      wallet_topup_url = jsonMap['wallet_topup_url'] ?? '';

      googleMapsKey = jsonMap['google_maps_key'] ?? null;
      fcmKey = jsonMap['fcm_key'] ?? null;
      mobileLanguage.value = Locale(jsonMap['mobile_language'] ?? "en", '');
      appVersion = jsonMap['app_version'] ?? '';
      distanceUnit = jsonMap['distance_unit'] ?? 'km';
      enableVersion = jsonMap['enable_version'] == null || jsonMap['enable_version'] == '0' ? false : true;
      defaultCurrency = jsonMap['default_currency'] ?? '';
      currencyDecimalDigits = int.tryParse(jsonMap['default_currency_decimal_digits'] ?? '2') ?? 2;
      currencyRight = jsonMap['currency_right'] == null || jsonMap['currency_right'] == '0' ? false : true;
      defaultTax = num.tryParse(jsonMap['defaultTax']) ?? 0;
      delivery_fee = num.tryParse(jsonMap['delivery_fee']) ?? 0;

      helpline = jsonMap['helpline'] ?? '';
      email = jsonMap['email'] ?? '';

    } catch (e) {
      print(e.toString());
      // print(CustomTrace(StackTrace.current, message: e.toString()).toString());
    }
  }

}