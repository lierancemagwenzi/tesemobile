import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../models/Setting.dart';

ValueNotifier<Setting> setting = ValueNotifier(Setting());

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

final navigatorKey = GlobalKey<NavigatorState>();

Future<Setting> initSettings() async {
  Setting _setting;
  try {
    Future.delayed(Duration(seconds: 1)).then((value) {
      _setting = Setting();
      _setting.appName = 'FullTank';
      setting.value = _setting;
    });
  } catch (e) {
    return Setting.fromJSON({});
  }
  return setting.value;
}

void setBrightness(Brightness brightness) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (brightness == Brightness.dark) {
    prefs.setBool("isDark", true);
    brightness = Brightness.dark;
  } else {
    prefs.setBool("isDark", false);
    brightness = Brightness.light;
  }
}
