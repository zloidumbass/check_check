import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';

class CheckData {
  final String name, status, sum, json_check_data;
  final Icon icon;
  CheckData({
    this.name,
    this.icon,
    this.sum,
    this.status,
    this.json_check_data
  });
  factory CheckData.fromJson(Map<String, dynamic> jsonData) {
    return CheckData(
      name: 'Чек от ' + jsonData['ДатаЧека'].toString().substring(6,8) + '.' + jsonData['ДатаЧека'].toString().substring(4,6) + '.' + jsonData['ДатаЧека'].toString().substring(0,4),
      sum: jsonData['ДокументСумма'].toString(),
      icon: getIcon(jsonData['Статус']),
      status: getStatus(jsonData['Статус']),
      json_check_data:  jsonData['ОтветИзФНС'].toString(),
    );
  }
}

getIcon(String status){

  Icon return_icon;
  if(status == 'Отправлен'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'НеСуществует'){
    return_icon = new Icon(Icons.error,color: Colors.red);
  }
  else if(status == 'ПроверенФНС'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'ПодтвержденоФНС'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'НаРассмотрении'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'ТребуетВводаПутевогоЛиста'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'ОжидаетПроверкиПутевогоЛиста'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'ГотовКОплате'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'ПринятВБУ'){
    return_icon = new Icon(Icons.check,color: Colors.green);
  }
  else if(status == 'Отказ'){
    return_icon = new Icon(Icons.error,color: Colors.red);
  }
  else {
    return_icon = new Icon(Icons.error,color: Colors.red);
  }
  return return_icon;
}

getStatus(String status){
  String representation_status;
  if(status == 'Отправлен'){
    representation_status = 'Отправлен';
  }
  else if(status == 'НеСуществует'){
    representation_status = 'Не существует';
  }
  else if(status == 'ПроверенФНС'){
    representation_status = 'Проверен ФНС';
  }
  else if(status == 'ПодтвержденоФНС'){
    representation_status = 'Подтверждено ФНС';
  }
  else if(status == 'НаРассмотрении'){
    representation_status = 'На рассмотрении';
  }
  else if(status == 'ТребуетВводаПутевогоЛиста'){
    representation_status = 'Ввод путевого';
  }
  else if(status == 'ОжидаетПроверкиПутевогоЛиста'){
    representation_status = 'Проверка путевого';
  }
  else if(status == 'ГотовКОплате'){
    representation_status = 'Готов к оплате';
  }
  else if(status == 'ПринятВБУ'){
    representation_status = 'Принят в БУ';
  }
  else if(status == 'Отказ'){
    representation_status = 'Отказ';
  }
  else {
    representation_status = 'Неизвестно';
  }
  return representation_status;
}

class SecondScreen extends StatefulWidget {
  final CheckData value;
  SecondScreen({Key key, this.value}) : super(key: key);
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Детали')),
      body:  new Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: new Text(
                  widget.value.name,
                  style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.only(bottom: 20.0),
              ),
              Padding(
                child: new Text(
                  'Наименование : ${widget.value.name}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'Сумма : ${widget.value.sum}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              ),
              Padding(
                child: new Text(
                  'Статус : ${widget.value.status}',
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                padding: EdgeInsets.all(20.0),
              )
            ],
          ),
        ),
    );
  }
}

class CheckPage extends StatefulWidget {
  @override
  CheckPageState createState() {
    return new CheckPageState();
  }
}

class CheckPageState extends State<CheckPage> {

  List<CheckData> check_data;

  Future<Null> refreshList() async {
    setState(() {
    });
    return null;
  }

  //Future is n object representing a delayed computation.
  Future<List<CheckData>> downloadCheckData() async {
    final jsonEndpoint = '${ServerUrl}/odata/standard.odata/InformationRegister_ДанныеQRкодов?%24format=json&%24filter=Пользователь%20eq%20guid%27${UserUID}%27';
    try {
      final response = await get(jsonEndpoint,headers: {
        'Authorization': 'Basic YXBpOmFwaQ=='
      });
      if (response.statusCode == 200) {
        List check_data = json.decode(response.body)['value'];
        if (check_data.length != 0) {
          return check_data
              .map((check_data) => new CheckData.fromJson(check_data))
              .toList();
        }
        else
          throw 'Список пуст';
      } else
        throw 'Не удалось загрузить список';
    }catch(error){
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new RefreshIndicator(
        onRefresh: this.refreshList,
        child: new FutureBuilder<List<CheckData>>(
        future: this.downloadCheckData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            check_data = snapshot.data;
            return ListView.builder(
              itemCount: check_data.length,
              itemBuilder: (context, int currentIndex)  => new Column(
                  children: <Widget>[
                    new Divider(
                      height: 10.0,
                    ),
                    this.CustomListViewTile(check_data[currentIndex])
                  ]
              ),
            );
          } else if (snapshot.hasError) {
            return new ListView(
              children: <Widget>[
                new Container(
                  child: Text('${snapshot.error}', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/1.5,
                  alignment:  FractionalOffset.center,
                )
              ],
            );
          }
          return new CircularProgressIndicator();
        },
      ),),
    );
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
              'Сумма: ' + check_data.sum,
              style: new TextStyle(color: Colors.grey, fontSize: 13.0),
            ),
          ),
          onTap: () {
            var route = new MaterialPageRoute(
              builder: (BuildContext context) =>
              new SecondScreen(value: check_data),
            );

            Navigator.of(context).push(route);
          }
        )
      ]),
    );
  }
}
