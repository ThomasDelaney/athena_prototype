import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'file_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'timetable_page.dart';
import 'package:file_picker/file_picker.dart';
import 'font_settings.dart';

//Widget that displays the "home" page, this will actually be page for the virtual hardback and journal that displays notes and files, stored by the user
class HomePage extends StatefulWidget {
  HomePage({Key key, this.pageTitle}) : super(key: key);

  static const String routeName = "/HomePage";
  final String pageTitle;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //list for image urls, will be general files in final version
  List<String> imageFiles = new List<String>();

  //object used to access the devices microphone
  FlutterSound flutterSound = new FlutterSound();
  bool submitting = false;

  //Dio object, used to make rich HTTP requests
  Dio dio = new Dio();
  bool recorderLoading = false;
  bool recording = false;

  //URI for audio file from recording
  String uri = "";

  //stream subscription is used to keep track of the user recording
  StreamSubscription<RecordStatus> audioSubscription = null;

  //function and day for recording
  String function = "";
  String day = "";

  //container for the image list
  Container imageList;
  bool imagesLoaded = false;

  //dummy data for user notes
  List<String> textFiles = const <String>["Algebra Notes", "Formulas for Standard Deviation", "Trigonometry Friday Notes", "Hint for Next Weeks test", "Probability cheat sheet", "Formulas for Algebra"];

  //size of images
  double imageSize = 150.0;
  String font = "";

  //get user images
  void getImages() async
  {
    List<String> reqImages = new List<String>();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //API URL for getting images
    String url = "http://mystudentlife-220716.appspot.com/photos";

    //get user images
    Response response = await dio.get(url, data: {"id": await prefs.getString("id"), "refreshToken": await prefs.getString("refreshToken")});

    //store images in a string list
    if (response.data['images']?.values != null) {
      for (var value in response.data['images'].values) {
        reqImages.add(value['url']);
      }
    }

    //set state for the images list, and tell the state that the images have been loaded
    this.setState((){imageFiles = reqImages; imagesLoaded = true;});
  }

  //get current font from shared preferences if present
  void getFont() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.setState((){font = prefs.getString("font");});
  }

  //method called before the page is rendered
  void initState() {
    //clear the image list and repopulate it
    imageFiles.clear();
    getImages();
  }

  @override
  Widget build(BuildContext context) {

    getFont();

    Container imageList;

    //if the user has no images stored currently, then create a list with one panel that tells the user they can add photos and images
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
    //else, display the list of images, it is a horizontal list view of cards that are 150px in size, where the images cover the card
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
                         //widget that detects gestures made by a user
                         child: GestureDetector(
                          onTap:() {
                            //go to the file viewer page and pass in the image list, and the index of the image tapped
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FileViewer(list: imageFiles, i: index)));
                          },
                           //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
                           //the tag allows both pages to know where to return to when the user presses the back button
                          child: new Hero(
                              tag: "imageView"+index.toString(),
                              //cached network image from URLs retrieved, witha circular progress indicator placeholder until the image has loaded
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
      //display a circular progress indicator when the image list is loading
      imageList =  new Container(child: new Padding(padding: EdgeInsets.all(50.0), child: new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0))));
  }

  //card widget that displays when the user presses the record button
  final Card recordingCard = Card(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0), child: new Text("Recording", textAlign: TextAlign.center, textScaleFactor: 1.5, style: TextStyle(fontFamily: font),)),
            //if the user has stopped the recorder then display a circular progress indicator, else display a large stop button
            recorderLoading ?
            IconButton(
              iconSize: 80.0,
              color: Colors.red,
              icon: Icon(Icons.stop),
              //if the stop button is pressed then stop the recording
              onPressed: () => stopRecording(),
            ) : new Padding(padding: EdgeInsets.all(20.0), child: new SizedBox(width: 45.0, height: 45.0, child: new CircularProgressIndicator(strokeWidth: 5.0))),
          ],
        ),
      )
  );

  //list view for the dummy note data
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

  //scaffold to encapsulate all the widgets
  final page = Scaffold(
      //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
      endDrawer: new Drawer(
        child: ListView(
          //Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            //drawer header
            DrawerHeader(
              child: Text('Settings', style: TextStyle(fontSize: 25.0, fontFamily: font)),
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
            //fonts option
            ListTile(
              leading: Icon(Icons.font_download),
              title: Text('Fonts', style: TextStyle(fontSize: 20.0, fontFamily: font)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings()));
              },
            ),
            //sign out option
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
        //if recording then just display an X icon in the app bar, which when pressed will stop the recorder
        actions: recording ? <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.close),
            iconSize: 30.0,
            onPressed: () => cancelRecording(),
          ),
        ] : <Widget>[
          // else display the mic button and settings button
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
            //stack to display the main widgets; the notes and images
            Stack(
              children: <Widget>[
                new Container(
                  //note container, which is 63% the size of the screen
                  height: MediaQuery.of(context).size.height * 0.63,
                  alignment: Alignment.topCenter,
                  child: textFileList,
                ),
                new Container(
                  //container for the image buttons, one for getting images from the gallery and one for getting images from the camera
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
                        //display the image list
                        imageList,
                      ],
                    ),
                  ),
                  //container for the recording card, show if recording, show blank container if not
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
                //container for the circular progress indicator when submitting an image, show if submitting, show blank container if not
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

  //method for getting an image from the gallery
  void getImage() async
  {
    //use filepicker to retrieve image from gallery
    String image = await FilePicker.getFilePath(type: FileType.IMAGE);

    //if image is not null then upload the image and add the url to the image files list
    if (image != null) {
      String url = await uploadPhoto(image);

      setState(() {
        if (image != null) {
          imageFiles.add(url);
        }
      });
    }
  }

  //method for getting an image from the camera
  void getCameraImage() async
  {
    //use filepicker to retrieve image from camera
    String image = await FilePicker.getFilePath(type: FileType.CAPTURE);

    //if image is not null then upload the image and add the url to the image files list
    if (image != null) {
      String url = await uploadPhoto(image);

      setState(() {
        if (image != null) {
          imageFiles.add(url);
        }
      });
    }
  }

  //alert dialog thats displayed when the recorder could not understand your command
  void showCannotUnderstandError()
  {
    //cancel the recording
    cancelRecording();

    AlertDialog cannotUnderstand = new AlertDialog(
      content: new Text("Sorry, I could not understand you! Please try again", style: TextStyle(fontFamily: font),),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK", style: TextStyle(fontFamily: font),))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => cannotUnderstand);
  }

  //alert dialog that notifies the user if an error has occurred
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

  //method that records audio
  void recordAudio() async
  {
    //set the state of the application that recording has begun
    this.setState(() {
      this.recorderLoading = true;
      this.recording = true;
    });

    //get the file URI and start recording
    this.uri =  await flutterSound.startRecorder(null);
    audioSubscription = flutterSound.onRecorderStateChanged.listen((e) {
      if (e != null) {
      }
    });
  }

  //method to cancel recording at any time
  void cancelRecording()
  {
    //set the state of the application that recording has been cancelled
    this.setState(() {
      this.recording = false;
    });

    //cancel the audio subscription
    if (audioSubscription != null) {
      audioSubscription.cancel();
      audioSubscription = null;
    }
  }

  //method called when the user manually stops the recording for their command to be processed
  void stopRecording() async
  {
    //stop the recorder
    await flutterSound.stopRecorder();

    //set the state of the application that recording has been stopped
    this.setState(() {
      this.recorderLoading = false;
    });

    //cancel the audio subscription
    if (audioSubscription != null) {
      audioSubscription.cancel();
      audioSubscription = null;

      //API URL for posting the audio command
      String url = "http://mystudentlife-220716.appspot.com/command";

      SharedPreferences prefs = await SharedPreferences.getInstance();

      //create file object from audio URI
      File file = new File.fromUri(new Uri.file(this.uri));

      //post the form data with the audio file
      FormData formData = new FormData.from({
        "id": await prefs.getString("id"),
        "refreshToken": await prefs.getString("refreshToken"),
        "file": new UploadFileInfo(file, this.uri),
      });

      var responseObj;

      try
      {
        //post the form data and retrieve the response
        responseObj = await dio.post(url, data: formData);

        //delete the audio file
        File currentAudio = File.fromUri(new Uri.file(this.uri));
        currentAudio.deleteSync();

        //if the function is null then set the state of the application that recording has stopped
        if(responseObj.data['function'] == null) {

          this.setState(() {
            this.recording = false;
          });

          //show cannot understand error
          showCannotUnderstandError();
        }
        else {
          //else check if the function is timetable
          if (responseObj.data['function'] == "timetable") {

            //set the state of the application that recording has stopped
            this.setState(() {
              this.recording = false;
            });

            //static list of days
            List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

            //if the day from the response object is not in the list, then display and error saying the user does not have classes for that day
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
              //else go to the timetables page and pass in the day
              Navigator.push(context, MaterialPageRoute(builder: (context) => TimetablePage(initialDay: responseObj.data['day'])));
            }
          }
          else{
            //else display cannot understand error
            showCannotUnderstandError();
          }
        }
      }
      on DioError catch(e)
      {
        //set the state of the application that recording has stopped
        this.setState(() {
          this.recording = false;
        });

        //show cannot understand error
        showCannotUnderstandError();
      }
    }
  }

  //method to display sign out dialog that notifies user that they will be signed out, when OK is pressed, handle the sign out
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

  //clear relevant shared preference data
  void handleSignOut() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("id");
    await prefs.remove("refreshToken");

    //clear the widget stack and route user to the login page
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
  }

  //method for uploading user chosen image
  Future<String> uploadPhoto(String filePath) async
  {
    //API URL for submitting a photo
    String url = "http://mystudentlife-220716.appspot.com/photo";

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form with relevant data and image as file
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "file": new UploadFileInfo(new File(filePath), new DateTime.now().millisecondsSinceEpoch.toString()+filePath.split('/').last)
    });

    submit(true);

    try {
      //post the form data to the url
      var responseObj = await dio.post(url, data: formData);

      //if the refresh token is null, then display an alert dialog with an error
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
        //else store the new refresh token in shared preferences and return the image URL
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        submit(false);
        return responseObj.data['url'];
      }
    }
    on DioError catch(e)
    {
      submit(false);
      //display error dialog
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
