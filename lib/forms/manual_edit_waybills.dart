import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:check_check/forms/manual_input_waybills_add_route.dart';
import 'package:check_check/forms/waybills.dart';
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
    return new CustomListViewTileState(
        this.check_data, this.cheks_selected_data);
  }
}

class CustomListViewTileState extends State<CustomListViewTile> {
  final CheckData check_data;
  List cheks_selected_data;

  CustomListViewTileState(this.check_data, this.cheks_selected_data);

  bool isSelected;
  Color mycolor;

  @override
  void initState() {
    isSelected = check_data.check_select;
    updateSelectedCard();
  }

  updateSelectedCard() {
    if (isSelected) {
      mycolor = Colors.grey[300];
      cheks_selected_data.add(check_data);
    } else {
      mycolor = Colors.white;
      cheks_selected_data.remove(check_data);
    }
  }

  selectedCard() {
    setState(() {
      if (isSelected) {
        isSelected = false;
      } else {
        isSelected = true;
      }
      updateSelectedCard();
    });
  }

  Widget build(context) {
    return new Card(
      color: mycolor,
      child: new Column(children: <Widget>[
        new ListTile(
            selected: isSelected,
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
              selectedCard();
            })
      ]),
    );
  }
}

class ManualEditWaybillsStep1 extends StatefulWidget {
  final WaybillData value;
  Function callback;

  ManualEditWaybillsStep1(this.value, this.callback);

  @override
  ManualEditWaybillsStep1State createState() => ManualEditWaybillsStep1State();
}

class ManualEditWaybillsStep1State extends State<ManualEditWaybillsStep1> {
  List<CheckData> check_selected_data = [];
  List<CheckData> check_data = [];

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
    print(max_amount);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ManualEditWaybillsStep2(widget.value,
                sending_check_data, max_amount, widget.callback)));
  }

  //Future is n object representing a delayed computation.
  Future<List<CheckData>> downloadCheckData() async {
    final jsonEndpoint =
        '${ServerUrl}/hs/mobilecheckcheck/addrecordqr?status=ТребуетВводаПутевогоЛиста&waybills=${widget.value.id}';
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
          throw 'Список пуст';
      } else
        throw 'Не удалось загрузить список';
    } catch (error) {
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Редактирование путевого листа'),
        ),
        body: new ListView(children: <Widget>[
          new Center(
            child: new FutureBuilder<List<CheckData>>(
              future: this.downloadCheckData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  check_data = snapshot.data;
                  return new Container(
                      height: MediaQuery.of(context).size.height - 160,
                      child: ListView.builder(
                        itemCount: check_data.length,
                        itemBuilder: (context, int currentIndex) =>
                            new Column(children: <Widget>[
                              new Divider(
                                height: 10.0,
                              ),
                              CustomListViewTile(
                                  check_data[currentIndex], check_selected_data)
                            ]),
                      ));
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                        10,
                        (MediaQuery.of(context).size.height - 180) / 2,
                        10,
                        (MediaQuery.of(context).size.height - 180) / 2),
                    child: Text(
                      '${snapshot.error}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  );
                }
                return Container(
                    alignment: FractionalOffset.center,
                    height: MediaQuery.of(context).size.height - 160,
                    child: new CircularProgressIndicator());
              },
            ),
          ),
          new Container(
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
          ),
        ]));
  }
}

class ManualEditWaybillsStep2 extends StatefulWidget {
  final WaybillData value;
  List cheks_selected_data;
  double max_amount;
  Function callback;

  ManualEditWaybillsStep2(
      this.value, this.cheks_selected_data, this.max_amount, this.callback);

  @override
  ManualEditWaybillsStep2State createState() {
    return new ManualEditWaybillsStep2State();
  }
}

class ManualEditWaybillsStep2State extends State<ManualEditWaybillsStep2> {
  List waybills_route_data = [];
  List waybills_selected_data = [];

  String button1_name = 'Добавить';
  String button2_name = 'Отправить';

  @override
  void initState() {
    waybills_route_data = widget.value.waybills_route_data;
  }

  //Future is n object representing a delayed computation.
  Future<List<WaybillsRouteData>> RouteList() async {
    if (waybills_route_data.length != 0) {
      return waybills_route_data
          .map((waybills_route_data) =>
              new WaybillsRouteData.fromJson(waybills_route_data))
          .toList();
    } else
      throw 'Добавьте точки маршрута';
  }

  //Добавление элемента
  addRouteToForm(String jsonInline, int index) {
    Map<String, dynamic> inline = json.decode(jsonInline);
    waybills_route_data.add(inline);
  }

  //Кнопка Добавить/Удалить
  addRoute() {
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
  nextPage() {
    if (waybills_selected_data.length != 0) {
      waybills_selected_data.clear();
      selectMode(waybills_selected_data.length != 0);
    } else {
      var max_km = 0.00;
      for (var waybills_route in waybills_route_data) {
        max_km = max_km + waybills_route['ПройденныйКилометраж'];
        max_km = double.parse(max_km.toStringAsFixed(3));
        waybills_route['ДатаВыезда'] =
            waybills_route['ДатаВыезда'].substring(0, 10);
        waybills_route['ДатаВозвращения'] =
            waybills_route['ДатаВозвращения'].substring(0, 10);
      }
      if (widget.max_amount == 10 * max_km / 100) {
        submit();
      } else {
        print(widget.max_amount);
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
              '{"type":"edit","waybills":"${widget.value.id}","user":"${UserUID}","tab1":${json.encode(waybills_route_data).toString()},"tab2":${widget.cheks_selected_data.toString()}}',
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
          title: new Text('Редактирование путевого листа'),
        ),
        body: new ListView(children: <Widget>[
          new Center(
            child: new FutureBuilder<List<WaybillsRouteData>>(
              future: this.RouteList(),
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
              onTap: this.addRoute,
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
              onTap: this.nextPage,
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
