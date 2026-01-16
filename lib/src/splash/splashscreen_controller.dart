// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/repositories/settings_repository.dart' as settingRepo;
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/user_repository.dart';


class   SplashSceenController extends ControllerMVC {
 late  GlobalKey<ScaffoldState> scaffoldKey;

  ValueNotifier<Map<String, double>> progress = ValueNotifier(new Map());
bool loading=false;
  SplashSceenController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    progress.value = {"Setting": 0, "User": 0};

  }






  load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null && settingRepo.setting.value.appName != '') {
        progress.value["Setting"] = 41;
        // ignore: invalid_use_of_protected_member
        progress?.notifyListeners();
      }
    });
    bool logged_in=prefs.getBool('logged_in')??false;
    if(!logged_in){
      progress.value["User"] = 59;
    }
    else{
      currentuser.addListener(() {
        if (currentuser.value.user?.id != null ){
          progress.value["User"] = 59;
          // ignore: invalid_use_of_protected_member
          progress.notifyListeners();
        }
      });
    }

  }
  @override
  void initState() {
    load();
    Timer(const Duration(seconds: 15), () {
print("15 seconds passed");
setState(() {
  progress.value["User"] = 59;
});

    });
    super.initState();
  }

}
