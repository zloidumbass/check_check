import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/forms/manual_input_waybills_add_route.dart';
import 'package:http/http.dart' as http;
import 'package:check_check/module_common.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class WaybillsRouteData {
  String name, date, point_A, point_B, date1, date2, km;
  WaybillsRouteData({
    this.name,
    this.date,
    this.point_A,
    this.point_B,
    this.date1,
    this.date2,
    this.km,
  });
  factory WaybillsRouteData.fromJson(Map<String, dynamic> jsonData) {
    return WaybillsRouteData(
      name: jsonData['point_A'] + ' - ' + jsonData['point_B'],
      date: jsonData['date1'] + ' - ' + jsonData['date2'],
      point_A: jsonData['point_A'],
      point_B: jsonData['point_B'],
      date1: jsonData['date1'],
      date2: jsonData['date2'],
      km: jsonData['km'],
    );
  }
}

//class CustomListViewTile extends StatefulWidget {
//  final WaybillsRouteData waybills_route_data;
//  List waybills_selected_data;
//  CustomListViewTile(this.waybills_selected_data, this.waybills_route_data);
//
//  @override
//  CustomListViewTileState createState() {
//    return new CustomListViewTileState(this.waybills_selected_data, this.waybills_route_data);
//  }
//}
//class CustomListViewTileState extends State<CustomListViewTile> {
//  final WaybillsRouteData waybills_route_data;
//  List waybills_selected_data;
//  CustomListViewTileState(this.waybills_selected_data, this.waybills_route_data);
//
//  var isSelected = false;
//  var mycolor=Colors.white;
//
//  //Цвет элемента
//  myColors(index){
//    var mycolor=Colors.white;
//    if(!waybills_selected_data.contains(waybills_route_data)){
//      mycolor = Colors.white;
//    }else{
//      mycolor = Colors.grey[300];
//    }
//    return mycolor;
//  }
//
//  Widget build(context) {
//    return new Card(
//      color: myColors(index),
//      child: new Column(children: <Widget>[
//        new ListTile(
//          selected: waybills_selected_data.contains(waybills_route_data),
//          title: new Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              new Text(
//                waybills_route_data.name,
//                style: new TextStyle(fontWeight: FontWeight.bold),
//              ),
//              new Text(
//                'КМ: ' + waybills_route_data.km,
//                style: new TextStyle(color: Colors.grey, fontSize: 13.0),
//              ),
//            ],
//          ),
//          subtitle: new Container(
//            padding: const EdgeInsets.only(top: 5.0),
//            child: new Text(
//              waybills_route_data.date,
//              style: new TextStyle(color: Colors.grey, fontSize: 13.0),
//            ),
//          ),
//          onLongPress: (){
//            setState(() {
//              if (waybills_selected_data.contains(waybills_route_data)) {
//                waybills_selected_data.remove(waybills_route_data);
//              } else {
//                waybills_selected_data.add(waybills_route_data);
//              }
//            });
//          },
//          onTap:(){
//            //Navigator.push(context, MaterialPageRoute(builder: (context)=> ManualInputWaybillsAddRoutePage(editRouteToForm, waybills_route, index)));
//          },
//        )]
//      ),
//    );
//  }
//}

//Future is n object representing a delayed computation.
Future<List<WaybillsRouteData>> RouteList(List waybills_route_data) async {
    if (waybills_route_data.length!=0){
      return waybills_route_data
          .map((waybill_data) => new WaybillsRouteData.fromJson(waybill_data))
          .toList();
    }
    else throw 'Добавьте точки маршрута';
}

class ManualInputWaybillsPage extends StatefulWidget {
  List cheks_selected_data;
  double max_amount;
  ManualInputWaybillsPage(this.cheks_selected_data, this.max_amount);
  @override
  ManualInputWaybillsPageState createState() {
    print(max_amount.toString());
    return new ManualInputWaybillsPageState(cheks_selected_data, this.max_amount);
  }
}

class ManualInputWaybillsPageState extends State<ManualInputWaybillsPage> {

  List cheks_selected_data;
  double max_amount;
  ManualInputWaybillsPageState(this.cheks_selected_data, this.max_amount);

  List waybills_route_data = [];
  List waybills_selected_data = [];

  String button1_name = 'Добавить';
  String button2_name = 'Отправить';


  //Добавление элемента
  addRouteToForm(String jsonInline, int index){
    Map<String, dynamic> inline = json.decode(jsonInline);
    waybills_route_data.add(inline);
  }

  //Кнопка Добавить/Удалить
  addRoute(){
    if(waybills_selected_data.length != 0){
      for (var waybills_selected in waybills_selected_data) {
        waybills_route_data.remove(waybills_selected);
      }
      waybills_selected_data.clear();
      selectMode(waybills_selected_data.length != 0);
    } else{
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ManualInputWaybillsAddRoutePage(addRouteToForm, null, 0)));
    }
  }

  //Кнопка Отправить/Очистить все
  nextPage(){
    if(waybills_selected_data.length != 0){
      waybills_selected_data.clear();
      selectMode(waybills_selected_data.length != 0);
    } else{
      var max_km = 0.00;
      for (var waybills_route in waybills_route_data) {
        max_km = max_km + double.parse(waybills_route['km']);
      }
      if(max_amount == 10*max_km/100){
        submit();
      }else {
        CreateshowDialog(context,new Text(
          'Количество литров по чекам: '+max_amount.toString()+', Количество литров по точкам: '+(10*max_km/100).toString(),
          style: new TextStyle(fontSize: 16.0),
        ));
      }
    }
  }

  //Отправка данных
  submit() async{
    print('{"user":"${User}","tab1":${json.encode(waybills_route_data).toString()},"tab2":${cheks_selected_data.toString()}}');

    LoadingStart(context);
    try {
      var response = await http.post('${ServerUrl}/hs/mobilecheckcheck/addwb',
          body: '{"user":"${UserUID}","tab1":${json.encode(waybills_route_data).toString()},"tab2":${cheks_selected_data.toString()}}',
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Basic YXBpOmFwaQ=='
          }
      );
      if (response.statusCode == 200) {
        LoadingStop(context);
        Navigator.pop(context);
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
        error.toString(),
        style: new TextStyle(fontSize: 16.0),
      ));
    };
  }

  //Проверка и обновление формы на статус выбора
  selectMode(bool select_mode){
    setState(() {
      if(select_mode){
        button1_name = 'Удалить помеченные';
        button2_name = 'Очистить все';
      }else{
        button1_name = 'Добавить';
        button2_name = 'Отправить';
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
      title: new Text('Отправка путевого листа'),
    ),
    body: new ListView(
      children: <Widget>[
        new Center(
          child: new FutureBuilder<List<WaybillsRouteData>>(
            future: RouteList(waybills_route_data),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<WaybillsRouteData> check_data = snapshot.data;
                if(check_data.length == waybills_route_data.length){
                  return new Container(
                    height: MediaQuery.of(context).size.height-260,
                    child: ListView.builder(
                      itemCount: check_data.length,
                      itemBuilder: (context, int currentIndex)  => new Column(
                        children: <Widget>[
                          new Divider(
                            height: 10.0,
                          ),
                          CreateCustomListViewTile(check_data[currentIndex], currentIndex)
                        ]
                      ),
                    )
                  );
                }{
                  return Container(alignment: FractionalOffset.center,
                      height: MediaQuery.of(context).size.height-260,
                      child:
                      new CircularProgressIndicator());
                }
              } else if (snapshot.hasError) {
                return Container(alignment: FractionalOffset.center,
                    height: MediaQuery.of(context).size.height-260,
                    child:
                    new Text('${snapshot.error}', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold), textAlign: TextAlign.left,));
              }
              return Container(alignment: FractionalOffset.center,
                  height: MediaQuery.of(context).size.height-260,
                  child:
                  new CircularProgressIndicator());
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
          margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
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
          margin: new EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        ),
      ]
        )
    );
  }

  //ЭЛЕМЕНТ СПИСКА
  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  //Редактирование эелемента
  editRouteToForm(String jsonInline, int index){
    Map<String, dynamic> inline = json.decode(jsonInline);
    waybills_route_data[index] = inline;
  }

  //Цвет элемента
  myColors(index){
      var mycolor=Colors.white;
      if(!waybills_selected_data.contains(waybills_route_data[index])){
        mycolor = Colors.white;
      }else{
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
                waybills_route.name,
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              new Text(
                'КМ: ' + waybills_route.km,
                style: new TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ],
          ),
          subtitle: new Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: new Text(
              waybills_route.date,
              style: new TextStyle(color: Colors.grey, fontSize: 13.0),
            ),
          ),
          onLongPress: (){
              if (waybills_selected_data.contains(waybills_route_data[index])) {
                waybills_selected_data.remove(waybills_route_data.elementAt(index));
              } else {
                waybills_selected_data.add(waybills_route_data.elementAt(index));
              }
              selectMode(waybills_selected_data.length != 0);
          },
          onTap:(){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> ManualInputWaybillsAddRoutePage(editRouteToForm, waybills_route, index)));
          },
        )]
      ),
    );
  }

}
