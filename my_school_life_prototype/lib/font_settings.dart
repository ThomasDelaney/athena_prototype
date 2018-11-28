import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class FontSettings extends StatefulWidget {
  @override
  _FontSettingsState createState() => _FontSettingsState();
}

class _FontSettingsState extends State<FontSettings> {

  String currentFont = "";

  @override
  Widget build(BuildContext context) {

    bool recording = false;

    print(currentFont);

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

                    },
                  )
              ),
            ],
          ),
        )
    );

    return page;
  }
}
