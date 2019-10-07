import 'package:check_check/data/session_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:check_check/forms/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    FSM();
  }

  void FSM() async{
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings){
      print("Setting reg: $settings");
    });
    FSM_token = await _firebaseMessaging.getToken();
    print(FSM_token);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Проверка чеков',
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ru', ''),
      ],
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        FallbackCupertinoLocalisationsDelegate()
      ],
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFFcc3333,
          <int, Color>{
            50: Color(0xFFCCAAAA),
            100: Color(0xFFCCAAAA),
            200: Color(0xFFCCAAAA),
            300: Color(0xFFCC9B9B),
            400: Color(0xFFCC8888),
            500: Color(0xFFcc3333),
            600: Color(0xFFB45151),
            700: Color(0xFFB44242),
            800: Color(0xFFCC4040),
            900: Color(0xFFcc3333),
          },
        ),
      ),
      home: LoginPage(),
    );
  }
}
