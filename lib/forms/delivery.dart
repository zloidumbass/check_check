import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:check_check/forms/manual_edit_delivery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../module_common.dart';

//Глобальные переменные модуля
final int MaxLenghtNom = 14;

//Классы данных
class CheckData {
  final String name, sum, addres_to, addres_do, UID, datetime;
  String status;
  final Icon icon;

  CheckData(
      {this.name,
      this.sum,
      this.datetime,
      this.icon,
      this.addres_to,
      this.addres_do,
      this.status,
      this.UID});

  factory CheckData.fromJson(Map<String, dynamic> jsonData) {
    print(jsonData['АдресAФорм'].toString());
    return CheckData(
      name: 'Заказ №' +
          jsonData['Номер'].toString(),
      sum: jsonData['Сумма'].toString(),
      addres_to: jsonData['АдресAФорм'].toString(),
      addres_do: jsonData['АдресBФорм'].toString(),
      icon: getIcon(jsonData['Статус'].toString()),
      status: jsonData['Статус'].toString(),
      UID: jsonData['Ссылка_Key'].toString(),
      datetime: jsonData['ДатаВремяДоставки'].toString(),
    );
  }
}


getIcon(String status) {
  Icon return_icon;
  if (status == 'Открыт') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Отменен') {
    return_icon = new Icon(Icons.error, color: Colors.red);
  } else if (status == 'В работе') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Закрыт') {
    return_icon = new Icon(Icons.check, color: Colors.green);
  } else {
    return_icon = new Icon(Icons.error, color: Colors.red);
  }
  return return_icon;
}

//Исполняемые классы
class DeliveryPage extends StatefulWidget {
  @override
  DeliveryPageState createState() {
    return new DeliveryPageState();
  }
}

class DeliveryPageState extends State<DeliveryPage> {
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
      final jsonEndpoint = '${ServerUrl}/hs/mobilecheckcheck/addrecordqr?selection_value=${this.sharedValue}&last_index=${this.check_data.length}&list_view=0';
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
    final jsonEndpoint = '${ServerUrl}/hs/mobilecheckcheck/addrecordqr?selection_value=${sharedValue}&list_view=1';
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
        2,
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
                check_data.addres_to,
                style: new TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ),
            onTap: () {
              if (!list_lock) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ManualEditDeliveryPage(check_data, turnOnUpdate)));
              }
            })
      ]),
    );
  }
}
