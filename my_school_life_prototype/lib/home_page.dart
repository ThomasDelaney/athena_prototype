import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/HomePage";
  final String pageTitle;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<File> imageFiles = new List<File>();

  @override
  Widget build(BuildContext context) {

    Container imageList;

    if (imageFiles.length == 0) {
      imageList = new Container(
        height: 150.0,
          child: new ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: new SizedBox(
                    width: 150.0,
                    height: 150.0,
                    child: new Card(
                      child: new Text("Add Photos and Videos!"),
                 ),
                )
              ),
            ],
          ),
      );
    }
    else{
    imageList =  new Container(
        height: 150.0,
        child: new ListView.builder (
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: imageFiles.length,
          itemBuilder: (BuildContext ctxt, int index)
          {
            return new Container(
              margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: new SizedBox(
                child: new Card(
                   child: new Image.file(imageFiles[index], fit: BoxFit.cover),
                ),
                width: 150.0,
                height: 150.0,
              ),
            );
          }
        )
    );
  }

    final page = Scaffold(
        appBar: new AppBar(
          title: new Text(widget.pageTitle),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => signOut(),
            ),
          ],
        ),
        body: new Container(
              alignment: Alignment.bottomCenter,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                      new IconButton(
                        color: Colors.red,
                        icon: Icon(Icons.image, size: 35.0),
                        onPressed: () => getImage(),
                      ),
                      new IconButton(
                        color: Colors.red,
                        icon: Icon(Icons.camera_alt, size: 35.0),
                        onPressed: () => getCameraImage(),
                      )
                    ]
                  ),
                imageList,
                ],
              )
            ),
    );

    return page;
  }

  void getCameraImage() async
  {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (image != null) {
        imageFiles.add(image);
      }
    });
  }

  void getImage() async
  {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    await uploadPhoto(image);

    setState(() {
      if (image != null) {
          imageFiles.add(image);
        }
    });
  }

  void signOut()
  {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text("You are about to be Signed Out"),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK"))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => signOutDialog);
  }

  void handleSignOut() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("id");
    await prefs.remove("refreshToken");


    Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
  }


  Future<String> uploadPhoto(File file) async
  {
    String url = "http://mystudentlife-220716.appspot.com/photo";

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Dio dio = new Dio();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "file": new UploadFileInfo(file, file.path.split('/').last)
    });

    var response = await dio.post(url, data: formData);

    print(response.data);
  }
}
