import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:smacredit/client/downloads/service.dart';
import 'package:smacredit/src/Route_generator.dart';
import 'package:smacredit/src/models/Setting.dart';

import 'package:smacredit/src/repositories/settings_repository.dart'
    as settingRepo;
import 'package:smacredit/src/helpers/app_config.dart' as config;

import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smacredit/src/repositories/settings_repository.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/theme/app_theme.dart';
import 'package:smacredit/src/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await FlutterDownloader.initialize(
    debug: true, // set to false in production
    ignoreSsl: true, // option to ignore SSL (use with caution)
  );

  DownloadService.init();
  // Load saved theme
  ThemeMode savedMode = await ThemeService().loadThemeMode();
  themeNotifier.value = savedMode;
  await GlobalConfiguration().loadFromAsset("app_settings");
  await Firebase.initializeApp(
    options: Platform.isAndroid
        ? FirebaseOptions(
            apiKey: 'AIzaSyDF9waYRPPIoXPClg4ixNfOUag8aylBWLY',
            appId: '1:969071079065:android:1b3c17a3bf7f1503bb1208',
            messagingSenderId: '663952460068',
            projectId: 'tese-eba00',
          )
        : FirebaseOptions(
            apiKey: 'AIzaSyBROAsynXBIQd71vbnKnIa5aMxP1i-dfis',
            appId: '1:663952460068:ios:6d56a137a520e9311a4bb1',
            messagingSenderId: '663952460068',
            projectId: 'tese-eba00',
            iosBundleId: 'com.smatechgoup.tese',
          ),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  settingRepo.initSettings();
  LoadUser();
  init();
  initializeDateFormatting().then((_) => runApp( TeseApp()));
}

void LoadUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? user = prefs.getString('user_details');

  if (user != null) {
    // UserModel userModel=UserModel.fromJson(jsonDecode(user)['data']);
    // RefreshUser({"id":userModel.user?.id});
  }
}

init() {
  FlutterLocalNotificationsPlugin flp = FlutterLocalNotificationsPlugin();
  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  // final DarwinInitializationSettings initializationSettingsDarwin =
  // DarwinInitializationSettings(
  //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initSetttings = InitializationSettings(android: android);
  flp.initialize(initSetttings);
}

void onDidReceiveLocalNotification(
  int? id,
  String? title,
  String? body,
  String? payload,
) async {
  showNotification(body!, title!, payload);
  // display a dialog with the notification details, tap ok to go to another page
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print("Handling a background message: ${message.messageId}");
}


class TeseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode, // This controls the switch
           navigatorKey: settingRepo.navigatorKey,
          title: 'Tese',
          initialRoute: '/Splash',
          //       initialRoute: '/Intro',
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,

          localizationsDelegates: const [FormBuilderLocalizations.delegate],
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'First Method',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: child,
        );
      },
      child: ValueListenableBuilder(
        valueListenable: settingRepo.setting,
        builder: (context, Setting _setting, _) {
          return MaterialApp(
            navigatorKey: settingRepo.navigatorKey,
            title: _setting.appName,
            initialRoute: '/Splash',
            //       initialRoute: '/Intro',
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
            locale: _setting.mobileLanguage.value,

            localizationsDelegates: const [FormBuilderLocalizations.delegate],
            theme: _setting.brightness.value == Brightness.light
                ? ThemeData(
                    fontFamily: 'Figtree',
                    useMaterial3: false,
                    primaryColor: config.Colors().mainColor(1),
                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                      elevation: 0,
                      foregroundColor: Colors.white,
                    ),
                    brightness: Brightness.light,
                    primaryColorLight: config.Colors().accentColor(1),
                    dividerColor: config.Colors().accentColor(0.1),
                    focusColor: config.Colors().accentColor(1),
                    hintColor: config.Colors().secondColor(1),

                    // appBarTheme: AppBarTheme(centerTitle: true,   color:config.Colors().mainColor(1),elevation: 0.0, toolbarTextStyle: TextTheme(headline5: TextStyle(fontSize: 18.0, color:Colors.white,fontWeight: FontWeight.bold, height: 1.3)).bodyText2, titleTextStyle: TextTheme(headline5: TextStyle(fontSize: 18.0, color:Colors.white,fontWeight: FontWeight.bold, height: 1.3)).headline6  ),
                    buttonTheme: ButtonThemeData(
                      buttonColor: config.Colors().accentColor(
                        1,
                      ), //  <-- dark color
                      //  <-- this auto selects the right color
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      // 1. Sets the color of the label when the field is UNfocused (inactive)
                      labelStyle: const TextStyle(
                        color: Colors.green, // Your default unfocused color
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                      ),

                      // 2. FOCUSED BORDER (The target property)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Colors
                              .green, // <-- Set the focused border color to GREEN
                          width: 2.0, // Make it thicker to highlight focus
                        ),
                      ),

                      // 3. ERROR BORDER (Optional)
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.0,
                        ),
                      ),
                      // 2. Sets the color of the label when the field IS focused (floating)
                      floatingLabelStyle: const TextStyle(
                        color: Colors.green, // Your primary focused color
                        fontWeight: FontWeight.bold,
                      ),

                      // Optional: Sets the color of the label when the field is in an error state
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    textTheme: TextTheme(
                      // headline5: TextStyle(fontSize: 22.0, color: config.Colors().accentColor(1), height: 1.3),
                      // headline4: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: config.Colors().accentColor(1), height: 1.3),
                      // headline3: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: config.Colors().secondColor(1), height: 1.3),
                      // headline2: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: config.Colors().mainColor(1), height: 1.4),
                      // headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w300, color: config.Colors().secondColor(1), height: 1.4),
                      // subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: config.Colors().secondColor(1), height: 1.3),
                      // headline6: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: config.Colors().mainColor(1), height: 1.3),
                      // bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: config.Colors().secondColor(1), height: 1.2),
                      // bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: config.Colors().secondColor(1), height: 1.3),
                      // caption: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: config.Colors().accentColor(1), height: 1.2),
                    ),
                  )
                : ThemeData(
                    fontFamily: 'sans',
                    primaryColor: Color(0xFF252525),
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Color(0xFF2C2C2C),
                    dividerColor: config.Colors().accentColor(0.1),
                    hintColor: config.Colors().secondDarkColor(1),
                    focusColor: config.Colors().accentDarkColor(1),
                    textTheme: TextTheme(
                      // headline5: TextStyle(fontSize: 22.0, color: config.Colors().secondDarkColor(1), height: 1.3),
                      // headline4: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: config.Colors().secondDarkColor(1), height: 1.3),
                      // headline3: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: config.Colors().secondDarkColor(1), height: 1.3),
                      // headline2: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: config.Colors().mainDarkColor(1), height: 1.4),
                      // headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w300, color: config.Colors().secondDarkColor(1), height: 1.4),
                      // subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: config.Colors().secondDarkColor(1), height: 1.3),
                      // headline6: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: config.Colors().mainDarkColor(1), height: 1.3),
                      // bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: config.Colors().secondDarkColor(1), height: 1.2),
                      // bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: config.Colors().secondDarkColor(1), height: 1.3),
                      // caption: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: config.Colors().secondDarkColor(0.6), height: 1.2),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
