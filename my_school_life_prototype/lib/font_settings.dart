import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class FontSettings extends StatefulWidget {
  @override
  _FontSettingsState createState() => _FontSettingsState();
}

class _FontSettingsState extends State<FontSettings> {

  String currentFont = "";
  bool uploadingFont = false;
  Dio dio = new Dio();


  void initState() {
    getCurrentFont();
  }

  void getCurrentFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      currentFont = prefs.getString("font");
    });
  }

  @override
  Widget build(BuildContext context) {
    bool recording = false;

    final page = Scaffold(
        endDrawer: new Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Settings', style: TextStyle(fontSize: 25.0)),
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
              ),
              ListTile(
                leading: Icon(Icons.font_download),
                title: Text('Fonts', style: TextStyle(fontSize: 20.0)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings()));
                },
              ),
            ],
          ),
        ),
        appBar: new AppBar(
          title: new Text("Thomas Delaney"),
          actions: recording ? <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.close),
              iconSize: 30.0,
              onPressed: () => null,
            ),
          ] : <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.mic),
              iconSize: 30.0,
              onPressed: () => null,
            ),
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) =>
          new Stack(
            children: <Widget>[
              new Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 0.0),
                child: new DropdownButton<String>(
                  value: this.currentFont == "" ? null : this.currentFont,
                  hint: new Text("Choose a Font", style: TextStyle(fontSize: 20.0)),
                  items: <String>['Roboto', 'NotoSansTC', 'Montserrat'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value,  style: TextStyle(fontSize: 20.0)),
                    );
                  }).toList(),
                  onChanged: (String val){
                    setState(() {this.currentFont = val;});
                  },
                ),
              ),
              new Container(alignment: Alignment.center, child: Text("Test the Font Here!", style: TextStyle(fontFamily: this.currentFont, fontSize: 35.0))),
              new Container(
                  padding: EdgeInsets.all(10.0),
                  alignment: Alignment.topRight,
                  child: new RaisedButton(
                    child: const Text('Okay', style: TextStyle(color: Colors.white)),
                    color: Theme.of(context).accentColor,
                    elevation: 4.0,
                    splashColor: Colors.blueGrey,
                    onPressed: () {
                      this.currentFont == "" ? Scaffold.of(context).showSnackBar(new SnackBar(content: Text('Please Choose a new Font!'))) : changeFont(context);
                    },
                  )
              ),
              new Container(
                  alignment: Alignment.center,
                  child: uploadingFont ? new Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      new Container(
                          margin: MediaQuery.of(context).padding,
                          child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
                    ],
                  )
                  : new Container()
              ),
            ],
          ),
        ),
    );

    return page;
  }

  void changeFont(BuildContext _context) async
  {
    String url = "http://mystudentlife-220716.appspot.com/font";

    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "font": currentFont
    });

    submit(true);

    try {
      var responseObj = await dio.post(url, data: formData);

      if(responseObj.data['refreshToken'] == null) {
        print(responseObj.data['response']);

        showErrorDialog();
      }
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        await prefs.setString("font", currentFont);
        Scaffold.of(_context).showSnackBar(new SnackBar(content: Text('Font Updated!!')));
        submit(false);
      }
    }
    on DioError catch(e)
    {
      print(e);
      showErrorDialog();
    }
  }

  void submit(bool state)
  {
    setState(() {
      uploadingFont = state;
    });
  }

  void showErrorDialog()
  {
    submit(false);

    AlertDialog errorDialog = new AlertDialog(
      content: new Text("An Error has occured. Please try again"),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK"))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }
}
