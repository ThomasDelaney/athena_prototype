import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'file_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  String name = "";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    var routes = <String, WidgetBuilder> {
      RegisterPage.routeName: (BuildContext context) => new RegisterPage(pageTitle: "Register"),
      LoginPage.routeName: (BuildContext context) => new LoginPage(pageTitle: "MyStudentLife"),
      HomePage.routeName: (BuildContext context) => new HomePage(pageTitle: name),
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
      routes: routes,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences sp)
    {
      if(sp.getString("name") == null) {
        Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
      }
      else{
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage(pageTitle: sp.getString("name"))), (Route<dynamic> route) => false);
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return new Container();
  }
}
