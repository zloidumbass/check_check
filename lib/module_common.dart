import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


//Всплывающие окна

CreateshowDialog(context, content){
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
      )
  );
}//Сообщение

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
                child: new Text("Загрузка...",textAlign: TextAlign.center, style: new TextStyle(fontSize: 16.0),),
                margin: new EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              ),
            ],
          ),
        )
      );
     },
  );
}//Загркзеп

LoadingStop(context) {
  Navigator.pop(context); //pop dialog
}//Конец загрузки
