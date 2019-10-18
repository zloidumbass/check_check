import 'dart:async';
import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:check_check/module_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:check_check/forms/manual_input_sd.dart';

class SDData {
  final String workorderid,
      status,
      subject,
      short_description,
      technician_email,
      technician_name;
  final Icon icon;

  SDData(
      {this.workorderid,
      this.icon,
      this.subject,
      this.status,
      this.short_description,
      this.technician_email,
      this.technician_name});

  factory SDData.fromJson(Map<String, dynamic> jsonData) {
    return SDData(
        workorderid: jsonData['id'].toString(),
        subject: jsonData['subject'].toString(),
        status: jsonData['status']['name'].toString(),
        icon: getIcon(jsonData['status']['name'].toString()),
        short_description: jsonData['short_description'].toString(),
        technician_email: jsonData['technician']['email_id'].toString(),
        technician_name: jsonData['technician']['name'].toString());
  }
}

class SDListData {
  final String name, description;

  SDListData({this.name, this.description});

  factory SDListData.fromJson(Map<String, dynamic> jsonData) {
    return SDListData(
      name: jsonData['FROM'].toString(),
      description: jsonData['DESCRIPTION'].toString(),
    );
  }
}

getIcon(String status) {
  Icon return_icon;
  if (status == 'Открыт') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Приостановлен') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'В работе') {
    return_icon = new Icon(Icons.access_time, color: Colors.amber);
  } else if (status == 'Закрыт') {
    return_icon = new Icon(Icons.done, color: Colors.green);
  } else {
    return_icon = new Icon(Icons.error, color: Colors.red);
  }
  return return_icon;
}

class SecondScreen extends StatefulWidget {
  final SDData value;

  SecondScreen({Key key, this.value}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final controller_text = TextEditingController();
  List<SDListData> sdlist_data;

  //Future is n object representing a delayed computation.
  Future<List<SDListData>> downloadSDListData() async {
    final jsonEndpoint =
        '${ServerSDURL}/sdpapi/request/${widget.value.workorderid}/allconversation?format=json&OPERATION_NAME=GET_ALL_CONVERSATIONS&TECHNICIAN_KEY=${SDTechnicianKey}';
    try {
      final response = await http.get(jsonEndpoint);

      if (response.statusCode == 200) {
        List sdlist_data = json.decode(response.body)['operation']['details'];
        if (sdlist_data != null && sdlist_data.length != 0) {
          return sdlist_data
              .map((sdlist_data) => new SDListData.fromJson(sdlist_data))
              .toList();
        } else
          return List<SDListData>();
      } else
        print(response.statusCode.toString());
        return List<SDListData>();
    } catch (error) {
      print(error.toString());
      return List<SDListData>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Детали')),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            child: new ListView(
              children: <Widget>[
                new Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.only(
                          bottom: 0, top: 10, right: 0, left: 0),
                      child: Text('№ заявки: ${widget.value.workorderid}',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.left),
                    ))),
//
                Column(children: <Widget>[
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 0, top: 10, right: 0, left: 0),
                        child: Text('Тема',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.subject,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left),
                      ))
                ]),

                Column(children: <Widget>[
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 0, top: 10, right: 0, left: 0),
                        child: Text('Описание',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.short_description,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left),
                      ))
                ]),

                new Center(
                  child: new FutureBuilder<List<SDListData>>(
                    future: this.downloadSDListData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        sdlist_data = snapshot.data;
                        return new Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height - 500,
                          child: ListView.builder(
                            itemCount: sdlist_data.length,
                            itemBuilder: (context, int currentIndex) =>
                                sdlist_data[currentIndex].name == 'System'
                                    ? new Container()
                                    : new Column(children: <Widget>[
                                        new Divider(
                                          height: 10.0,
                                        ),
                                        this.CustomListViewTile1(
                                            sdlist_data[currentIndex])
                                      ]),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return new ListView(
                          children: <Widget>[
                            new Container(
                              child: Text('${snapshot.error}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 1.5,
                              alignment: FractionalOffset.center,
                            )
                          ],
                        );
                      }
                      return new CircularProgressIndicator();
                    },
                  ),
                ),

                new TextFormField(
                  controller: controller_text,
                  maxLines: null,
                  maxLength: 1000,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(labelText: 'Комментарий'),
                ),

                new Container(
                  decoration: new BoxDecoration(
                      border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    title: new Text(
                      "Отправить",
                      textAlign: TextAlign.center,
                    ),
                    onTap: this.submit,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );
  }

  _validateRequiredField(String value, String Field) {
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

  submit() async {
    String imageBase64 = "";

    //Обработки проверки заполнения форм
    if (_validateRequiredField(controller_text.text, 'Комментарий')) {
      return;
    }
    ;

    //Методы отправки
    LoadingStart(context);

    try {
      String JsonEndpoint = '${ServerSDURL}/sdpapi/request/${widget.value.workorderid}?OPERATION_NAME=REPLY_REQUEST&TECHNICIAN_KEY=${SDTechnicianKey}&INPUT_DATA=<Details><parameter><name>to</name><value>${widget.value.technician_email}</value></parameter><parameter><name>subject</name><value>${widget.value.subject}</value></parameter><parameter><name>description</name><value>${controller_text.text}</value></parameter></Details>';
      var response = await http.post(JsonEndpoint);

      if (response.statusCode == 200) {
        LoadingStop(context);
        Navigator.pop(context);
        print(JsonEndpoint);
      } else {
        LoadingStop(context);
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
            'Ошибка соединения с сервером',
            style: new TextStyle(fontSize: 16.0),
          ));
    }
    ;
  }

  CustomListViewTile1(SDListData sdlist_data) {
    // переменная, обозначающая автора сообщения (пользователь приложения или специалист техподдержки)
    String name_from;

    if (sdlist_data.name == SDUserName) {
      name_from = User;
    } else {
      name_from = sdlist_data.name;
    }

    return new Card(
      child: new Column(children: <Widget>[
        new ListTile(
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                name_from,
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: new Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: new Html(
              data: sdlist_data.description,
            ),
          ),
        )
      ]),
    );
  }
}

class SDPage extends StatefulWidget {
  @override
  SDPageState createState() {
    return new SDPageState();
  }
}

class SDPageState extends State<SDPage> {
  List<SDData> sd_data;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  bool list_lock = false;
  ScrollController _scrollController = new ScrollController();

  void _getMoreData() async {
    if (!list_lock) {
      setState(() {
        list_lock = true;
      });
      final jsonEndpoint =
          '${ServerSDURL}/api/v3/requests?format=json&input_data=%7B"list_info"%3A%7B"row_count"%3A20%2C"start_index"%3A${sd_data.length}%2C"sort_field"%3A"id"%2C"sort_order"%3A"desc"%2C"get_total_count"%3Atrue%2C"search_fields"%3A%7B"requester.name"%3A"${UserUID}"%7D%7D%7D&TECHNICIAN_KEY=${SDTechnicianKey}';
      try {
        final response = await http.get(jsonEndpoint);
        if (response.statusCode == 200) {
          List sd_data = json.decode(response.body);
          List<SDData> tempList = List<SDData>();
          for (var sd_element in sd_data.map((sd_data) => new SDData.fromJson(sd_data)).toList()) {
            tempList.add(sd_element);
          }
          setState(() {
            list_lock = false;
            this.sd_data.addAll(tempList);
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
    sd_data = await this.downloadSDData();
    setState(() {});

    return null;
  }

  //Future is n object representing a delayed computation.
  Future<List<SDData>> downloadSDData() async {
    list_lock = true;
    final jsonEndpoint =
        '${ServerSDURL}/api/v3/requests?format=json&input_data=%7B"list_info"%3A%7B"row_count"%3A20%2C"sort_field"%3A"id"%2C"sort_order"%3A"desc"%2C"get_total_count"%3Atrue%2C"search_fields"%3A%7B"requester.name"%3A"${UserUID}"%7D%7D%7D&TECHNICIAN_KEY=${SDTechnicianKey}';
    try {
      final response = await http.get(jsonEndpoint);
      if (response.statusCode == 200) {
        list_lock = false;
        List sd_data = json.decode(response.body)['requests'];
        if (sd_data.length != 0) {
          return sd_data
              .map((sd_data) => new SDData.fromJson(sd_data))
              .toList();
        } else
          return List<SDData>();
      } else
        return List<SDData>();
    } catch (error) {
      print(error.toString());
      return List<SDData>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Заявки"),
      ),
      body: new Center(
          child: CreateListForm(sd_data, _refreshIndicatorKey, context, _scrollController, list_lock, CustomListViewTile, refreshList)
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ManualInputPage_SD(turnOnUpdate)));
        },
      ),
    );
  }

  //ЭЛЕМЕНТ СПИСКА
  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  //Элемент списка
  CustomListViewTile(SDData sd_data) {
    return new Card(
      child: new Column(children: <Widget>[
        new ListTile(
            leading: new Container(
              child: sd_data.icon,
            ),
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  sd_data.workorderid,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
                new Text(
                  sd_data.status,
                  style: new TextStyle(color: Colors.grey, fontSize: 13.0),
                ),
              ],
            ),
            subtitle: new Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: new Text(
                sd_data.subject,
                style: new TextStyle(color: Colors.grey, fontSize: 13.0),
              ),
            ),
            onTap: () {
              var route = new MaterialPageRoute(
                builder: (BuildContext context) =>
                    new SecondScreen(value: sd_data),
              );
              Navigator.of(context).push(route);
            })
      ]),
    );
  }
}
