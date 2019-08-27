import 'package:check_check/forms/waybills.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:check_check/validator.dart';
import 'package:check_check/module_common.dart';
import 'package:intl/intl.dart';

//Класс инициализации
class ManualInputWaybillsAddRoutePage extends StatefulWidget {
  Function(String, int) callback;
  WaybillsRouteData waybills_route;
  int index;

  ManualInputWaybillsAddRoutePage(
      this.callback, this.waybills_route, this.index);

  @override
  State<StatefulWidget> createState() {
    return new ManualInputWaybillsAddRouteState();
  }
}

class ManualInputWaybillsAddRouteState
    extends State<ManualInputWaybillsAddRoutePage> {
  //Переменные даты аремени формы
  DateTime _date1 = DateTime.now();
  DateFormat formatter = new DateFormat('dd.MM.yyyy');
  DateTime _date2 = DateTime.now();

  //Переменные формы
  final controller_date1 = TextEditingController();
  final controller_date2 = TextEditingController();
  final controller_point_a = TextEditingController();
  final controller_point_b = TextEditingController();
  final controller_kilometers = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.waybills_route != null) {
      controller_date1.text = widget.waybills_route.date1;
      controller_date2.text = widget.waybills_route.date2;
      controller_point_a.text = widget.waybills_route.point_A;
      controller_point_b.text = widget.waybills_route.point_B;
      controller_kilometers.text = widget.waybills_route.km.toString();
      var array_string_date1 = widget.waybills_route.date1.split('.');
      var array_string_date2 = widget.waybills_route.date2.split('.');
      _date1 = DateTime.parse(array_string_date1[2] +
          array_string_date1[1] +
          array_string_date1[0] +
          'T000000');
      _date2 = DateTime.parse(array_string_date2[2] +
          array_string_date2[1] +
          array_string_date2[0] +
          'T000000');
    }
  }

  //При выборе дат
  Future<Null> selectDate1(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date1,
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2050));

    if (picked != null) {
      setState(() {
        _date1 = picked;
        controller_date1.text = formatter.format(_date1);
      });
    }
  }

  Future<Null> selectDate2(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date2,
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2050));

    if (picked != null) {
      setState(() {
        _date2 = picked;
        controller_date2.text = formatter.format(_date2);
      });
    }
  }

  validateRequiredField(String value, String Field) {
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

  //Добавление
  addRoute() async {
    if (validateRequiredField(controller_point_a.text, 'Пункт А')) {
      return;
    }
    ;
    if (validateRequiredField(controller_point_b.text, 'Пункт B')) {
      return;
    }
    ;
    if (validateRequiredField(controller_date1.text, 'Дата начала')) {
      return;
    }
    ;
    if (validateRequiredField(controller_date2.text, 'Дата конца')) {
      return;
    }
    ;
    if (validateRequiredField(controller_kilometers.text, 'КМ.')) {
      return;
    }
    ;

    String jsonInline =
        '{"ПунктОтправления":"${controller_point_a.text}","ПунктНазначения":"${controller_point_b.text}","ДатаВыезда":"${controller_date1.text}","ДатаВозвращения":"${controller_date2.text}","ПройденныйКилометраж":${double.parse(controller_kilometers.text).toDouble()}}';
    widget.callback(jsonInline, widget.index);
    Navigator.of(context).pop(jsonInline);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Точка маршрута'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            child: new ListView(
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                      child: new TextFormField(
                    controller: controller_point_a,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(labelText: 'Пункт А'),
                  )),
                  Expanded(
                      child: new TextFormField(
                    controller: controller_point_b,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(labelText: 'Пункт Б'),
                  )),
                ]),
                Row(children: <Widget>[
                  Expanded(
                      child: new GestureDetector(
                          onTap: () {
                            selectDate1(context);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: new TextFormField(
                            enabled: false,
                            controller: controller_date1,
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                              labelText: 'Дата начала',
                            ),
                          ))),
                  Expanded(
                      child: new GestureDetector(
                          onTap: () {
                            selectDate2(context);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: new TextFormField(
                            enabled: false,
                            controller: controller_date2,
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                              labelText: 'Дата конца',
                            ),
                          ))),
                ]),
                new TextFormField(
                  controller: controller_kilometers,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(labelText: 'КМ.'),
                  inputFormatters: [
                    ValidatorInputFormatter(
                      editingValidator: DecimalNumberEditingRegexValidator(),
                    )
                  ],
                ),
                new Container(
                  decoration: new BoxDecoration(
                      border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    title: new Text(
                      "Ок",
                      textAlign: TextAlign.center,
                    ),
                    onTap: addRoute,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );
  }
}
