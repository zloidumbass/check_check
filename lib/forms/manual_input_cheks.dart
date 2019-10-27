import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:check_check/module_common.dart';
import 'package:intl/intl.dart';

//Форма ручного ввода
class ManualInputPage extends StatefulWidget {
  Function callback;

  ManualInputPage(this.callback);

  @override
  State<StatefulWidget> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  //Переменные сканера
  String result_scan = "";

  //переменные imagePicker
  String image_path = "";
  Image PhotoCheck = Image.asset('assets/images/camera.png');
  Icon icon_photo = new Icon(Icons.error, color: Colors.red);

  //Переменные даты аремени формы
  DateTime _date = DateTime.now();
  DateFormat formatter = new DateFormat('dd-MM-yyyy');
  DateFormat formatter_send = new DateFormat('yyyyMMddTHHmm');
  TimeOfDay _time = TimeOfDay.now();

  //Переменные формы
  final controller_date = TextEditingController();
  final controller_time = TextEditingController();
  final controller_addres_to = TextEditingController();
  final controller_addres_do = TextEditingController();
  final controller_comment = TextEditingController();

  //При выборе даты
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2050));

    if (picked != null) {
      setState(() {
        _date = picked;
        controller_date.text = formatter.format(_date);
      });
    }
  }

  //При выборе времени
  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(context: context, initialTime: _time);

    if (picked != null) {
      setState(() {
        _time = picked;
        controller_time.text = _time.format(context);
      });
    }
  }

  _validateRequiredField(String value, String Field) {
    if (value.isEmpty) {
      CreateshowDialog(
          context,
          new Text(
            'Поле "${Field}" не заполнено',
            style: new TextStyle(fontSize: 16.0),
          ));
      return true;
    }
    return false;
  }

  //Локальные функции
  NumberToString(int number) {
    String numberstring = number.toString();
    if (numberstring.length == 1) {
      numberstring = '0' + numberstring;
    }
    return numberstring;
  }

  //отправка данных
  submit() async {
    String imageBase64 = "";
    //Обработки проверки заполнения форм
    if (_validateRequiredField(controller_date.text, 'Дата')) {
      return;
    }
    ;
    if (_validateRequiredField(controller_time.text, 'Время')) {
      return;
    }
    ;
    if (_validateRequiredField(controller_addres_to.text, 'Адрес A')) {
      return;
    }
    ;
    if (_validateRequiredField(controller_addres_do.text, 'Адрес B')) {
      return;
    }
    ;
    //Методы отправки
    LoadingStart(context);
    try {
      var formatter_datetime = new DateTime(
          _date.year, _date.month, _date.day, _time.hour, _time.minute);
      var response = await http.post(
          '${ServerUrl}/hs/mobilecheckcheck/addrecordqr',
          body:
              '{"type":"add","user":"${UserUID}","datetime":"${formatter_send.format(formatter_datetime)}","addres_to":"${controller_addres_to.text}","addres_do":"${controller_addres_do.text}","comment":"${controller_comment.text}"}',
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Basic ${AuthorizationString}',
            'content-version': Version+'.'+BuildNumber
          });
      if (response.statusCode == 200) {
        LoadingStop(context);
        Navigator.pop(context);
        widget.callback();
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
  }

  @override
  Widget build(BuildContext context) {
    if (image_path != "") {
      icon_photo = new Icon(Icons.check, color: Colors.green);
    } else {
      icon_photo = new Icon(Icons.error, color: Colors.red);
    }
    ;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Формирование заказа'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            child: new ListView(
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                      child: new GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: new TextFormField(
                            enabled: false,
                            controller: controller_date,
                            keyboardType: TextInputType.datetime,
                            decoration: new InputDecoration(
                              labelText: 'Дата',
                            ),
                          ))),
                  Expanded(
                      child: new GestureDetector(
                          onTap: () {
                            _selectTime(context);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: new TextFormField(
                            enabled: false,
                            controller: controller_time,
                            keyboardType: TextInputType.datetime,
                            decoration: new InputDecoration(
                              labelText: 'Время',
                            ),
                          ))),
                ]),
                new TextFormField(
                  controller: controller_addres_to,
                  maxLines: null,
                  maxLength: 1000,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(labelText: 'Адрес A'),
                ),
                new TextFormField(
                  controller: controller_addres_do,
                  maxLines: null,
                  maxLength: 1000,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(labelText: 'Адрес B'),
                ),
                new TextFormField(
                  controller: controller_comment,
                  maxLines: null,
                  maxLength: 1000,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(labelText: 'Комментарий'),
                ),
                new Container(
                  decoration: new BoxDecoration(
                      border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    title: new Text(
                      "Отправить",
                      textAlign: TextAlign.center,
                    ),
                    onTap: this.submit,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );
  }
}
