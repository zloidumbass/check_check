import 'package:flutter/material.dart';
import 'package:check_check/forms/login.dart';
import 'package:check_check/forms/manual_input_cheks.dart';
import 'package:check_check/forms/manual_input_waybills.dart';
import 'package:check_check/forms/checks.dart';
import 'package:check_check/forms/waybills.dart';
import 'package:check_check/forms/instruction.dart';
import 'package:check_check/forms/account.dart';

class ActivityPage extends StatefulWidget {
  @override
  ActivityPageState createState() {
    return new ActivityPageState();
  }
}

class ActivityPageState extends State<ActivityPage>  with SingleTickerProviderStateMixin {
  //Переменные
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 3);
  }

  //Открытие формы по кнопке добавления
  OpenForm(){
    if (_tabController.index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ManualInputWaybillsPage2()));
    }
    else{
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ManualInputPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _tabController.index == 0?'ИНСТРУКЦИЯ':
            _tabController.index == 1?'ЧЕКИ':
            _tabController.index == 2?'ПУТЕВЫЕ ЛИСТЫ': 'НЕОПРЕДЕЛЕНО'
        ),
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
                    selected: _tabController.index == 0,
                    leading: new Icon(Icons.assignment),
                    title: new Text('ИНСТРУКЦИЯ'),
                    onTap: () {
                      if(_tabController.index != 0) {
                        Navigator.of(context).pop();
                        setState(() {
                          _tabController.index = 0;
                        });
                      }
                    },
                  ),
                  new ListTile(
                    selected: _tabController.index == 1,
                    leading: new Icon(Icons.check_box),
                    title: new Text('ЧЕКИ'),
                    onTap: () {
                      if(_tabController.index != 1) {
                        Navigator.of(context).pop();
                        setState(() {
                          _tabController.index = 1;
                        });
                      }
                    },
                  ),
                  new ListTile(
                    selected: _tabController.index == 2,
                    leading: new Icon(Icons.swap_calls),
                    title: new Text('ПУТЕВЫЕ ЛИСТЫ'),
                    onTap: () {
                      if(_tabController.index != 2) {
                        Navigator.of(context).pop();
                        _tabController.index = 2;
                        setState(() {
                        });
                      }
                    },
                  ),
                  new Divider(),
                  new ListTile(
                    leading: new Icon(Icons.account_circle),
                    title: new Text('УЧЕТНАЯ ЗАПИСЬ'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> AccountPage()));
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
                              builder: (BuildContext context) => new LoginPage()
                            ),
                              (Route<dynamic> route) => false
                          );
                        },
                      )
                    ],
                  )
                )
              )
            )
          ],
        ),
      ),
      body:
      _tabController.index == 0? new InstructionPage():
      _tabController.index == 1? new CheckPage():
      _tabController.index == 2? new WaybillsPage(): Container(),
      floatingActionButton:
      FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
        onPressed: this.OpenForm,
      ),
    );
  }
}
