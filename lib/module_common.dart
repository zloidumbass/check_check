import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'forms/account.dart';
import 'forms/checks.dart';
import 'forms/instruction.dart';
import 'forms/login.dart';
import 'forms/manual_input_cheks.dart';
import 'forms/manual_input_waybills.dart';
import 'forms/waybills.dart';

//Всплывающие окна

CreateshowDialog(context, content) {
  showDialog(
      context: context,
      barrierDismissible: false,
      child: new CupertinoAlertDialog(
        content: content,
        actions: <Widget>[
          new FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text("OK"))
        ],
      ));
} //Сообщение

LoadingStart(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () {},
          child: new CupertinoAlertDialog(
            content: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                new Container(
                  child: new Text(
                    "Загрузка...",
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 16.0),
                  ),
                  margin: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                ),
              ],
            ),
          ));
    },
  );
} //Загркзеп

LoadingStop(context) {
  Navigator.pop(context); //pop dialog
} //Конец загрузки

//мастер форма
CreateDefaultMasterForm(int index_form, Widget body, context, callback) {
  return Scaffold(
    appBar: AppBar(
      title: Text(index_form == 0
          ? 'ИНСТРУКЦИЯ'
          : index_form == 1
              ? 'ЧЕКИ'
              : index_form == 2 ? 'ПУТЕВЫЕ ЛИСТЫ' : 'НЕОПРЕДЕЛЕНО'),
    ),
    drawer: new Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                new DrawerHeader(
                  child: new Image.asset(
                    "assets/images/open_logo.png",
                    height: 100.0,
                  ),
                ),
                new ListTile(
                  selected: index_form == 0,
                  leading: new Icon(Icons.assignment),
                  title: new Text('ИНСТРУКЦИЯ'),
                  onTap: () {
                    if (index_form != 0) {
                      Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new InstructionPage()),
                          (Route<dynamic> route) => false);
                    }
                  },
                ),
                new ListTile(
                  selected: index_form == 1,
                  leading: new Icon(Icons.check_box),
                  title: new Text('ЧЕКИ'),
                  onTap: () {
                    if (index_form != 1) {
                      Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new CheckPage()),
                          (Route<dynamic> route) => false);
                    }
                  },
                ),
                new ListTile(
                  selected: index_form == 2,
                  leading: new Icon(Icons.swap_calls),
                  title: new Text('ПУТЕВЫЕ ЛИСТЫ'),
                  onTap: () {
                    if (index_form != 2) {
                      Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new WaybillsPage()),
                          (Route<dynamic> route) => false);
                    }
                  },
                ),
                new Divider(),
                new ListTile(
                  leading: new Icon(Icons.account_circle),
                  title: new Text('УЧЕТНАЯ ЗАПИСЬ'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AccountPage()));
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.info),
                  title: new Text('О ПРОГРАММЕ'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Container(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                      child: Column(
                    children: <Widget>[
                      Divider(),
                      new ListTile(
                        leading: new Icon(Icons.exit_to_app),
                        title: new Text('ВЫХОД'),
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new LoginPage()),
                              (Route<dynamic> route) => false);
                        },
                      )
                    ],
                  ))))
        ],
      ),
    ),
    body: body,
    floatingActionButton: index_form != 0
        ? FloatingActionButton(
            tooltip: 'Increment',
            child: Icon(Icons.add),
            onPressed: () {
              if (index_form == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManualInputPage(callback)));
              } else if (index_form == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ManualInputWaybillsStep1(callback)));
              }
            },
          )
        : Container(),
  );
}
