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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'timetable_page.dart';
import 'package:file_picker/file_picker.dart';
import 'font_settings.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/HomePage";
  final String pageTitle;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<String> imageFiles = new List<String>();
  FlutterSound flutterSound = new FlutterSound();
  bool submitting = false;
  Dio dio = new Dio();
  bool recorderLoading = false;
  bool recording = false;
  String uri = "";
  StreamSubscription<RecordStatus> audioSubscription = null;
  String function = "";
  String day = "";
  Container imageList;
  bool imagesLoaded = false;
  List<String> textFiles = const <String>["Algebra Notes", "Formulas for Standard Deviation", "Trigonometry Friday Notes", "Hint for Next Weeks test", "Probability cheat sheet", "Formulas for Algebra"];
  double imageSize = 150.0;
  String font = "";

  void getImages() async
  {
    List<String> reqImages = new List<String>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = "http://mystudentlife-220716.appspot.com/photos";
    Response response = await dio.get(url, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    if (response.data['images']?.values != null) {
      for (var value in response.data['images'].values) {
        reqImages.add(value['url']);
      }
    }

    this.setState((){imageFiles = reqImages; imagesLoaded = true;});
  }
  
  void getFont() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.setState((){font = prefs.getString("font");});
  }

  void initState() {
    imageFiles.clear();
    getImages();
  }

  @override
  Widget build(BuildContext context) {

    getFont();

    Container imageList;

    if (imageFiles.length == 0 && imagesLoaded) {
      imageList = new Container(
        height: imageSize,
          child: new ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              new Container(
                  margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: new SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: new Card(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text("Add Photos and Videos!", textAlign: TextAlign.center, style: TextStyle(fontFamily: font),),
                          new Icon(Icons.cloud_upload, size: 40.0, color: Colors.grey,)
                        ]
                      ),
                 ),
                )
              ),
            ],
          ),
      );
    }
    else if (imagesLoaded){
    imageList =  new Container(
        height: imageSize,
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
                       Center(
                         child: GestureDetector(
                          // When the child is tapped, show a snackbar
                          onTap:() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(list: imageFiles, i: index)));
                          },
                          child: new Hero(
                              tag: "imageView"+index.toString(),
                              child: CachedNetworkImage(
                                placeholder: CircularProgressIndicator(),
                                imageUrl: imageFiles[index],
                                height: imageSize,
                                width: imageSize,
                                fit: BoxFit.cover
                              ),
                          ),
                        ),
                       ),
                     ],
                   )
                ),
                //Keeps the card the same size when the image is loading
                width: imageSize,
                height: imageSize,
              ),
            );
          }
        )
    );
  }
  else{
      imageList =  new Container(child: new Padding(padding: EdgeInsets.all(50.0), child: new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0))));
  }

  final Card recordingCard = Card(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0), child: new Text("Recording", textAlign: TextAlign.center, textScaleFactor: 1.5, style: TextStyle(fontFamily: font),)),
            recorderLoading ?
            IconButton(
              iconSize: 80.0,
              color: Colors.red,
              icon: Icon(Icons.stop),
              onPressed: () => stopRecording(),
            ) : new Padding(padding: EdgeInsets.all(20.0), child: new SizedBox(width: 45.0, height: 45.0, child: new CircularProgressIndicator(strokeWidth: 5.0))),
          ],
        ),
      )
  );

  final ListView textFileList = ListView.builder(
      itemCount: textFiles.length,
      itemBuilder: (context, position) {
        return Card(
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          elevation: 3.0,
          child: new ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                  border: new Border(right: new BorderSide(width: 1.0, color: Colors.white24))
              ),
              child: Icon(Icons.insert_drive_file, color: Colors.redAccent, size: 32.0,),
            ),
            title: Text(
              textFiles[position],
              style: TextStyle(fontSize: 20.0, fontFamily: font),
            ),
          ),
        );
      },
    );

  final page = Scaffold(
      endDrawer: new Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Settings', style: TextStyle(fontSize: 25.0, fontFamily: font)),
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
            ListTile(
              leading: Icon(Icons.font_download),
              title: Text('Fonts', style: TextStyle(fontSize: 20.0, fontFamily: font)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings()));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out', style: TextStyle(fontSize: 20.0, fontFamily: font)),
              onTap: () {
                signOut();
              },
            ),
          ],
        ),
      ),
      appBar: new AppBar(
        title: new Text(widget.pageTitle, style: TextStyle(fontFamily: font),),
        actions: recording ? <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.close),
            iconSize: 30.0,
            onPressed: () => cancelRecording(),
          ),
        ] : <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.mic),
            iconSize: 30.0,
            onPressed: () => recording ? null : recordAudio(),
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
            Stack(
              //fit: StackFit.expand,
              children: <Widget>[
                new Container(
                  height: MediaQuery.of(context).size.height * 0.63,
                  alignment: Alignment.topCenter,
                  child: textFileList,
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
                  ),
                  new Container(
                      alignment: Alignment.center,
                      child: recording ?
                      new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                            margin: MediaQuery.of(context).padding,
                            child: new ModalBarrier(color: Colors.black54, dismissible: false,)), recordingCard],) : new Container()
                  ),
                  new Container(
                      alignment: Alignment.center,
                      child: submitting ? new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                              margin: MediaQuery.of(context).padding,
                              child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
                        ],
                      )
                          : new Container()
                  ),
                ]
               ),
            )
      );

    return page;
  }

  void getImage() async
  {
    String image = await FilePicker.getFilePath(type: FileType.IMAGE);

    if (image != null) {
      String url = await uploadPhoto(image);

      setState(() {
        if (image != null) {
          imageFiles.add(url);
        }
      });
    }
  }

  void getCameraImage() async
  {
    String image = await FilePicker.getFilePath(type: FileType.CAPTURE);;

    if (image != null) {
      String url = await uploadPhoto(image);

      setState(() {
        if (image != null) {
          imageFiles.add(url);
        }
      });
    }
  }

  void showCannotUnderstandError()
  {
    cancelRecording();

    AlertDialog cannotUnderstand = new AlertDialog(
      content: new Text("Sorry, I could not understand you! Please try again", style: TextStyle(fontFamily: font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
  }

  void showErrorDialog()
  {
    AlertDialog errorDialog = new AlertDialog(
      content: new Text("An Error has occured. Please try again", style: TextStyle(fontFamily: font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  void recordAudio() async
  {
    this.setState(() {
      this.recorderLoading = true;
      this.recording = true;
    });

    this.uri =  await flutterSound.startRecorder(null);
    audioSubscription = flutterSound.onRecorderStateChanged.listen((e) {
      if (e != null) {
      }
    });
  }

  void cancelRecording()
  {
    this.setState(() {
      this.recording = false;
    });

    if (audioSubscription != null) {
      audioSubscription.cancel();
      audioSubscription = null;
    }
  }

  void stopRecording() async
  {
    print("stopped");
    await flutterSound.stopRecorder();

    this.setState(() {
      this.recorderLoading = false;
    });

    if (audioSubscription != null) {
      audioSubscription.cancel();
      audioSubscription = null;

      String url = "http://mystudentlife-220716.appspot.com/command";

      SharedPreferences prefs = await SharedPreferences.getInstance();

      File file = new File.fromUri(new Uri.file(this.uri));

      FormData formData = new FormData.from({
        "id": await prefs.getString("id"),
        "refreshToken": await prefs.getString("refreshToken"),
        "file": new UploadFileInfo(file, this.uri),
      });

      var responseObj;

      try
      {
        responseObj = await dio.post(url, data: formData);

        File currentAudio = File.fromUri(new Uri.file(this.uri));
        currentAudio.deleteSync();

        if(responseObj.data['function'] == null) {

          this.setState(() {
            this.recording = false;
          });

          showCannotUnderstandError();
        }
        else {
          if (responseObj.data['function'] == "timetable") {

            this.setState(() {
              this.recording = false;
            });

            List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

            if (!weekdays.contains(responseObj.data['day'])) {
              AlertDialog cannotUnderstand = new AlertDialog(
                content: new Text("You don't have any classes for this day", style: TextStyle(fontFamily: font),),
                actions: <Widget>[
                  new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font)))
                ],
              );

              showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
            }
            else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TimetablePage(initialDay: responseObj.data['day'])));
            }
          }
          else{
            showCannotUnderstandError();
          }
        }
      }
      on DioError catch(e)
      {
        this.setState(() {
          this.recording = false;
        });

        showCannotUnderstandError();
      }
    }
  }

  void signOut()
  {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text("You are about to be Signed Out", style: TextStyle(fontFamily: font)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK", style: TextStyle(fontFamily: font)))
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


  Future<String> uploadPhoto(String filePath) async
  {
    String url = "http://mystudentlife-220716.appspot.com/photo";

    SharedPreferences prefs = await SharedPreferences.getInstance();

    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "file": new UploadFileInfo(new File(filePath), new DateTime.now().millisecondsSinceEpoch.toString()+filePath.split('/').last)
    });

    submit(true);

    try {
      var responseObj = await dio.post(url, data: formData);

      if(responseObj.data['refreshToken'] == null) {
        AlertDialog errorDialog = new AlertDialog(
          content: new Text("An Error Occured! Please Try Again", style: TextStyle(fontFamily: font)),
          actions: <Widget>[
            new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font)))
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
    on DioError catch(e)
    {
      submit(false);
      showErrorDialog();
    }
  }

  void submit(bool state)
  {
    setState(() {
      submitting = state;
    });
  }
}
