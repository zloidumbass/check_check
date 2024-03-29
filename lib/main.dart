import 'package:check_check/data/session_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:check_check/forms/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_background_location/flutter_background_location.dart';
import 'package:http/http.dart' as http;

import 'data/static_variable.dart';

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

  @override
  void initState() {
    super.initState();
    FlutterBackgroundLocation.startLocationService();
    FlutterBackgroundLocation.getLocationUpdates((location) {
      if(UserUID.isNotEmpty) {

        SetGeoData(location);
        print(
            location.latitude.toString() + ' ' + location.longitude.toString());
      }
    });
    GetVersion();
  }

  void GetVersion() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Version = packageInfo.version;
    BuildNumber = packageInfo.buildNumber;
  }

  void SetGeoData(location) async{
    var response = await http.post(
        '${ServerUrl}/hs/mobilecheckcheck/geodata?user=${UserUID}&latitude=${location.latitude}&longitude=${location.longitude}',
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Basic ${AuthorizationString}',
          'content-version': Version+'.'+BuildNumber
        });
    print(response.statusCode);
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
