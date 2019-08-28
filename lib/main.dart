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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

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
