import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:padimanartisan/auth/splash-screens.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'auth/login.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'helpers/components.dart';
import 'helpers/session.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  await Firebase.initializeApp(
    name: 'Padiman',
      options: const FirebaseOptions(
          apiKey: "AIzaSyBuWY8crqJaTHsL7XsRX_aWV5pcTZ1lUho",
          appId: "1:1014976582420:android:348d0dc79b26987e5fe801",
          messagingSenderId: "1014976582420",
          projectId: "padimanartisan"));

  // FirebaseMessaging.onBackgroundMessage(_messageHandler);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel123443', // id
      'High Importance Notifications', // title
      // 'This channel is used for important notifications.', // description
      importance: Importance.high,
      showBadge: true,
      playSound: false,
      // sound: AndroidNotificationSound
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  Map<int, Color> color = {
    50:Color.fromRGBO(7, 84, 40, .1),
    100:Color.fromRGBO(7, 84, 40, .2),
    200:Color.fromRGBO(7, 84, 40, .3),
    300:Color.fromRGBO(7, 84, 40, .4),
    400:Color.fromRGBO(7, 84, 40, .5),
    500:Color.fromRGBO(7, 84, 40, .6),
    600:Color.fromRGBO(7, 84, 40, .7),
    700:Color.fromRGBO(7, 84, 40, .8),
    800:Color.fromRGBO(7, 84, 40, .9),
    900:Color.fromRGBO(7, 84, 40, 1),
  };


  Future<void> save_devicetoken(String device_token) async {

    var client = http.Client();
    try {
      String user_id = '';
      var session = FlutterSession();
      user_id = await session.get('user_id') ;
      var url = Uri.parse(Component().API+'save-push-notification-token');
      var response = await http.post(url, body: {
        'user_id': user_id.toString(),
        'token': device_token,
      });
      print('===============================================');

      // print('Response status: ${response.statusCode}');
    } finally {
      client.close();
    }
  }

  Future initt()async{
    var session = FlutterSession();
    var value =  await session.getInt('id');
    if(value == null){
      user_id = 0;
    }else{
      user_id = await session.getInt('id');
    }
  }

  int user_id = 0;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Init.instance.initialize(),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        initt();
        // Loading is done, return the app:
        MaterialColor colorCustom = MaterialColor(0xFF1197b7, color);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Splash(), debugShowCheckedModeBanner: false,);
        } else {
          if(user_id == 0 || user_id.toString().isEmpty){
            // WELCOME USER
            return MaterialApp(
              title: '',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  primarySwatch: colorCustom,
                  bottomAppBarColor: colorCustom
              ),
              home: const SplashScreenPage(),
            );
          }else{
            // DASHBOARD
            return MaterialApp(
              title: '',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  primarySwatch: colorCustom,
                  bottomAppBarColor: colorCustom
              ),
              home: HomeScreen(),
            );
          }
        }
      },
    );
  }

  bool _isShowingWindow = false;
  bool _isUpdatedWindow = false;
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }

  late FirebaseMessaging _firebaseMessaging;
  late AndroidNotificationChannel channel;
  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    // _requestPermissions();
    // _firebaseMessaging = FirebaseMessaging.instance;
    // _firebaseMessaging.getToken().then((value){
    //   print('Token: $value');
    //
    //   var session = FlutterSession();
    //   session.set('device_token', value.toString());
    //   save_devicetoken(value.toString()); // SAVE DEVICE TOKEN
    // });
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool lightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor:
      lightMode ? const Color(0xffe1f5fe) : const Color(0xff042a49),
      body: Center(
          child: lightMode
              ? Image.asset('graphics/rectangle3.png')
              : Image.asset('graphics/rectangle41.png')),
    );
  }
}

class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    await Future.delayed(const Duration(seconds: 3));
  }
}