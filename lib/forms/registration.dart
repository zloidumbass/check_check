import 'dart:convert';
import 'package:check_check/data/session_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:check_check/data/static_variable.dart';

import '../module_common.dart';
import '../validator.dart';

class RegistrationPage extends StatefulWidget {
  @override
  RegistrationPageState createState() => new RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final controller_login = TextEditingController();
  final controller_full_login = TextEditingController();
  final controller_password = TextEditingController();

  //step = 0 - ввод ФИО и пароля, step = 1 ввод кода подтверждения/пароля
  int step = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text("РЕГИСТРАЦИЯ"),
        ),
        body: new Container(
            padding: new EdgeInsets.all(20.0),
            child: new Form(
              child: new ListView(
                children: <Widget>[
                  new Container(
                    margin: EdgeInsets.all(30.0),
                    child: new Image.asset(
                      "assets/images/open_logo.png",
                      height: 100.0,
                    ),
                  ),
                  new TextFormField(
                          controller: controller_full_login,
                          keyboardType: TextInputType.text,
                          decoration: new InputDecoration(labelText: 'ФИО'),
                        ),
                  new TextFormField(
                          controller: controller_login,
                          keyboardType: TextInputType.phone,
                          decoration: new InputDecoration(labelText: 'Телефон'),
                          inputFormatters: [
                            ValidatorInputFormatter(
                              editingValidator:
                                  DecimalPhoneEditingRegexValidator(),
                            )
                          ],
                        ),
                      new TextFormField(
                          controller: controller_password,
                          keyboardType: TextInputType.text,
                          decoration: new InputDecoration(labelText: 'Пароль'),
                        ),
                  new Container(
                          decoration: new BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          child: new ListTile(
                            title: new Text(
                              "Зарегистрироваться",
                              textAlign: TextAlign.center,
                            ),
                            onTap: this.registration,
                          ),
                          margin: new EdgeInsets.only(top: 20.0),
                        ),
                ],
              ),
            )));
  }

  void submitMessage() async {
//    if (controller_login.text.length != 0) {
//      LoadingStart(context);
//      try {
//        //Регистрация пользователя в фнс
//        var response_fns = await http.post(
//            'https://proverkacheka.nalog.ru:9999/v1/mobile/users/signup',
//            headers: {
//              'content-type': 'application/json'
//            },
//            body:
//                '{"email":"some@mail.com","name":"${controller_full_login.text}","phone":"${controller_login.text}"}');
//        //Если успешно, то идём к шагу 2
//        if (response_fns.statusCode == 204) {
//          LoadingStop(context);
//          setState(() {
//            step = 1;
//          });
//          //Если код 409, значит пользователь есть в базе фнс, но есть ли он у нас?
//        } else if (response_fns.statusCode == 409) {
//          //Смотрим есть ли пользователь у нас в базе
//          var response_login = await http.get(
//              '${ServerUrlNoAuth}/hs/mobilecheckcheck/login?user=${controller_login.text}&check=true',
//              headers: {
//                'content-type': 'application/json',
//                'content-version': Version+'.'+BuildNumber
//              });
//          //Если есть то пишем, что пользователь существует
//          if (response_login.statusCode == 200) {
//            LoadingStop(context);
//            CreateshowDialog(
//                context,
//                new Text(
//                  "Пользователь уже существует",
//                  style: new TextStyle(fontSize: 16.0),
//                ));
//            //Если код 401 (не авторизован) то такого пользователя в базе нет
//          } else if (response_login.statusCode == 401) {
//            print("Response status: ${response_login.statusCode}");
//            print("Response body: ${response_login.body}");
//
//            //Делаем восстановление пароля, для присвоения его пользователю
//            var response = await http.post(
//                'https://proverkacheka.nalog.ru:9999/v1/mobile/users/restore',
//                headers: {'content-type': 'application/json'},
//                body: '{"phone":"${controller_login.text}"}');
//            if (response.statusCode == 204) {
//              LoadingStop(context);
//              setState(() {
//                step = 1;
//              });
//            } else {
//              LoadingStop(context);
//              print("Response status: ${response.statusCode}");
//              print("Response body: ${response.body}");
//              CreateshowDialog(
//                  context,
//                  new Text(
//                    response.body,
//                    style: new TextStyle(fontSize: 16.0),
//                  ));
//            }
//          }
//        } else {
//          LoadingStop(context);
//          print("Response status: ${response_fns.statusCode}");
//          print("Response body: ${response_fns.body}");
//          CreateshowDialog(
//              context,
//              new Text(
//                response_fns.body,
//                style: new TextStyle(fontSize: 16.0),
//              ));
//        }
//      } catch (error) {
//        LoadingStop(context);
//        print(error.toString());
//        CreateshowDialog(
//            context,
//            new Text(
//              'Ошибка соединения с сервером',
//              style: new TextStyle(fontSize: 16.0),
//            ));
//      }
//      ;
//    } else {
//      CreateshowDialog(
//          context,
//          new Text("Телефон не может быть пустым",
//              style: new TextStyle(fontSize: 16.0)));
//    }
  }

  void registration() async {
    if (controller_login.text.length != 0) {
      LoadingStart(context);
      try {
        var response = await http.post(
            '${ServerUrlNoAuth}/hs/mobilecheckcheck/login',
            headers: {
              'content-type': 'application/json',
              'content-version': Version+'.'+BuildNumber
            },
            body:
                '{"user":"${controller_login.text}","full_user":"${controller_full_login.text}","pass":"${controller_password.text}"}');
        if (response.statusCode == 200) {
          LoadingStop(context);
          Navigator.pop(context);
        } else {
          LoadingStop(context);
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          CreateshowDialog(
              context,
              new Text(
                response.body,
                style: new TextStyle(fontSize: 16.0),
              ));
        }
      } catch (error) {
        LoadingStop(context);
        print(error.toString());
        CreateshowDialog(
            context,
            new Text(
              'Ошибка соединения с сервером',
              style: new TextStyle(fontSize: 16.0),
            ));
      }
      ;
    } else {
      CreateshowDialog(
          context,
          new Text("Телефон не может быть пустым",
              style: new TextStyle(fontSize: 16.0)));
    }
  }
}
