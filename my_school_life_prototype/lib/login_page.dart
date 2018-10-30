import 'package:flutter/material.dart';
import 'register_page.dart';
import 'dart:async';
import 'dart:convert';

class LoginPage extends StatefulWidget {

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
          onPressed: test
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
          title: new Text("MyStudentLife"),
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

  void test()
  {
    print("test");
  }
}
