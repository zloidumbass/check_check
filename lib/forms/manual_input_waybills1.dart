import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/forms/manual_input_waybills2.dart';
import 'package:check_check/module_common.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class CheckData {
  final String name, status, sum, UID;
  final double amount;
  final Icon icon;
  CheckData({
    this.name,
    this.icon,
    this.sum,
    this.status,
    this.UID,
    this.amount
  });
  factory CheckData.fromJson(Map<String, dynamic> jsonData) {
    return CheckData(
      name: 'Чек от ' + jsonData['ДатаЧека'].toString().substring(6,8) + '.' + jsonData['ДатаЧека'].toString().substring(4,6) + '.' + jsonData['ДатаЧека'].toString().substring(0,4),
      sum: jsonData['ДокументСумма'].toString(),
      amount: jsonData['ДокументКоличество'],
      icon: getIcon(jsonData['Статус']),
      status: getStatus(jsonData['Статус']),
      UID: jsonData['СсылкаНаДокумент_Key'].toString(),
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

class CustomListViewTile extends StatefulWidget {
  final CheckData check_data;
  List cheks_selected_data;
  CustomListViewTile(this.check_data, this.cheks_selected_data);

  @override
  CustomListViewTileState createState() {
    return new CustomListViewTileState(this.check_data, this.cheks_selected_data);
  }
}
class CustomListViewTileState extends State<CustomListViewTile> {
  final CheckData check_data;
  List cheks_selected_data;
  CustomListViewTileState(this.check_data, this.cheks_selected_data);

  var isSelected = false;
  var mycolor=Colors.white;

  selectedCard(){
    setState(() {
      if (isSelected) {
        mycolor=Colors.white;
        isSelected = false;
        cheks_selected_data.remove(check_data);
        //cheks_selected_data.remove('{"key" : "${check_data.UID}"}');
      } else {
        mycolor=Colors.grey[300];
        isSelected = true;
        cheks_selected_data.add(check_data);
        //cheks_selected_data.add('{"key" : "${check_data.UID}"}');
        //print(max_amount.toString());
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
          onLongPress: (){
            selectedCard();
          },
          onTap: () {
            var route = new MaterialPageRoute(
              builder: (BuildContext context) =>
              new SecondScreen(value: check_data),
            );
            Navigator.of(context).push(route);
          }
        )]
      ),
    );
  }
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
      body: new Container(
        child: new Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: new Text(
                  'Детали чека',
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
            ],   ),
        ),
      ),
    );
  }
}

class ManualInputWaybillsPage2 extends StatefulWidget {
  @override
  ManualInputWaybillsPage2State createState() {
    return new ManualInputWaybillsPage2State();
  }
}


class ManualInputWaybillsPage2State extends State<ManualInputWaybillsPage2> {
  List<CheckData> check_selected_data = [];
  List<CheckData> check_data = [];

  //Кнопка Далее/Очистить все
  nextPage(){
    if (check_selected_data.length == 0){
      CreateshowDialog(context,new Text(
        'Не выбрано ни одного чека!',
        style: new TextStyle(fontSize: 16.0),
      ));
      return;
    }

    List sending_check_data = [];
    //sending_check_data.add('1');
    var max_amount = 0.00;
    for (var check_selected in check_selected_data) {
      max_amount += check_selected.amount;
      sending_check_data.add('{"key" : "${check_selected.UID}"}');
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ManualInputWaybillsPage(sending_check_data, max_amount)));
  }

  //Future is n object representing a delayed computation.
  Future<List<CheckData>> downloadCheckData() async {
    final jsonEndpoint = '${ServerUrl}/odata/standard.odata/InformationRegister_ДанныеQRкодов?%24format=json&%24filter=Пользователь%20eq%20guid%27${UserUID}%27%20and%20Статус%20eq%20%27ТребуетВводаПутевогоЛиста%27';
    try{
      final response = await http.get(jsonEndpoint,headers: {
        'Authorization': 'Basic YXBpOmFwaQ=='
      });
      if (response.statusCode == 200) {
        List check_data = json.decode(response.body)['value'];
        if (check_data.length!=0){
          return check_data
              .map((waybill_data) => new CheckData.fromJson(waybill_data))
              .toList();
        }
        else throw 'Список пуст';
      } else throw 'Не удалось загрузить список';
    }catch(error){
      throw error.toString();
    }
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
          child: new FutureBuilder<List<CheckData>>(
            future: this.downloadCheckData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                check_data = snapshot.data;
                return new Container(
                  height: MediaQuery.of(context).size.height-160,
                  child: ListView.builder(
                    itemCount: check_data.length,
                    itemBuilder: (context, int currentIndex)  => new Column(
                      children: <Widget>[
                        new Divider(
                          height: 10.0,
                        ),
                        CustomListViewTile(check_data[currentIndex], check_selected_data)
                      ]
                    ),
                  )
                );
              } else if (snapshot.hasError) {
                return Padding(padding: EdgeInsets.fromLTRB(10, (MediaQuery.of(context).size.height-180)/2, 10, (MediaQuery.of(context).size.height-180)/2), child: Text('${snapshot.error}', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold), textAlign: TextAlign.left,),);
              }
              return Container(alignment: FractionalOffset.center,
                  height: MediaQuery.of(context).size.height-160,
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
              "Далее",
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
}
