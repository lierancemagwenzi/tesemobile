import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' as s;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smacredit/src/splash/splashscreen_controller.dart';

import '../helpers/constants.dart';
import '../models/constants.dart';
import '../repositories/user_repository.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends StateMVC<SplashScreen> {
  late SplashSceenController _con;

  _SplashScreenState() : super(SplashSceenController()) {
    _con = controller as SplashSceenController;
  }

  Future<void> loadData() async {
    // SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool installed = prefs.getBool('installed') ?? false;
    if (kDebugMode) {
      print("installed is $installed");
    }

    final user = await _con.getUser();

    if (user != null) {
      await Future.delayed(Duration(seconds: 3));
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/Dashboard');
    }

    // _con.progress.addListener(()  {
    //   double progress = 0;
    //   print("progress is $progress");
    //   _con.progress.value.values.forEach((_progress) {
    //     progress += _progress;

    //   });
    //   if (progress == 100) {
    //     if(!installed){
    //       Navigator.of(context).pushReplacementNamed('/First');
    //     }
    //     else {
    //       Future.delayed(const Duration(seconds: 5), () async {
    //         if (currentuser.value?.user?.id != null) {
    //           Navigator.of(context).pushReplacementNamed('/dashboard');
    //         }
    //         else {
    //           Navigator.of(context).pushReplacementNamed('/First');
    //         }
    //       });
    //     }

    //   }
    // });

    await Future.delayed(Duration(seconds: 3));
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('/First');
  }

  @override
  void initState() {
    super.initState();
    s.SchedulerBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/logo/logoo.png"),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        backgroundColor: Constants.primaryColor,
        key: _con.scaffoldKey,
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage("assets/images/logo.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Constants.primaryColor,
                  size: 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
