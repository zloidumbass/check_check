import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/forms/manual_edit_cheks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final int MaxLenghtNom = 14;

class CheckData {
  final String name, status, doc_sum, full_name, date_time, sum, fn, fd, fpd, UID;
  final double amount;
  final List nomenclature;
  final Icon icon;
  CheckData({
    this.name,
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
    this.amount
  });
  factory CheckData.fromJson(Map<String, dynamic> jsonData) {
    return CheckData(
      name: 'Чек от ' + jsonData['ДатаЧека'].toString().substring(6,8) + '.' + jsonData['ДатаЧека'].toString().substring(4,6) + '.' + jsonData['ДатаЧека'].toString().substring(0,4),
      sum: jsonData['Сумма'].toString(),
      doc_sum: jsonData['ДокументСумма'].toString(),
      icon: getIcon(jsonData['Статус'].toString()),
      status: getStatus(jsonData['Статус'].toString()),
      full_name:  jsonData['ФизическоеЛицо'].toString(),
      date_time:  jsonData['ДатаЧека'],
      nomenclature:  jsonData['Номенклатура'],
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
  Nomenclature({
    this.nomenclature,
    this.accepted,
    this.id
  });
  factory Nomenclature.fromJson(Map<String, dynamic> jsonData) {
    return Nomenclature(
      nomenclature:  jsonData['Номенклатура'].toString(),
      accepted:  !jsonData['НеПринимаетсяКУчету'],
      id:  jsonData['НомерСтроки'].toString(),
    );
  }
}

getIcon(String status){

  Icon return_icon;
  if(status == 'Отправлен'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'Не существует'){
    return_icon = new Icon(Icons.error,color: Colors.red);
  }
  else if(status == 'Проверен ФНС'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'Подтверждено ФНС'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'На рассмотрении'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'Требует ввода путевого листа'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'Ожидает проверки путевого листа'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'Готов к оплате'){
    return_icon = new Icon(Icons.access_time,color: Colors.amber);
  }
  else if(status == 'Принят в БУ'){
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
  else if(status == 'Не существует'){
    representation_status = 'Не существует';
  }
  else if(status == 'Проверен ФНС'){
    representation_status = 'Проверен ФНС';
  }
  else if(status == 'Подтверждено ФНС'){
    representation_status = 'Подтверждено ФНС';
  }
  else if(status == 'На рассмотрении'){
    representation_status = 'На рассмотрении';
  }
  else if(status == 'Требует ввода путевого листа'){
    representation_status = 'Ввод путевого';
  }
  else if(status == 'Ожидает проверки путевого листа'){
    representation_status = 'Проверка путевого';
  }
  else if(status == 'Готов к оплате'){
    representation_status = 'Готов к оплате';
  }
  else if(status == 'Принят в БУ'){
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
    final jsonEndpoint = '${ServerUrl}/hs/mobilecheckcheck/addrecordqr';
    try {
      final response = await http.get(jsonEndpoint,headers: {
        'Authorization': 'Basic ${AuthorizationString}'
      });
      if (response.statusCode == 200) {
        List check_data = json.decode(response.body);
        if (check_data.length != 0) {
          return check_data
              .map((check_data) => new CheckData.fromJson(check_data))
              .toList();
        }
        else
          throw 'Список пуст';
      } else
        print(response.body);
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
              'Сумма: ' + check_data.doc_sum,
              style: new TextStyle(color: Colors.grey, fontSize: 13.0),
            ),
          ),
          onTap: () {
            var route = new MaterialPageRoute(
              builder: (BuildContext context) =>
              new ManualEditPage(value: check_data),
            );

            Navigator.of(context).push(route);
          }
        )
      ]),
    );
  }
}
