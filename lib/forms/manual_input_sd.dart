import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:check_check/module_common.dart';


//Форма ручного ввода
class ManualInputPage_SD extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage_SD> {
//  //Переменные сканера
//  String result_scan = "";
//  //переменные imagePicker
//  String image_path = "";
//  //Переменные даты аремени формы
//  DateTime _date = DateTime.now();
//  DateFormat formatter = new DateFormat('dd-MM-yyyy');
//  DateFormat formatter_send = new DateFormat('yyyyMMddTHHmm');
//  TimeOfDay _time = TimeOfDay.now();
  //Переменные формы
//  final controller_date = TextEditingController();
//  final controller_time = TextEditingController();
//  final controller_s = TextEditingController();
//  final controller_fn = TextEditingController();
//  final controller_fd = TextEditingController();
//  final controller_fpd = TextEditingController();
final controller_subject = TextEditingController();
final controller_text = TextEditingController();

//  //При выборе даты
//  Future<Null> _selectDate(BuildContext context) async {
//    final DateTime picked = await showDatePicker(context: context, initialDate: _date, firstDate: new DateTime(2018), lastDate: new DateTime(2050));
//
//    if(picked != null){
//      setState(() {
//        _date = picked;
//        controller_date.text = formatter.format(_date);
//      });
//    }
//  }

//  //При выборе времени
//  Future<Null> _selectTime(BuildContext context) async {
//    final TimeOfDay picked = await showTimePicker(context: context, initialTime: _time);
//
//    if(picked != null){
//      setState(() {
//        _time = picked;
//        controller_time.text = _time.format(context);
//      });
//    }
//  }

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

//  //Локальные функции
//  NumberToString(int number){
//    String numberstring =  number.toString();
//    if (numberstring.length == 1){
//      numberstring = '0' + numberstring;
//    }
//    return numberstring;
//  }

//  //При выборе картинки
//  Future getImage() async {
//    try {
//      var image = await ImagePicker.pickImage(source: ImageSource.camera);
//      setState(() {
//        print(image.path);
//        image_path = image.path;
//      }) ;
//    } catch(error){
//
//    }
//  }

  //отправка данных
  submit() async{
    String imageBase64 = "";
    //Обработки проверки заполнения форм
    if (_validateRequiredField(controller_subject.text,'Тема')){
      return;
    };
////    if (_validateRequiredField(controller_time.text,'Время')){
////      return;
////    };
////    if (_validateRequiredField(controller_fn.text,'ФН')){
////      return;
////    };
    if (_validateRequiredField(controller_text.text,'Описание')){
      return;
    };
////    if (_validateRequiredField(controller_fpd.text,'ФПД.')){
////      return;
////    };
////    if (_validateRequiredField(controller_s.text,'Сумма')){
////      return;
////    };
////    try{
////      imageBase64 = base64Encode(File(image_path).readAsBytesSync());
////    } catch(error){
////      CreateshowDialog(context,new Text(
////        'Фотография чека отсутствует',
////        style: new TextStyle(fontSize: 16.0),
////      ));
////      return;
////    };
    //Методы отправки
    LoadingStart(context);
    try {
//      var formatter_datetime = new DateTime(_date.year,_date.month,_date.day,_time.hour,_time.minute);
//      var response = await http.post('${ServerUrl}/hs/mobilecheckcheck/addrecordqr',
//          body: '{"user":"${UserUID}","datetime":"${formatter_send.format(formatter_datetime)}","s":"${controller_s.text}","fn":"${controller_fn.text}","fd":"${controller_fd.text}","fpd":"${controller_fpd.text}","photo_check":"${imageBase64}"}',
//          headers: {
//            'content-type': 'application/json',
//            'Authorization': 'Basic YXBpOmFwaQ=='
//          }
//      );

      var response = await http.post('${ServerSDURLPost}?OPERATION_NAME=ADD_REQUEST&TECHNICIAN_KEY=5941482B-E801-4520-ABBC-530CC9826A40&INPUT_DATA=<Details><parameter><name>requester</name><value>${UserUID}</value></parameter><parameter><name>subject</name><value>${controller_subject.text}</value></parameter><parameter><name>description</name><value>${controller_text.text}</value></parameter></Details>'

      );

      if (response.statusCode == 200) {
        LoadingStop(context);
        //CreateshowDialog(context,new Text(
        //  "Данные успешно отправлены",
        //  style: new TextStyle(fontSize: 16.0),
        //));
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

//  //инициализация сканера
//  Future _scanQR() async {
//    try {
//      String qrResult = await BarcodeScanner.scan();
//      setState(() {
//        result_scan = "Успешно";
//        var ArrayData = qrResult.split('&');
//        var DateTime_String = ArrayData[0].replaceAll('t=', '');
//        _date = DateTime.parse(DateTime_String);
//        _time = new TimeOfDay(hour: _date.hour, minute: _date.minute);
//
//        controller_date.text = formatter.format(_date);
//        controller_time.text = _time.format(context);
//
//        controller_s.text = ArrayData[1].replaceAll('s=', '');
//        controller_fn.text = ArrayData[2].replaceAll('fn=', '');
//        controller_fd.text = ArrayData[3].replaceAll('i=', '');
//        controller_fpd.text = ArrayData[4].replaceAll('fp=', '');
//      });
//    } on PlatformException catch (ex) {
//      if (ex.code == BarcodeScanner.CameraAccessDenied) {
//        setState(() {
//          result_scan = "Разрешение к камере не получено";
//        });
//      } else {
//        setState(() {
//          result_scan = "Неизвестная ошибка $ex";
//        });
//      }
//    } on FormatException {
//      setState(() {
//        result_scan = "Вы нажали кнопку назад, прежде чем сканировать что-либо";
//      });
//    } catch (ex) {
//      setState(() {
//        result_scan = "Неизвестная ошибка $ex";
//      });
//    }
 // }

  @override
  Widget build(BuildContext context) {

//    Image PhotoCheck;
//    if(image_path != ""){
//      PhotoCheck = Image.file(File(image_path));
//    }else{
//      PhotoCheck = Image.asset('assets/images/camera.png');
//    };

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Вопрос'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            child: new ListView(
              children: <Widget>[
//                Row(
//                  children: <Widget>[
//                    Expanded(
//                      child:new GestureDetector(
//                        onTap: (){_selectDate(context);},
//                          behavior: HitTestBehavior.opaque,
//                          child: new TextFormField(
//                            enabled: false,
//                            controller: controller_date,
//                            keyboardType: TextInputType.datetime,
//                            decoration: new InputDecoration(
//                                labelText: 'Дата',
//                            ),
//                        )
//                      )
//                    ),
//                    Expanded(
//                      child:new GestureDetector(
//                        onTap: (){_selectTime(context);},
//                        behavior: HitTestBehavior.opaque,
//                        child: new TextFormField(
//                          enabled: false,
//                          controller: controller_time,
//                          keyboardType: TextInputType.datetime,
//                          decoration: new InputDecoration(
//                            labelText: 'Время',
//                          ),
//                        )
//                      )
//                    ),
//                  ]
//                ),
//                new TextFormField(
//                    controller: controller_s,
//                    keyboardType: TextInputType.number,
//                    decoration: new InputDecoration(
//                        labelText: 'Сумма'
//                    ),
//                    inputFormatters: [ValidatorInputFormatter(
//                      editingValidator: DecimalNumberEditingRegexValidator(),
//                    )],
//                ),
                new TextFormField(
                    controller: controller_subject,
                    maxLength: 100,
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                        labelText: 'Тема'
                    ),
                    //inputFormatters: <TextInputFormatter>[
                    //  WhitelistingTextInputFormatter(RegExp(r"(\w+)")),
                    //],
                ),
//                new TextFormField(
//                    controller: controller_fd,
//                    maxLength: 10,
//                    keyboardType: TextInputType.number,
//                    decoration: new InputDecoration(
//                        labelText: 'ФД'
//                    ),
//                    inputFormatters: <TextInputFormatter>[
//                      WhitelistingTextInputFormatter(RegExp(r"(\w+)")),
//                    ],
//                ),
                new TextFormField(
                    controller: controller_text,
                    maxLines: null,
                    maxLength: 1000,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                        labelText: 'Описание'
                    ),
                    //inputFormatters: <TextInputFormatter>[
                    //  WhitelistingTextInputFormatter(RegExp(r"(\w+)")),
                    //],
                ),

//                new Container(
//                  decoration:
//                  new BoxDecoration(border: Border.all(color: Colors.black)),
//                  child: new FlatButton(
//                        onPressed: this.getImage,
//                        child: PhotoCheck,
//                    )
//                ),
//                new Container(
//                  decoration:
//                  new BoxDecoration(border: Border.all(color: Colors.black)),
//                  child: new ListTile(
//                    title: new Text(
//                      "Сканер",
//                      textAlign: TextAlign.center,
//                    ),
//                    onTap: this._scanQR,
//                  ),
//                  margin: new EdgeInsets.only(
//                      top: 20.0
//                  ),
//                ),
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
}