import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';

import '../module_common.dart';
import 'manual_edit_waybills.dart';

class WaybillData {
  final String name, status, sum, id;
  final List checks_waybills, waybills_route_data;
  final Icon icon;

  WaybillData({
    this.name,
    this.id,
    this.icon,
    this.sum,
    this.status,
    this.checks_waybills,
    this.waybills_route_data,
  });

  factory WaybillData.fromJson(Map<String, dynamic> jsonData) {
    return WaybillData(
      id: jsonData['Ссылка_Key'].toString(),
      name: 'ПЛ от ' + jsonData['Дата'].toString().substring(0, 10),
      sum: jsonData['СуммаДокумента'].toString(),
      icon: getIcon(jsonData['Принят'], jsonData['Проведен']),
      status: getStatus(jsonData['Принят'], jsonData['Проведен']),
      checks_waybills: jsonData['ЧекиПутевогоЛиста'],
      waybills_route_data: jsonData['Километраж'],
    );
  }
}

class ChecksWaybills {
  final String check, id;
  bool accepted;

  ChecksWaybills({this.check, this.id});

  factory ChecksWaybills.fromJson(Map<String, dynamic> jsonData) {
    return ChecksWaybills(
        id: jsonData['НомерСтроки'].toString(),
        check: jsonData['Чек_Key'].toString());
  }
}

class WaybillsRouteData {
  String point_A, point_B, date1, date2;
  double km;

  WaybillsRouteData({
    this.point_A,
    this.point_B,
    this.date1,
    this.date2,
    this.km,
  });

  factory WaybillsRouteData.fromJson(Map<String, dynamic> jsonData) {
    return WaybillsRouteData(
      point_A: jsonData['ПунктОтправления'].toString(),
      point_B: jsonData['ПунктНазначения'].toString(),
      date1: jsonData['ДатаВыезда'].toString().substring(0, 10),
      date2: jsonData['ДатаВозвращения'].toString().substring(0, 10),
      km: jsonData['ПройденныйКилометраж'],
    );
  }
}

getIcon(bool status, bool posted) {
  Icon return_icon;
  if (!posted) {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (posted && !status) {
    return_icon = new Icon(Icons.error, color: Colors.red);
  } else if (posted && status) {
    return_icon = new Icon(Icons.check, color: Colors.green);
  } else {
    return_icon = new Icon(Icons.error, color: Colors.red);
  }
  return return_icon;
}

getStatus(bool status, bool posted) {
  String representation_status;
  if (!posted) {
    representation_status = 'Не рассмотрен';
  } else if (posted && !status) {
    representation_status = 'Не принят';
  } else if (posted && status) {
    representation_status = 'Принят';
  } else {
    representation_status = 'Неизвестно';
  }
  return representation_status;
}

class WaybillsPage extends StatefulWidget {
  @override
  WaybillsPageState createState() {
    return new WaybillsPageState();
  }
}

class WaybillsPageState extends State<WaybillsPage> {
  List<WaybillData> waybill_data = List<WaybillData>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  bool list_lock = false;

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  turnOnUpdate() {
    refreshList();
  }

  Future<Null> refreshList() async {
    this._refreshIndicatorKey.currentState?.show(atTop: true);
    waybill_data = await this.downloadWaybillData();
    setState(() {});

    return null;
  }

  //Future is n object representing a delayed computation.
  Future<List<WaybillData>> downloadWaybillData() async {
    list_lock = true;
    final jsonEndpoint = '${ServerUrl}/hs/mobilecheckcheck/addwb';
    try {
      final response = await get(jsonEndpoint,
          headers: {'Authorization': 'Basic ${AuthorizationString}'});
      if (response.statusCode == 200) {
        list_lock = false;
        List waybill_data = json.decode(response.body);
        if (waybill_data.length != 0) {
          return waybill_data
              .map((waybill_data) => new WaybillData.fromJson(waybill_data))
              .toList();
        } else
          throw 'Список пуст';
      } else
        throw 'Не удалось загрузить список';
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CreateDefaultMasterForm(2, getBody(), context, turnOnUpdate);
  }

  Widget getBody() {
    if (waybill_data.length != 0) {
      return new Center(
          child: new RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: this.refreshList,
              child: ListView.builder(
                itemCount: waybill_data.length,
                itemBuilder: (context, int currentIndex) =>
                    new Column(children: <Widget>[
                      new Divider(
                        height: 10.0,
                      ),
                      this.CustomListViewTile(waybill_data[currentIndex])
                    ]),
              )));
    } else {
      return new Center(child: new CircularProgressIndicator());
    }
  }

  //ЭЛЕМЕНТ СПИСКА
  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  //Элемент списка
  CustomListViewTile(WaybillData waybill_data) {
    return new Card(
      child: new Column(children: <Widget>[
        new ListTile(
            leading: new Container(
              child: waybill_data.icon,
            ),
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  waybill_data.name,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                new Text(
                  waybill_data.status,
                  style: new TextStyle(color: Colors.grey, fontSize: 13.0),
                ),
              ],
            ),
            subtitle: new Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: new Text(
                'Сумма: ' + waybill_data.sum,
                style: new TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ),
            onTap: () {
              if (waybill_data.status != 'Принят' && EditingAllowed) {
                if (!list_lock) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ManualEditWaybillsStep1(
                                  waybill_data, turnOnUpdate)));
                }
              }else{
                CreateshowDialog(context,new Text(
                  "Редактирование невозможно",
                  style: new TextStyle(fontSize: 16.0),
                ));
              }
            })
      ]),
    );
  }
}
