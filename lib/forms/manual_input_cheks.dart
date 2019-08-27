import 'dart:convert';
import 'dart:io';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:check_check/data/static_variable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:check_check/validator.dart';
import 'package:check_check/module_common.dart';
import 'package:image_picker/image_picker.dart';
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

  //Переменные даты аремени формы
  DateTime _date = DateTime.now();
  DateFormat formatter = new DateFormat('dd-MM-yyyy');
  DateFormat formatter_send = new DateFormat('yyyyMMddTHHmm');
  TimeOfDay _time = TimeOfDay.now();

  //Переменные формы
  final controller_date = TextEditingController();
  final controller_time = TextEditingController();
  final controller_s = TextEditingController();
  final controller_fn = TextEditingController();
  final controller_fd = TextEditingController();
  final controller_fpd = TextEditingController();

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

  //При выборе картинки
  Future getImage() async {
    try {
      var image = await ImagePicker.pickImage(source: ImageSource.camera);
      setState(() {
        print(image.path);
        image_path = image.path;
      });
    } catch (error) {}
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
    if (_validateRequiredField(controller_fn.text, 'ФН')) {
      return;
    }
    ;
    if (_validateRequiredField(controller_fd.text, 'ФД')) {
      return;
    }
    ;
    if (_validateRequiredField(controller_fpd.text, 'ФПД.')) {
      return;
    }
    ;
    if (_validateRequiredField(controller_s.text, 'Сумма')) {
      return;
    }
    ;
    try {
      imageBase64 = base64Encode(File(image_path).readAsBytesSync());
    } catch (error) {
      CreateshowDialog(
          context,
          new Text(
            'Фотография чека отсутствует',
            style: new TextStyle(fontSize: 16.0),
          ));
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
              '{"type":"add","user":"${UserUID}","datetime":"${formatter_send.format(formatter_datetime)}","s":"${controller_s.text}","fn":"${controller_fn.text}","fd":"${controller_fd.text}","fpd":"${controller_fpd.text}","photo_check":"${imageBase64}"}',
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Basic ${AuthorizationString}'
          });
      if (response.statusCode == 200) {
        LoadingStop(context);
        Navigator.pop(context);
        widget.callback();
//        CreateshowDialog(context,new Text(
//          "Данные успешно отправлены",
//          style: new TextStyle(fontSize: 16.0),
//        ));
        print('ok!');
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

  //инициализация сканера
  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result_scan = "Успешно";
        var ArrayData = qrResult.split('&');
        var DateTime_String = ArrayData[0].replaceAll('t=', '');
        _date = DateTime.parse(DateTime_String);
        _time = new TimeOfDay(hour: _date.hour, minute: _date.minute);

        controller_date.text = formatter.format(_date);
        controller_time.text = _time.format(context);

        controller_s.text = ArrayData[1].replaceAll('s=', '');
        controller_fn.text = ArrayData[2].replaceAll('fn=', '');
        controller_fd.text = ArrayData[3].replaceAll('i=', '');
        controller_fpd.text = ArrayData[4].replaceAll('fp=', '');
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result_scan = "Разрешение к камере не получено";
        });
      } else {
        setState(() {
          result_scan = "Неизвестная ошибка $ex";
        });
      }
    } on FormatException {
      setState(() {
        result_scan = "Вы нажали кнопку назад, прежде чем сканировать что-либо";
      });
    } catch (ex) {
      setState(() {
        result_scan = "Неизвестная ошибка $ex";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Image PhotoCheck;
    if (image_path != "") {
      PhotoCheck = Image.file(File(image_path));
    } else {
      PhotoCheck = Image.asset('assets/images/camera.png');
    }
    ;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Отправка чека'),
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
                  controller: controller_s,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(labelText: 'Сумма'),
                  inputFormatters: [
                    ValidatorInputFormatter(
                      editingValidator: DecimalNumberEditingRegexValidator(),
                    )
                  ],
                ),
                new TextFormField(
                  controller: controller_fn,
                  maxLength: 16,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(labelText: 'ФН'),
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter(RegExp(r"(\w+)")),
                  ],
                ),
                new TextFormField(
                  controller: controller_fd,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(labelText: 'ФД'),
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter(RegExp(r"(\w+)")),
                  ],
                ),
                new TextFormField(
                  controller: controller_fpd,
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(labelText: 'ФПД'),
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter(RegExp(r"(\w+)")),
                  ],
                ),
                new Container(
                    decoration: new BoxDecoration(
                        border: Border.all(color: Colors.black)),
                    child: new FlatButton(
                      onPressed: this.getImage,
                      child: PhotoCheck,
                    )),
                new Container(
                  decoration: new BoxDecoration(
                      border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    title: new Text(
                      "Сканер",
                      textAlign: TextAlign.center,
                    ),
                    onTap: this._scanQR,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
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
