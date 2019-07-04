import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:check_check/forms/activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:check_check/module_common.dart';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/forms/registration.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();

  bool checkValue = false;

  SharedPreferences sharedPreferences;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();

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
    _firebaseMessaging.getToken().then((token){
      print(token);
    });
    getCredential();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white12,
      ),
      body: new SingleChildScrollView(
        child: _body(),
        scrollDirection: Axis.vertical,
      ),
    );
  }

  Widget _body() {
    return new Container(
      padding: EdgeInsets.only(right: 20.0, left: 20.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: EdgeInsets.all(30.0),
            child: new Image.asset(
              "assets/images/open_logo.png",
              height: 100.0,
            ),
          ),
          new TextField(
            controller: username,
            decoration: InputDecoration(
                hintText: "Логин",
                hintStyle: new TextStyle(color: Colors.grey.withOpacity(0.3))),
          ),
          new TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "Пароль",
                  hintStyle:
                  new TextStyle(color: Colors.grey.withOpacity(0.3)))),
          new CheckboxListTile(
            value: checkValue,
            onChanged: _onChanged,
            title: new Text("Запомнить"),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          new Container(
            decoration:
            new BoxDecoration(border: Border.all(color: Colors.black)),
            child: new ListTile(
              title: new Text(
                "Вход",
                textAlign: TextAlign.center,
              ),
              onTap: LoginOnClick,
            ),
          ),
          new Container(
            decoration:
            new BoxDecoration(border: Border.all(color: Colors.black)),
            child: new ListTile(
              title: new Text(
                "Регистрация",
                textAlign: TextAlign.center,
              ),
              onTap: RegistrationOnClick,
            ),
            margin: new EdgeInsets.only(
                top: 20.0
            ),
          )
        ],
      ),
    );
  }

  _onChanged(bool value) async {
    setState((){
      checkValue = value;
    });
  }

  setCredential(bool value) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("check", value);
    if(value) {
      sharedPreferences.setString("username", username.text);
      sharedPreferences.setString("password", password.text);
      //session variable
      sharedPreferences.setString("session_username", username.text);
      sharedPreferences.commit();
    }else{
      sharedPreferences.remove("username");
      sharedPreferences.remove("password");
    }
  }

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      checkValue = sharedPreferences.getBool("check");
      if (checkValue != null) {
        if (checkValue) {
          username.text = sharedPreferences.getString("username");
          password.text = sharedPreferences.getString("password");
        }
      } else {
        checkValue = false;
      }
    });
  }

  LoginOnClick() async{
    if (username.text.length != 0 || password.text.length != 0) {
      LoadingStart(context);
      try {
        var response = await http.get('${ServerUrl}/hs/mobilecheckcheck/login?user=${username.text}&pass=${password.text}',
            headers: {
              'content-type': 'application/json',
              'Authorization': 'Basic YXBpOmFwaQ=='
            }
        );
        if (response.statusCode == 200) {
          LoadingStop(context);
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(
                  builder: (BuildContext context) => new ActivityPage()),
                  (Route<dynamic> route) => false);
          setCredential(checkValue);
          var json_response = json.decode(response.body);
          User = json_response['user'];
          UserUID = json_response['user_uid'];
        } else {
          LoadingStop(context);
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          CreateshowDialog(context,new Text(
            response.body,
            style: new TextStyle(fontSize: 16.0),
          ));
        }
      } catch (error) {
        LoadingStop(context);
        print(error.toString());
        CreateshowDialog(context,new Text(
          'Ошибка соединения с сервером',
          style: new TextStyle(fontSize: 16.0),
        ));
      };
    } else {
      CreateshowDialog(context, new Text(
          "Логин или пароль \nне может быть пустым",
          style: new TextStyle(fontSize: 16.0)
      ));
    }
  }

  RegistrationOnClick() async{
    Navigator.push(context, MaterialPageRoute(builder: (context)=> RegistrationPage()));
  }
}


