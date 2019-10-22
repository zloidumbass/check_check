import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:check_check/forms/manual_edit_cheks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../module_common.dart';

//Глобальные переменные модуля
final int MaxLenghtNom = 14;

//Классы данных
class CheckData {
  final String name, doc_sum, full_name, date_time, sum, fn, fd, fpd, UID;
  final double amount;
  final bool check_select;
  List nomenclature;
  String status;
  final Icon icon;

  CheckData(
      {this.name,
      this.check_select,
      this.icon,
      this.sum,
      this.doc_sum,
      this.status,
      this.full_name,
      this.date_time,
      this.fn,
      this.fd,
      this.fpd,
      this.nomenclature,
      this.UID,
      this.amount});

  factory CheckData.fromJson(Map<String, dynamic> jsonData) {
    return CheckData(
      name: 'Чек от ' +
          jsonData['ДатаЧека'].toString().substring(6, 8) +
          '.' +
          jsonData['ДатаЧека'].toString().substring(4, 6) +
          '.' +
          jsonData['ДатаЧека'].toString().substring(0, 4),
      sum: jsonData['Сумма'].toString(),
      check_select: jsonData['ЧекВыбран'],
      doc_sum: jsonData['ДокументСумма'].toString(),
      icon: getIcon(jsonData['Статус'].toString()),
      status: getStatus(jsonData['Статус'].toString()),
      full_name: jsonData['ФизическоеЛицо'].toString(),
      date_time: jsonData['ДатаЧека'],
      nomenclature: jsonData['Номенклатура'],
      fn: jsonData['ФН'].toString(),
      fd: jsonData['ФД'].toString(),
      fpd: jsonData['ФПД'].toString(),
      amount: jsonData['ДокументКоличество'],
      UID: jsonData['СсылкаНаДокумент_Key'].toString(),
    );
  }
}

class Nomenclature {
  final String nomenclature, id;
  bool accepted;

  Nomenclature({this.nomenclature, this.accepted, this.id});

  factory Nomenclature.fromJson(Map<String, dynamic> jsonData) {
    return Nomenclature(
      nomenclature: jsonData['Номенклатура'].toString(),
      accepted: !jsonData['НеПринимаетсяКУчету'],
      id: jsonData['НомерСтроки'].toString(),
    );
  }
}

getIcon(String status) {
  Icon return_icon;
  if (status == 'Отправлен') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Не существует') {
    return_icon = new Icon(Icons.error, color: Colors.red);
  } else if (status == 'Проверен ФНС') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Подтверждено ФНС') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'На рассмотрении') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Требует ввода путевого листа') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Ожидает проверки путевого листа') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Готов к оплате') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Принят в БУ') {
    return_icon = new Icon(Icons.check, color: Colors.green);
  } else if (status == 'Отказ') {
    return_icon = new Icon(Icons.error, color: Colors.red);
  } else {
    return_icon = new Icon(Icons.error, color: Colors.red);
  }
  return return_icon;
}

getStatus(String status) {
  String representation_status;
  if (status == 'Отправлен') {
    representation_status = 'Отправлен';
  } else if (status == 'Не существует') {
    representation_status = 'Не существует';
  } else if (status == 'Проверен ФНС') {
    representation_status = 'Проверен ФНС';
  } else if (status == 'Подтверждено ФНС') {
    representation_status = 'Подтверждено ФНС';
  } else if (status == 'На рассмотрении') {
    representation_status = 'На рассмотрении';
  } else if (status == 'Требует ввода путевого листа') {
    representation_status = 'Ввод путевого';
  } else if (status == 'Ожидает проверки путевого листа') {
    representation_status = 'Проверка путевого';
  } else if (status == 'Готов к оплате') {
    representation_status = 'Готов к оплате';
  } else if (status == 'Принят в БУ') {
    representation_status = 'Принят в БУ';
  } else if (status == 'Отказ') {
    representation_status = 'Отказ';
  } else {
    representation_status = 'Неизвестно';
  }
  return representation_status;
}

//Исполняемые классы
class CheckPage extends StatefulWidget {
  @override
  CheckPageState createState() {
    return new CheckPageState();
  }
}

class CheckPageState extends State<CheckPage> {
  int sharedValue = 0;
  List<CheckData> check_data;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool list_lock = false;
  ScrollController _scrollController = new ScrollController();

  void _getMoreData() async {
    if (!list_lock) {
      setState(() {
        list_lock = true;
      });
      final jsonEndpoint = '${ServerUrl}/hs/mobilecheckcheck/addrecordqr?selection_value=${this.sharedValue}&last_index=${this.check_data.length}';
      try {
        final response = await http.get(jsonEndpoint,
            headers: {
              'Authorization': 'Basic ${AuthorizationString}',
              'content-version': Version+'.'+BuildNumber
            });
        if (response.statusCode == 200) {
          List check_data = json.decode(response.body);
          List<CheckData> tempList = List<CheckData>();
          for (var check_element in check_data.map((check_data) => new CheckData.fromJson(check_data)).toList()) {
            tempList.add(check_element);
          }
          setState(() {
            list_lock = false;
            this.check_data.addAll(tempList);
          });

        } else
          print(response.body);
      } catch (error) {
        print(error.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    refreshList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  turnOnUpdate() {
    refreshList();
  }

  Future<Null> refreshList() async {
    this._refreshIndicatorKey.currentState?.show(atTop: true);
    check_data = await this.downloadCheckData();
    setState(() {});

    return null;
  }

  //Future is n object representing a delayed computation.
  Future<List<CheckData>> downloadCheckData() async {
    list_lock = true;
    final jsonEndpoint = '${ServerUrl}/hs/mobilecheckcheck/addrecordqr?selection_value=${sharedValue}';
    try {
      final response = await http.get(jsonEndpoint,
          headers: {
            'Authorization': 'Basic ${AuthorizationString}',
            'content-version': Version+'.'+BuildNumber
        });
      if (response.statusCode == 200) {
        List check_data = json.decode(response.body);
        if (check_data.length != 0) {
          list_lock = false;
          return check_data
              .map((check_data) => new CheckData.fromJson(check_data))
              .toList();
        } else
          return List<CheckData>();
      } else
        print(response.body);
      return List<CheckData>();
    } catch (error) {
      print(error.toString());
      return List<CheckData>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Widget> children = const <int, Widget>{
      0: Padding(
          padding: EdgeInsets.all(10),
          child: Text('Все')),
      1: Padding(
          padding: EdgeInsets.all(10),
          child: Text('В работе')),
      2: Padding(
          padding: EdgeInsets.all(10),
          child: Text('Архив')),
    };

    return CreateDefaultMasterForm(
        1,
        new Center(
            child: new Column(children: <Widget>[
              new SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: new CupertinoSegmentedControl<int>(
                    padding: EdgeInsets.all(5.0),
                    children: children,
                    onValueChanged: (int newValue) {
                      setState(() {
                        sharedValue = newValue;
                        check_data = null;
                        refreshList();
                      });
                    },
                    groupValue: sharedValue,
                  )),
              new Expanded(child: CreateListForm(check_data, _refreshIndicatorKey, context, _scrollController, list_lock, CustomListViewTile, refreshList))
            ])),
        context,
        turnOnUpdate);
  }

  //ЭЛЕМЕНТ СПИСКА
  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  //Элемент списка
  CustomListViewTile(CheckData check_data) {
    return new Card(
      child: new Column(children: <Widget>[
        new ListTile(
            leading: new Container(
              child: check_data.icon,
            ),
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  check_data.name,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                new Text(
                  check_data.status,
                  style: new TextStyle(color: Colors.grey, fontSize: 13.0),
                ),
              ],
            ),
            subtitle: new Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: new Text(
                'Сумма: ' + check_data.doc_sum,
                style: new TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ),
            onTap: () {
              if (!list_lock) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ManualEditPage(check_data, turnOnUpdate)));
              }
            })
      ]),
    );
  }
}
