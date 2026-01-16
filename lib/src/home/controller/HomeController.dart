import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http_parser/http_parser.dart';
import 'package:smacredit/src/auth/models/ExtractIDModel.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/auth/models/VerifyOTPModel.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:smacredit/src/employment/repository/employer_repository.dart';
import 'package:smacredit/src/expenses/models/ExpenseModel.dart';
import 'package:smacredit/src/expenses/repository/expense_repository.dart';
import 'package:smacredit/src/home/models/DashboardModel.dart';
import 'package:smacredit/src/home/models/ProfileModel.dart';
import 'package:smacredit/src/home/models/earnings_stats_model.dart';
import 'package:smacredit/src/home/models/user_stats.dart';
import 'package:smacredit/src/home/repository/dashboard_repository.dart';
import 'package:smacredit/src/notifications/widgets/notifications.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/repositories/user_repository.dart' as userRepo;
import '../../helpers/Message.dart';

class HomeController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool loading = false;
  String? selectedCurrency;
  AmountStatsModel? data;
  UserStatsModel? dashboardModel;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  HomeController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  local() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );
    await flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      var map = jsonDecode(payload!);
      if (map['action'] == 'access_request') {
        // userRepo.accessRequestNotificationModel.value =
        //     AccessRequestNotificationModel(
        //       message: map['body'],
        //       action: map['action'],
        //       action_id: map['action_id'],
        //       timeCreated: DateTime.now(),
        //     );
        // // ignore: invalid_use_of_protected_member
        // userRepo.accessRequestNotificationModel.notifyListeners();
      }
      debugPrint('notification payload: $payload');
    }

    Navigator.pushNamed(scaffoldKey.currentContext!, '/Home');
    // await Navigator.push(
    //   scaffoldKey.currentContext!,
    //   MaterialPageRoute<void>(builder: (context) => NotificationScreen(payload: payload,)),
    // );
  }

  showLocalNotification(String title, String body, String payload) {
    Future.delayed(Duration(seconds: 1)).then((value) async {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'your channel id',
            'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );
      await flutterLocalNotificationsPlugin?.show(
        0,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    });
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ""),
        content: Text(body ?? ""),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> init(BuildContext context) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final perm = await FirebaseMessaging.instance.requestPermission();
    print("Permission: ${perm.authorizationStatus}");

    // final apns = await FirebaseMessaging.instance.getAPNSToken();
    // print("APNs: $apns");

    // FirebaseMessaging.instance.onTokenRefresh
    //     .listen((fcmToken) {
    //       print('token_refresh');
    //       // TODO: If necessary send token to application server.

    //       // Note: This callback is fired at each app startup and whenever a new
    //       // token is generated.
    //     })
    //     .onError((err) {
    //       // Error getting token.
    //     });

    // final fcm = await FirebaseMessaging.instance.getToken();
    // print("FCM: $fcm");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      if (Platform.isAndroid) {
        Map map = {
          "title": message.notification?.title ?? "",
          "body": message.notification?.body ?? "",
          "action_id": message.data['action_id'] ?? "",
          "action": message.data['action'] ?? "",
        };
        print(map['action_id']);
        print(map['action']);

        showLocalNotification(
          message.notification?.title ?? "",
          message.notification?.body ?? "",
          jsonEncode(map),
        );

        // context.showFlash<bool>(
        //   barrierDismissible: true,
        //   duration: const Duration(seconds: 3),
        //   builder: (context, controller) => FlashBar(
        //     controller: controller,
        //     forwardAnimationCurve: Curves.easeInCirc,
        //     reverseAnimationCurve: Curves.bounceIn,
        //     position: FlashPosition.top,
        //     indicatorColor: Colors.red,
        //     icon: Icon(Icons.tips_and_updates_outlined),
        //     title: Text(message.notification?.title??"",style: TextStyle(color: Colors.black),),
        //     content: Text(message.notification?.body??"",style: TextStyle(color: Colors.black)),
        //     actions: [
        //       // TextButton(onPressed: controller.dismiss, child: Text('Cancel')),
        //       TextButton(onPressed: () => controller.dismiss(true), child: Text('Ok'))
        //     ],
        //   ),
        // );
      } else {
        context.showFlash<bool>(
          barrierDismissible: true,
          duration: const Duration(seconds: 3),
          builder: (context, controller) => FlashBar(
            controller: controller,
            forwardAnimationCurve: Curves.easeInCirc,
            reverseAnimationCurve: Curves.bounceIn,
            position: FlashPosition.top,
            indicatorColor: Colors.red,
            icon: const Icon(Icons.tips_and_updates_outlined),
            title: Text(
              message.notification?.title ?? "",
              style: TextStyle(color: Colors.black),
            ),
            content: Text(
              message.notification?.body ?? "",
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              TextButton(
                onPressed: () => controller.dismiss(true),
                child: Text('Ok'),
              ),
            ],
          ),
        );
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // handle accordingly
        if (Platform.isAndroid) {
          Map map = {
            "title": message.notification?.title ?? "",
            "body": message.notification?.body ?? "",
            "action_id": message.data['action_id'] ?? "",
            "action": message.data['action'] ?? "",
          };
        } else {}
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (Platform.isAndroid) {
        Map map = {
          "title": message.notification?.title ?? "",
          "body": message.notification?.body ?? "",
          "action_id": message.data['action_id'] ?? "",
          "action": message.data['action'] ?? "",
        };
      } else {}

      // context.showFl; // add logic here
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      print("FCM Token: $token");
      userRepo.RegisterToken(token: token);
    });
    // final fcm = await FirebaseMessaging.instance.getToken();
    // print("isFCM: $fcm");
    if (!userRepo.initialized) {
      if (Platform.isIOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (kDebugMode) {
          print("token_is $apnsToken");
        }
        if (apnsToken != null) {
          if (currentuser.value.user?.id != null) {
            userRepo.RegisterToken(token: apnsToken);
            userRepo.initialized = true;
          }
          await _firebaseMessaging.subscribeToTopic('generalnotifications');
        } else {
          await Future<void>.delayed(const Duration(seconds: 10));
          apnsToken = await _firebaseMessaging.getAPNSToken();
          if (kDebugMode) {
            print(" getAPNSToken token_is $apnsToken");
          }

          if (apnsToken != null) {
            // await _firebaseMessaging.subscribeToTopic('generalnotifications');
            if (currentuser.value.user?.id != null) {
              // userRepo.RegisterToken(token: apnsToken);
              userRepo.initialized = true;
            }
          }
        }
      }

      await Future<void>.delayed(const Duration(seconds: 10));

      // else {
      String? token = await _firebaseMessaging.getToken();
      if (currentuser.value.user?.id != null) {
        userRepo.RegisterToken(token: token!);
      }
      _firebaseMessaging.subscribeToTopic("generalnotifications");
      if (kDebugMode) {
        print("FirebaseMessaging token: $token");
      }
      userRepo.initialized = true;
      // }

      // final fcm = await FirebaseMessaging.instance.getToken();
      // if (kDebugMode) {
      //   print("FCM: $fcm");
      // }
    }
  }

  Future<void> listenForDashboardInfo() async {
    setState(() {
      loading = true;
    });
    final Stream<UserStatsModel?> stream = await get_dashboard_info();

    stream.listen(
      (UserStatsModel? employerModel) {
        setState(() {
          dashboardModel = employerModel;
        });
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        print(a);
      },
      onDone: () {
        setState(() {
          loading = false;
          data = dashboardModel?.amountStats?.first;
        });
      },
    );
  }
}
