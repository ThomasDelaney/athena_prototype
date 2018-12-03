import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

//class to display and handle the register page
class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/RegisterPage";
  final String pageTitle;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //boolean to check if the user is submitting
  bool submitting = false;

  //text editing controllers, used to retrieve the text entered by the user in a text form field
  final firstNameController = new TextEditingController();
  final secondNameController = new TextEditingController();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final reEnteredPasswordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    //text input field for the user's first name
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

    //text input field for the user's second name
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

    //text input field for the user's password name
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

    //text input field for the user to re-enter their password
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

    //button which when pressed, will submit the user's inputted data
    final registerButton = ButtonTheme(
        minWidth: 30.0,
        height: 46.0,
        child: new RaisedButton(
            child: new Text("Register", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
            color: Colors.red,
            onPressed: () => registerUser(firstNameController.text, secondNameController.text, emailController.text, passwordController.text, reEnteredPasswordController.text)
        )
    );

    //a circular progress indicator widget. which is centered on the screen
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

    //container which houses all the widgets previously instantiated
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

    //a stack widget, which has the registerForm container as a child (this will allow for widgets to be put on-top of the stack(
    final pageStack = new Stack(
      children: <Widget>[
        registerForm
      ],
    );

    //if user is submitting data, add the circular progress indicator to the stack, thus displaying it on top of the screen
    if (submitting) {
      pageStack.children.add(centeredIndicator);
    }

    //scaffold which includes the appbar, and the stack within a centered container
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

  //method to change submission state
  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }

  //method to submit user's register data
  void registerUser(String fname, String sname, String email, String pwd, String rPwd) async
  {
    //API URL for registering
    String url = "http://mystudentlife-220716.appspot.com/register";

    //check if passwords match, if not then throw alertdialog error
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

    //create map of register data
    Map map = {"firstName": fname, "secondName": sname, "email": email, "password": pwd, "reEnteredPassword": rPwd};

    //submit the request, and decode the response
    Map<String, dynamic> response = json.decode(await regiserRequest(url, map));

    String message = "";

    //if the response ['response']  is not null, then print the error message
    if (response['response'] != null){
      message = json.decode(response['response'])['error']['message'];
    }
    //if null, then the request was a success, retrieve the information
    else{
      message = response['message'];
    }

    //parse the returned message, this could be error message such as email already exists
    if (message == "EMAIL_EXISTS"){
      message = "A User with this Email already exists!";
    }
    else if (message == "User Created Successfully" ){
      message = "SIGNED UP!";
    }
    else if (message == "WEAK_PASSWORD : Password should be at least 6 characters" ){
      message = "Password should be at least 6 characters";
    }

    //display alertdialog with the returned message
    AlertDialog responseDialog = new AlertDialog(
      content: new Text(message),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleDialog(message, email, pwd), child: new Text("OK"))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => responseDialog);
  }

  //method called when the alert dialog for submitting register information is displayed after the submission request is returned
  void handleDialog(String message, String username, String password)
  {
    //put the user's username and password into a map
    Map userMap = {"username": username, "password": password};
    String userData = json.encode(userMap);

    //if the message isnt signed up, then just close the dialog
    if (message != "SIGNED UP!"){
      Navigator.pop(context);
    }
    //if success, then pop the dialog and pop the register screen (bringing the user back to the log in screen, however, the map of user data is passed back to the log in screen too
    else{
      Navigator.pop(context);
      Navigator.pop(context, userData);
    }
  }

  //make the register request using the HttpClient Library, will be changed to adhere to the Dio library standard
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
