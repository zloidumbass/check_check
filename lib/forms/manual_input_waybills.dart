import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:check_check/forms/waybills.dart';
import 'package:check_check/forms/manual_input_waybills_add_route.dart';
import 'package:check_check/module_common.dart';
import 'package:check_check/forms/checks.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomListViewTile extends StatefulWidget {
  final CheckData check_data;
  List cheks_selected_data;

  CustomListViewTile(this.check_data, this.cheks_selected_data);

  @override
  CustomListViewTileState createState() {
    return new CustomListViewTileState();
  }
}

class CustomListViewTileState extends State<CustomListViewTile> {

  bool isSelected = false;
  Color mycolor = Colors.white;

  @override
  void initState() {
    super.initState();
    isSelected = widget.cheks_selected_data.contains(widget.check_data);
    if (widget.cheks_selected_data.contains(widget.check_data)) {
      mycolor = Colors.grey[300];
      isSelected = true;
    } else {
      mycolor = Colors.white;
      isSelected = false;
    }
  }

  selectedCard() {
    setState(() {
      if (isSelected) {
        mycolor = Colors.white;
        isSelected = false;
        widget.cheks_selected_data.remove(widget.check_data);
      } else {
        mycolor = Colors.grey[300];
        isSelected = true;
        widget.cheks_selected_data.add(widget.check_data);
      }
    });
  }

  Widget build(context) {
    return new Card(
      color: mycolor,
      child: new Column(children: <Widget>[
        new ListTile(
            selected: isSelected,
            leading: new Container(
              child: widget.check_data.icon,
            ),
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  widget.check_data.name,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                new Text(
                  widget.check_data.status,
                  style: new TextStyle(color: Colors.grey, fontSize: 13.0),
                ),
              ],
            ),
            subtitle: new Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: new Text(
                'Сумма: ' + widget.check_data.doc_sum,
                style: new TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ),
            onTap: () {
              selectedCard();
            })
      ]),
    );
  }
}

class ManualInputWaybillsStep1 extends StatefulWidget {
  Function callback;

  ManualInputWaybillsStep1(this.callback);

  @override
  ManualInputWaybillsStep1State createState() {
    return new ManualInputWaybillsStep1State();
  }
}

class ManualInputWaybillsStep1State extends State<ManualInputWaybillsStep1> {
  List<CheckData> check_selected_data = [];
  List<CheckData> check_data;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  //Кнопка Далее/Очистить все
  nextPage() {
    if (check_selected_data.length == 0) {
      CreateshowDialog(
          context,
          new Text(
            'Не выбрано ни одного чека!',
            style: new TextStyle(fontSize: 16.0),
          ));
      return;
    }

    List sending_check_data = [];
    var max_amount = 0.00;
    for (var check_selected in check_selected_data) {
      max_amount += check_selected.amount;
      max_amount = double.parse(max_amount.toStringAsFixed(3));
      sending_check_data.add('{"key" : "${check_selected.UID}"}');
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ManualInputWaybillsPage(
                sending_check_data, max_amount, widget.callback)));
  }

  //Future is n object representing a delayed computation.
  Future<List<CheckData>> downloadCheckData() async {
    final jsonEndpoint =
        '${ServerUrl}/hs/mobilecheckcheck/addrecordqr?status=ТребуетВводаПутевогоЛиста';
    try {
      final response = await http.get(jsonEndpoint,
          headers: {'Authorization': 'Basic ${AuthorizationString}'});
      if (response.statusCode == 200) {
        List check_data = json.decode(response.body);
        if (check_data.length != 0) {
          return check_data
              .map((waybill_data) => new CheckData.fromJson(waybill_data))
              .toList();
        } else
          return List<CheckData>();
      } else
        print(response.body);
      return List<CheckData>();
    } catch (error) {
      return List<CheckData>();
    }
  }

  Future<Null> refreshList() async {
    this._refreshIndicatorKey.currentState?.show(atTop: true);
    check_data = await this.downloadCheckData();
    setState(() {});

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Отправка путевого листа'),
        ),
        body: new Center(
            child: new Column(
          children: <Widget>[
            Expanded(
                child: getBody()),
            new SizedBox(
                width: MediaQuery.of(context).size.width,
                child: new Container(
              decoration:
                  new BoxDecoration(border: Border.all(color: Colors.black)),
              child: new ListTile(
                title: new Text(
                  "Далее",
                  textAlign: TextAlign.center,
                ),
                onTap: this.nextPage,
              ),
              margin:
                  new EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            )),
          ],
        )));
  }

  Widget getBody() {
    if (check_data == null) {
      return new Center(child: new CircularProgressIndicator());
    } else if (check_data.length == 0) {
      return new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: this.refreshList,
          child: new ListView(children: <Widget>[
            new Container(
              child: Text('Список пуст'),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              alignment: FractionalOffset.center,
            )
          ]));
    } else {
      return new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: this.refreshList,
          child: ListView.builder(
            itemCount: check_data.length,
            itemBuilder: (context, int currentIndex) =>
                new Column(children: <Widget>[
              new Divider(
                height: 10.0,
              ),
              CustomListViewTile(check_data[currentIndex], check_selected_data)
            ]),
          ));
    }
  }
}

//Future is n object representing a delayed computation.
Future<List<WaybillsRouteData>> RouteList(List waybills_route_data) async {
  if (waybills_route_data.length != 0) {
    return waybills_route_data
        .map((waybill_data) => new WaybillsRouteData.fromJson(waybill_data))
        .toList();
  } else
    throw 'Добавьте точки маршрута';
}

class ManualInputWaybillsPage extends StatefulWidget {
  List cheks_selected_data;
  double max_amount;
  Function callback;

  ManualInputWaybillsPage(
      this.cheks_selected_data, this.max_amount, this.callback);

  @override
  ManualInputWaybillsPageState createState() {
    return new ManualInputWaybillsPageState();
  }
}

class ManualInputWaybillsPageState extends State<ManualInputWaybillsPage> {
  List waybills_route_data = [];
  List waybills_selected_data = [];

  //Дефолтные имена кнопок
  String button1_name = 'Добавить';
  String button2_name = 'Отправить';

  //Добавление элемента
  addRouteToForm(String jsonInline, int index) {
    Map<String, dynamic> inline = json.decode(jsonInline);
    waybills_route_data.add(inline);
  }

  //Кнопка Добавить/Удалить
  addOrRemoveRoute() {
    if (waybills_selected_data.length != 0) {
      for (var waybills_selected in waybills_selected_data) {
        waybills_route_data.remove(waybills_selected);
      }
      waybills_selected_data.clear();
      selectMode(waybills_selected_data.length != 0);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ManualInputWaybillsAddRoutePage(addRouteToForm, null, 0)));
    }
  }

  //Кнопка Отправить/Очистить все
  sendOrClear() {
    if (waybills_selected_data.length != 0) {
      waybills_selected_data.clear();
      selectMode(waybills_selected_data.length != 0);
    } else {
      var max_km = 0.00;
      for (var waybills_route in waybills_route_data) {
        max_km += waybills_route['ПройденныйКилометраж'];
        max_km = double.parse(max_km.toStringAsFixed(2));
      };
      if (widget.max_amount == 10 * max_km / 100) {
        submit();
      } else {
        CreateshowDialog(
            context,
            new Text(
              'Количество литров по чекам: ' +
                  widget.max_amount.toString() +
                  ', Количество литров по точкам: ' +
                  (10 * max_km / 100).toString(),
              style: new TextStyle(fontSize: 16.0),
            ));
      }
    }
  }

  //Отправка данных
  submit() async {
    LoadingStart(context);
    try {
      var response = await http.post('${ServerUrl}/hs/mobilecheckcheck/addwb',
          body:
              '{"type":"add","user":"${UserUID}","tab1":${json.encode(waybills_route_data).toString()},"tab2":${widget.cheks_selected_data.toString()}}',
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Basic ${AuthorizationString}'
          });
      if (response.statusCode == 200) {
        LoadingStop(context);
        Navigator.pop(context);
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
            error.toString(),
            style: new TextStyle(fontSize: 16.0),
          ));
    }
    ;
  }

  //Проверка и обновление формы на статус выбора
  selectMode(bool select_mode) {
    setState(() {
      if (select_mode) {
        button1_name = 'Удалить помеченные';
        button2_name = 'Очистить все';
      } else {
        button1_name = 'Добавить';
        button2_name = 'Отправить';
      }
      ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Отправка путевого листа'),
        ),
        body: new ListView(children: <Widget>[
          new Center(
            child: new FutureBuilder<List<WaybillsRouteData>>(
              future: RouteList(waybills_route_data),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<WaybillsRouteData> check_data = snapshot.data;
                  if (check_data.length == waybills_route_data.length) {
                    return new Container(
                        height: MediaQuery.of(context).size.height - 260,
                        child: ListView.builder(
                          itemCount: check_data.length,
                          itemBuilder: (context, int currentIndex) =>
                              new Column(children: <Widget>[
                            new Divider(
                              height: 10.0,
                            ),
                            CreateCustomListViewTile(
                                check_data[currentIndex], currentIndex)
                          ]),
                        ));
                  }
                  {
                    return Container(
                        alignment: FractionalOffset.center,
                        height: MediaQuery.of(context).size.height - 260,
                        child: new CircularProgressIndicator());
                  }
                } else if (snapshot.hasError) {
                  return Container(
                      alignment: FractionalOffset.center,
                      height: MediaQuery.of(context).size.height - 260,
                      child: new Text(
                        '${snapshot.error}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ));
                }
                return Container(
                    alignment: FractionalOffset.center,
                    height: MediaQuery.of(context).size.height - 260,
                    child: new CircularProgressIndicator());
              },
            ),
          ),
          new Container(
            decoration:
                new BoxDecoration(border: Border.all(color: Colors.black)),
            child: new ListTile(
              title: new Text(
                button1_name,
                textAlign: TextAlign.center,
              ),
              onTap: this.addOrRemoveRoute,
            ),
            margin:
                new EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
          ),
          new Container(
            decoration:
                new BoxDecoration(border: Border.all(color: Colors.black)),
            child: new ListTile(
              title: new Text(
                button2_name,
                textAlign: TextAlign.center,
              ),
              onTap: this.sendOrClear,
            ),
            margin:
                new EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
          ),
        ]));
  }

  //ЭЛЕМЕНТ СПИСКА
  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  //Редактирование эелемента
  editRouteToForm(String jsonInline, int index) {
    Map<String, dynamic> inline = json.decode(jsonInline);
    waybills_route_data[index] = inline;
  }

  //Цвет элемента
  myColors(index) {
    var mycolor = Colors.white;
    if (!waybills_selected_data.contains(waybills_route_data[index])) {
      mycolor = Colors.white;
    } else {
      mycolor = Colors.grey[300];
    }
    return mycolor;
  }

  //Элемент списка
  CreateCustomListViewTile(WaybillsRouteData waybills_route, int index) {
    return new Card(
      color: myColors(index),
      child: new Column(children: <Widget>[
        new ListTile(
          selected: waybills_selected_data.contains(waybills_route_data[index]),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                waybills_route.point_A + " - " + waybills_route.point_B,
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              new Text(
                'КМ: ' + waybills_route.km.toString(),
                style: new TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ],
          ),
          subtitle: new Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: new Text(
              waybills_route.date1 + " - " + waybills_route.date2,
              style: new TextStyle(color: Colors.grey, fontSize: 13.0),
            ),
          ),
          onLongPress: () {
            if (waybills_selected_data.contains(waybills_route_data[index])) {
              waybills_selected_data
                  .remove(waybills_route_data.elementAt(index));
            } else {
              waybills_selected_data.add(waybills_route_data.elementAt(index));
            }
            selectMode(waybills_selected_data.length != 0);
          },
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ManualInputWaybillsAddRoutePage(
                        editRouteToForm, waybills_route, index)));
          },
        )
      ]),
    );
  }
}
