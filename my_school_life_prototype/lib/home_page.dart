import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:photo_view/photo_view.dart';
import 'file_viewer.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/HomePage";
  final String pageTitle;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<String> imageFiles = new List<String>();
  bool submitting = false;
  Dio dio = new Dio();

  void getImages() async
  {
    List<String> reqImages = new List<String>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = "http://mystudentlife-220716.appspot.com/photos";
    Response response = await dio.get(url, data: {"id":await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    for (var value in response.data['images'].values) {
      reqImages.add(value['url']);
    }
    
    this.setState((){imageFiles = reqImages;});
  }

  void initState() {

    imageFiles.clear();
    getImages();
  }

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
                   child: new Stack(
                     children: <Widget>[
                       Center(child: CircularProgressIndicator(),),
                       Center(
                         child: GestureDetector(
                          // When the child is tapped, show a snackbar
                          onTap:() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(list: imageFiles, i: index)));
                          },
                          child: new Hero(
                              tag: "imageView"+index.toString(),
                              child: new TransitionToImage((
                                 fit: BoxFit.cover,
                                   height: 150.0,
                                   width: 150.0,
                                   placeholder: kTransparentImage,
                                   image: imageFiles[index]
                                 ))
                        ),
                       ),
                     ],
                   )
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
        body: LayoutBuilder(
          builder: (context, constraints) =>
              Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Container(
                    alignment: Alignment.center,
                    child: submitting ? new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,)) : new Container()
                  ),
                  new Container(
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
                      ),
                    )
                  ]
                 ),
              )
        );

    return page;
  }

  void getCameraImage() async
  {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    String url = await uploadPhoto(image);

    setState(() {
      if (image != null) {
        imageFiles.add(url);
      }
    });
  }

  void getImage() async
  {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String url = await uploadPhoto(image);

    setState(() {
      if (image != null) {
          imageFiles.add(url);
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

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "file": new UploadFileInfo(file, new DateTime.now().millisecondsSinceEpoch.toString()+file.path.split('/').last)
    });

    submit(true);

    var responseObj = await dio.post(url, data: formData);

    if(responseObj.data['refreshToken'] == null) {
        AlertDialog errorDialog = new AlertDialog(
        content: new Text("An Error Occured! Please Try Again"),
        actions: <Widget>[
          new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK"))
        ],
      );

      showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
    }
    else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        submit(false);
        return responseObj.data['url'];
    }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
