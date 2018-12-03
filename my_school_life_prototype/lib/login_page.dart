import 'package:flutter/material.dart';
import 'register_page.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

//class to display and handle the log in page
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/LoginPage";
  final String pageTitle;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text editing controllers, used to retrieve the text entered by the user in a text form field
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();

  //method to change the text in the email and password input boxes
  void updateText(String newEmail, String newPass)
  {
    setState(() {
      emailController.text = newEmail;
      passwordController.text = newPass;
    });
  }

  @override
  Widget build(BuildContext context){

    //text input field for the user's email
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

    //text input field for the user's password
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

    //button to submit the log in details
    final loginButton = ButtonTheme(
        minWidth: 30.0,
        height: 46.0,
        child: new RaisedButton(
          child: new Text("Login", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
          color: Colors.redAccent,
          onPressed: () => signInUser(emailController.text, passwordController.text)
        )
    );

    //button to route the user to the register page
    final registerButton = ButtonTheme(
        minWidth: 30.0,
        height: 46.0,
        child: new RaisedButton(
            child: new Text("Register", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
            color: Colors.red,
            onPressed: receiveUserData
        )
    );

    //scaffold to encapsulate all the widgets
    return new Scaffold(
          appBar: new AppBar(
          title: new Text(widget.pageTitle),
          ),
          body: new Center(
            //stored in a listview for simple layout, will be changed later on
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

  //route user to register screen and when the user returns, accept the user data from that page, and update the relevant text form fields
  Future<void> receiveUserData() async
  {
    var userInfo = await Navigator.pushNamed(context, RegisterPage.routeName);
    Map<String, dynamic> userJson = json.decode(userInfo);
    updateText(userJson['username'], userJson['password']);
  }

  //method to submit user's log in data
  void signInUser(String email, String password) async
  {
    //API URL for logging in
    String url = "http://mystudentlife-220716.appspot.com/signin";

    //put the email and password into a map
    Map map = {"email": email, "password": password};

    //make the sign in request and retrieve the response
    Map<String, dynamic> response = json.decode(await signInRequest(url, map));

    String message = "";
    String id = "";
    String firstName = "";
    String secondName = "";
    String token = "";
    String refresh = "";

    //if the response ['response']  is not null, then print the error message
    if (response['response'] != null){
      message = json.decode(response['response'])['error']['message'];
    }
    //if null, then the request was a success, retrieve the information
    else{
      id = response['id'];
      firstName = response['message']['firstName'];
      secondName = response['message']['secondName'];
      token = response['token'];
      refresh = response['refreshToken'];
    }

    //parse the returned message, this could be error message such as invalid email
    if (message == "INVALID_EMAIL"){
      message = "This Email is Not Recognized!";
    }
    else if (message == "INVALID_PASSWORD" ){
      message = "Incorrect Password";
    }
    else {
      message = "Success";
    }

    //display alertdialog with the returned message
    AlertDialog responseDialog = new AlertDialog(
      content: new Text(message),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleDialog(message, id, firstName, secondName, token, refresh), child: new Text("OK"))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
  }

  //method called when the alert dialog for submitting log in information is displayed after the submission request is returned
  void handleDialog(String message, String id, String firstName, String secondName, String token, String refreshToken) async
  {
    //if log in was not a success, pop the the dialog
    if (message != "Success"){
      Navigator.pop(context);
    }
    //if successful, then store the users name, id, and refreshToken (used for authentication) in shared preferences for quick retrieval
    else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("name", firstName+" "+secondName);
      await prefs.setString("id", id);
      await prefs.setString("refreshToken", refreshToken);

      //pop all widgets currently on the stack, and route user to the homepage, and pass in their name
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => new HomePage(pageTitle: firstName+" "+secondName)), (Route<dynamic> route) => false);
    }
  }

  //make the sign in request using the HttpClient Library, will be changed to adhere to the Dio library standard
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
