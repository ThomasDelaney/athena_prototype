import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'register_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder> {
      RegisterPage.routeName: (BuildContext context) => new RegisterPage(pageTitle: "Register")
    };

    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.red,
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}

class MyHomePage extends StatefulWidget
{
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  String text = "";
  final _random = new Random();

  Future<String> fetchPost() async
  {
    final response =
    await http.get('http://mystudentlife-220716.appspot.com/mainpage/');

    if (response.statusCode == 200)
    {
      // If the call to the server was successful, parse the JSON
      print(json.decode(response.body));
      changeText(json.decode(response.body)['title']+": "+(_random.nextInt(1000)).toString());
    }
    else
    {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  void changeText(String input)
  {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      text = input;
    });
  }

  @override
  Widget build(BuildContext context)
  {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(widget.title),
        ),
        body: new Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: new Column(
            // Column is also layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug paint" (press "p" in the console where you ran
            // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
            // window in IntelliJ) to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("BIRD UP? $text", style: new TextStyle(fontSize: 20.0)),
              new Container(
                margin: new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                child: new ButtonTheme(
                    minWidth: 30.0,
                    height: 46.0,
                    child: new RaisedButton(
                      child: new Text("Press For the Juice", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
                      color: Colors.blue,
                      onPressed: fetchPost,
                    )
                ),
              ),
            ],
          ),
        ),
    );
  }
}
