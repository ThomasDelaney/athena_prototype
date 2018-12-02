import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/RegisterPage";
  final String pageTitle;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool submitting = false;

  final firstNameController = new TextEditingController();
  final secondNameController = new TextEditingController();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final reEnteredPasswordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firstName = new TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      controller: firstNameController,
      decoration: InputDecoration(
          hintText: "First Name",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    final secondName = new TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      controller: secondNameController,
      decoration: InputDecoration(
          hintText: "Second Name",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );


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
      obscureText: true,
      controller: passwordController,
      decoration: InputDecoration(
          hintText: "Password",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    final reEnterPassword = new TextFormField(
      autofocus: false,
      controller: reEnteredPasswordController,
      obscureText: true,
      decoration: InputDecoration(
          hintText: "Re-Enter Password",
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero
          )
      ),
    );

    final registerButton = ButtonTheme(
        minWidth: 30.0,
        height: 46.0,
        child: new RaisedButton(
            child: new Text("Register", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
            color: Colors.red,
            onPressed: () => registerUser(firstNameController.text, secondNameController.text, emailController.text, passwordController.text, reEnteredPasswordController.text)
        )
    );

    final centeredIndicator = new Center(
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new SizedBox(
              height: 60.0,
              width: 60.0,
              child: new CircularProgressIndicator(
                strokeWidth: 7.0,
              ),
            )
        ]
      )
    );

    final registerForm = new Container(
      padding: EdgeInsets.only(left: 25.0, right: 25.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
            firstName,
            SizedBox(height: 30.0),
            secondName,
            SizedBox(height: 30.0),
            email,
            SizedBox(height: 30.0),
            password,
            SizedBox(height: 30.0),
            reEnterPassword,
            SizedBox(height: 30.0),
            registerButton
        ],
      ),
    );

    final pageStack = new Stack(
      children: <Widget>[
        registerForm
      ],
    );

    if (submitting) {
      pageStack.children.add(centeredIndicator);
    }

    final page = Scaffold(
        appBar: new AppBar(
          title: new Text(widget.pageTitle),
        ),
        body: new Center(
          child: new Container(
              child: pageStack
            ),
        )
    );

    return page;
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }

  void registerUser(String fname, String sname, String email, String pwd, String rPwd) async
  {
    String url = "http://mystudentlife-220716.appspot.com/register";

    if (rPwd != pwd){
      AlertDialog responseDialog = new AlertDialog(
        content: new Text("Passwords do not Match!"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
      return ;
    }

    Map map = {"firstName": fname, "secondName": sname, "email": email, "password": pwd, "reEnteredPassword": rPwd};

    Map<String, dynamic> response = json.decode(await regiserRequest(url, map));

    String message = "";

    if (response['response'] != null){
      message = json.decode(response['response'])['error']['message'];
    }
    else{
      message = response['message'];
    }

    if (message == "EMAIL_EXISTS"){
      message = "A User with this Email already exists!";
    }
    else if (message == "User Created Successfully" ){
      message = "SIGNED UP!";
    }
    else if (message == "WEAK_PASSWORD : Password should be at least 6 characters" ){
      message = "Password should be at least 6 characters";
    }

    AlertDialog responseDialog = new AlertDialog(
      content: new Text(message),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleDialog(message, email, pwd), child: new Text("OK"))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
  }

  void handleDialog(String message, String username, String password)
  {
    Map userMap = {"username": username, "password": password};
    String userData = json.encode(userMap);

    if (message != "SIGNED UP!"){
      Navigator.pop(context);
    }
    else{
      Navigator.pop(context);
      Navigator.pop(context, userData);
    }
  }

  Future<String> regiserRequest(String url, Map jsonMap) async
  {
    submit(true);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    submit(false);
    return reply;
  }
}
