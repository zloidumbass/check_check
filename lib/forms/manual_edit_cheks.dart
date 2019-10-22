import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:check_check/forms/checks.dart';
import 'package:check_check/module_common.dart';

//Класс инициализации
class ManualEditPage extends StatefulWidget {
  Function callback;
  final CheckData value;

  ManualEditPage(this.value, this.callback);

  @override
  ManualEditPageState createState() => ManualEditPageState();
}

class ManualEditPageState extends State<ManualEditPage> {
  List<Nomenclature> nomenclature;
  bool update = true;
  String text_button_verified;
  var verified;

  @override
  void initState() {
    super.initState();
    if (widget.value.status == 'Ввод путевого') {
      verified = true;
      text_button_verified = 'Отклонить';
    } else if (widget.value.status == 'Подтверждено ФНС') {
      verified = false;
      text_button_verified = 'Принять';
    } else {
      verified = null;
      text_button_verified = 'Недоступно';
    }
    ;
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Процедура сохранения параметров
  saveCheks() async {
    if (verified == null) {
      return;
    }
    ;
    LoadingStart(context);
    try {
      List<String> body_list = new List();
      if (nomenclature != null) {
        for (var nomenclature_element in nomenclature) {
          String ell =
              '{"id":${nomenclature_element.id},"accepted":${nomenclature_element.accepted.toString()}}';
          body_list.add(ell);
        }
      }
      String json_body =
          '{"type":"edit","datetime":"${widget.value.date_time}","s":"${widget.value.sum}","fn":"${widget.value.fn}","fd":"${widget.value.fd}","fpd":"${widget.value.fpd}", "verified":${verified}, "nomenclature":${body_list.toString()}}';
      var response = await http.post(
          '${ServerUrl}/hs/mobilecheckcheck/addrecordqr',
          body: json_body,
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Basic ${AuthorizationString}',
            'content-version': Version+'.'+BuildNumber
          });
      if (response.statusCode == 200) {
        LoadingStop(context);
        Navigator.pop(context);
        widget.callback();
      } else {
        LoadingStop(context);
        CreateshowDialog(
            context,
            new Text(
              response.body,
              style: new TextStyle(fontSize: 16.0),
            ));
        print("Response status: ${response.statusCode}");
      }
    } catch (error) {
      LoadingStop(context);
      LoadingStop(context);
      CreateshowDialog(
          context,
          new Text(
            error.toString(),
            style: new TextStyle(fontSize: 16.0),
          ));
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('ДЕТАЛИ')),
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
                      child: Text(widget.value.name,
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.left),
                    ))),
                Column(children: <Widget>[
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 0, top: 10, right: 0, left: 0),
                        child: Text('ФИО',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.full_name,
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
                        child: Text('Номенклатура',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: CreateTable(),
                      ))
                ]),
                Column(children: <Widget>[
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 0, top: 10, right: 0, left: 0),
                        child: Text('Сумма',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.doc_sum,
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
                        child: Text('Статус',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.status,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left),
                      ))
                ]),
                new Container(
                  decoration: new BoxDecoration(
                      border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    enabled: verified != null && EditingAllowed,
                    title: new Text(
                      text_button_verified,
                      textAlign: TextAlign.center,
                    ),
                    onTap: this.closeCheck,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                ),
                new Container(
                  decoration: new BoxDecoration(
                      border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    enabled: verified != null,
                    title: new Text(
                      "Сохранить",
                      textAlign: TextAlign.center,
                    ),
                    onTap: this.saveCheks,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );
  }

  closeCheck() async {
    if (verified != null) {
      setState(() {
        verified = !verified;
        if (verified) {
          text_button_verified = 'Отклонить';
        } else {
          text_button_verified = 'Принять';
        }
      });
    }
  }

  CreateTable() {
    return new Center(
      child: new FutureBuilder<List<Nomenclature>>(
        future: this.ParseNomenclatureTable(widget.value.nomenclature),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (update) {
              nomenclature = snapshot.data;
              update = false;
            }
            ;
            return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: new BoxDecoration(
                    border: Border.all(color: Colors.black12)),
                child: ListView.builder(
                  itemCount: nomenclature.length,
                  itemBuilder: (context, int currentIndex) =>
                      new Column(children: <Widget>[
                        new Divider(
                          height: 10.0,
                        ),
                        this.CustomListViewTile(nomenclature[currentIndex])
                      ]),
                ));
          } else if (snapshot.hasError) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: new ListView(
                  children: <Widget>[
                    new Container(
                      child: Text('${snapshot.error}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.3,
                      alignment: FractionalOffset.center,
                    )
                  ],
                ));
          }
          return new CircularProgressIndicator();
        },
      ),
    );
  }

  //ЭЛЕМЕНТ СПИСКА
  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  //Элемент списка
  CustomListViewTile(Nomenclature nomenclature) {
    return new Card(
      child: new Column(children: <Widget>[
        new ListTile(
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                nomenclature.nomenclature.length > MaxLenghtNom
                    ? nomenclature.nomenclature.substring(0, MaxLenghtNom) +
                        '...'
                    : nomenclature.nomenclature,
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              CupertinoSwitch(
                value: nomenclature.accepted,
                onChanged: (bool value) {
                  setState(() {
                    nomenclature.accepted = value;
                  });
                },
              ),
            ],
          ),
          onTap: () {
            setState(() {
              nomenclature.accepted = !nomenclature.accepted;
            });
          },
        )
      ]),
    );
  }

  Future<List<Nomenclature>> ParseNomenclatureTable(List nomenclature) async {
    try {
      if (nomenclature.length != 0) {
        return nomenclature
            .map((nomenclature) => new Nomenclature.fromJson(nomenclature))
            .toList();
      } else
        throw 'Список пуст';
    } catch (error) {
      throw error.toString();
    }
  }
}
