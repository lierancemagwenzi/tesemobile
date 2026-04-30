import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'string_extension.dart';


class Helper {
  BuildContext? context;
DateTime? currentBackPressTime;

  Helper.of(BuildContext _context) {
    this.context = _context;
  }

  // for mapping data retrieved form json array
  static getData(data) {
    return data ?? [];
  }

    static getNestedData(data) {
    return data['data'] ?? [];
  }
  static String limitString(String text, {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) + (text.length > limit ? hiddenText : '');
  }

  static getMeterData(Map<String, dynamic> data) {
    return data['meters'] ?? [];
  }

  static String getfilextention(String path){
    return path.split(".").last;

  }


static  String getFiledName(String myString){

    return myString.replaceFirst(RegExp('_'), ' ');
  }


  static String skipHtml(String htmlString) {
    try {
      var document = parse(htmlString);
      String parsedString = parse(document.body!.text).documentElement!.text;
      return parsedString;
    } catch (e) {
      return '';
    }
  }

}
