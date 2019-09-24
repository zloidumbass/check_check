import 'dart:io';

import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:check_check/module_common.dart';
import 'package:package_info/package_info.dart';


//Форма ручного ввода
class ManualInputPage_SD extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage_SD> {

final controller_subject = TextEditingController();
final controller_text = TextEditingController();

  _validateRequiredField(String value, String Field) {
    if (value.isEmpty) {
      CreateshowDialog(context,new Text(
        'Поле "${Field}" не заполнено',
        style: new TextStyle(fontSize: 16.0),
      ));
      return true;
    }
    return false;
  }

  //отправка данных
  submit() async{
    String imageBase64 = "";
    //Обработки проверки заполнения форм
    if (_validateRequiredField(controller_subject.text,'Тема')){
      return;
    };
    if (_validateRequiredField(controller_text.text,'Описание')){
      return;
    };
    String DeviceAndPackageInfo =  await _DeviceAndPackageInfo();

    //Методы отправки
    LoadingStart(context);
    try {

      var response = await http.post('${ServerSDURLPost}?OPERATION_NAME=ADD_REQUEST&TECHNICIAN_KEY=5941482B-E801-4520-ABBC-530CC9826A40&INPUT_DATA=<Details><parameter><name>requester</name><value>${UserUID}</value></parameter><parameter><name>subject</name><value>${controller_subject.text}</value></parameter><parameter><name>description</name><value>${controller_text.text+' '+DeviceAndPackageInfo}</value></parameter></Details>'

      );

      if (response.statusCode == 200) {
        LoadingStop(context);
         Navigator.pop(context);
        print('ok!');
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
 }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Вопрос'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            child: new ListView(
              children: <Widget>[
                new TextFormField(
                    controller: controller_subject,
                    maxLength: 100,
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                        labelText: 'Тема'
                    ),
                ),
                new TextFormField(
                    controller: controller_text,
                    maxLines: null,
                    maxLength: 1000,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                        labelText: 'Описание'
                    ),
                ),
                new Container(
                  decoration:
                  new BoxDecoration(border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    title: new Text(
                      "Отправить",
                      textAlign: TextAlign.center,
                    ),
                    onTap: this.submit,
                  ),
                  margin: new EdgeInsets.only(
                      top: 20.0
                  ),
                )
              ],
            ),
          )
      ),
    );
  }


  _DeviceAndPackageInfo() async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    //String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    String operatingSystem = Platform.operatingSystem;

    print(operatingSystem);
    print(appName);
    //print(packageName);
    print(version);
    print(buildNumber);

    String release = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (operatingSystem == 'android')  {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"
      print(androidInfo.version.release);
      release = androidInfo.version.release;
    }
    else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
      release = iosInfo.utsname.machine;
    };

    //print(appName + ' ' + version + '.' + buildNumber + ', OS ' + operatingSystem + ' ' + release);
    //return '\\n\---\\n\' + appName + ' ' + version + '.' + buildNumber + ', OS ' + operatingSystem + ' ' + release;
    return '\n  ---' + appName + ' ' + version + '.' + buildNumber + ', OS ' + operatingSystem + ' ' + release + ' ' + User + ' ' + UserPhone;

  }

}