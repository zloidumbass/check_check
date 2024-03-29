import 'dart:convert';

import 'package:check_check/data/static_variable.dart';
import 'package:check_check/data/session_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  bool update = true;
  bool verified = false;


  @override
  void dispose() {
    super.dispose();
  }

  //Процедура сохранения параметров
  saveCheks() async {

    LoadingStart(context);
    try {
      String json_body =
          '{"type":"edit","UID":"${widget.value.UID}","verified":${verified},"list_view":false}';
      var response = await http.post(
          '${ServerUrl}/hs/mobilecheckcheck/addrecordqr',
          body: json_body,
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Basic ${AuthorizationString}',
            'content-version': Version + '.' + BuildNumber
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
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 0, top: 10, right: 0, left: 0),
                        child: Text('Статус',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.status,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left),
                      ))
                ]),
                Column(children: <Widget>[
                  new Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 0, top: 10, right: 0, left: 0),
                        child: Text('Дата/время доставки',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.datetime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left),
                      ))
                ]),
                Column(children: <Widget>[
                  new Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 0, top: 10, right: 0, left: 0),
                        child: Text('Маршрут',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.addres_to + ' - ' + widget.value.addres_do,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.left),
                      ))
                ]),
                Column(children: <Widget>[
                  new Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 0, top: 10, right: 0, left: 0),
                        child: Text('Сумма',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left),
                      )),
                  new Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, top: 0, right: 0, left: 0),
                        child: Text(widget.value.sum,
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
                    enabled: widget.value.status == 'В работе',
                    title: new Text(
                      'Показать курьера',
                      textAlign: TextAlign.center,
                    ),
                    onTap: this.getCour,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                ),
                new Container(
                  decoration: new BoxDecoration(
                      border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    title: new Text(
                      'Отменить',
                      textAlign: TextAlign.center,
                    ),
                    onTap: this.cancelCheck,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                ),
                new Container(
                  decoration: new BoxDecoration(
                      border: Border.all(color: Colors.black)),
                  child: new ListTile(
                    title: new Text(
                      'Принять',
                      textAlign: TextAlign.center,
                    ),
                    onTap: this.verifiedCheck,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );

  }

  verifiedCheck() async {
    verified = true;
    saveCheks();
  }

  cancelCheck() async {
    verified = false;
    saveCheks();
  }

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  getCour() async {

    final jsonEndpoint = '${ServerUrl}/hs/mobilecheckcheck/geodata?courier=${widget.value.courier}';
    print(jsonEndpoint);
    try {
      final response = await http.get(jsonEndpoint,
          headers: {
            'Authorization': 'Basic ${AuthorizationString}',
            'content-version': Version+'.'+BuildNumber
          });
      if (response.statusCode == 200) {
        List geo_data = json.decode(response.body);
        if(geo_data.length == 1){
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(geo_data[0]['Широта'], geo_data[0]['Долгота']),
                    zoom: 18.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('courier'),
                      position: LatLng(geo_data[0]['Широта'], geo_data[0]['Долгота']),
                      infoWindow: InfoWindow(title: 'Курьер'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet,
                      ),
                    )
                  },);
              });
        }

      } else
        print(response.body);
    } catch (error) {
      print(error.toString());
    }
  }


}
