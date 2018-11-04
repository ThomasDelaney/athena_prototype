import 'package:flutter/material.dart';
import 'register_page.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/LoginPage";
  final String pageTitle;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();

  void updateText(String newEmail, String newPass)
  {
    setState(() {
      emailController.text = newEmail;
      passwordController.text = newPass;
    });
  }

  @override
  Widget build(BuildContext context){
    final email = new TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: emailController,
      decoration: InputDecoration(
        hintText: "Email",
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero
        )
      ),
    );

    final password = new TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
          hintText: "Password",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    final loginButton = ButtonTheme(
        minWidth: 30.0,
        height: 46.0,
        child: new RaisedButton(
          child: new Text("Login", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
          color: Colors.redAccent,
          onPressed: () => signInUser(emailController.text, passwordController.text)
        )
    );

    final registerButton = ButtonTheme(
        minWidth: 30.0,
        height: 46.0,
        child: new RaisedButton(
            child: new Text("Register", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
            color: Colors.red,
            onPressed: receiveUserData
        )
    );


    return new Scaffold(
          appBar: new AppBar(
          title: new Text(widget.pageTitle),
          ),
          body: new Center(
            child: new ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
            children: <Widget>[
              email,
              SizedBox(height: 30.0),
              password,
              SizedBox(height: 30.0),
              loginButton,
              SizedBox(height: 30.0),
              registerButton
            ]
          )
        )
      );
    }

  Future<void> receiveUserData() async
  {
    var userInfo = await Navigator.pushNamed(context, RegisterPage.routeName);
    Map<String, dynamic> userJson = json.decode(userInfo);
    updateText(userJson['username'], userJson['password']);
  }

  void signInUser(String email, String password) async
  {
    String url = "http://mystudentlife-220716.appspot.com/signin";

    Map map = {"email": email, "password": password};

    Map<String, dynamic> response = json.decode(await signInRequest(url, map));

    print(response);

    String message = "";
    String id = "";
    String firstName = "";
    String secondName = "";

    if (response['response'] != null){
      message = json.decode(response['response'])['error']['message'];
    }
    else{
      id = response['id'];
      firstName = response['message']['firstName'];
      secondName = response['message']['secondName'];
    }

    if (message == "INVALID_EMAIL"){
      message = "This Email is Not Recognized!";
    }
    else if (message == "INVALID_PASSWORD" ){
      message = "Incorrect Password";
    }
    else {
      message = "Success";
    }

    AlertDialog responseDialog = new AlertDialog(
      content: new Text(message),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleDialog(message, id, firstName, secondName), child: new Text("OK"))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
  }

  void handleDialog(String message, String id, String firstName, String secondName) async
  {
    if (message != "Success"){
      Navigator.pop(context);
    }
    else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("name", firstName+" "+secondName);
      await prefs.setString("id", id);

      print("ITS BEEN PLOTTED: "+prefs.getString("name"));
      
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage(pageTitle: firstName+" "+secondName)), (Route<dynamic> route) => false);
    }
  }

  Future<String> signInRequest(String url, Map jsonMap) async
  {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }
}
