import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'login_page.dart';

//Widget that displays the settings that allow the user to change the font used in the application
class FontSettings extends StatefulWidget {
  @override
  _FontSettingsState createState() => _FontSettingsState();
}

class _FontSettingsState extends State<FontSettings> {

  //placeholder for current font
  String currentFont = "";
  bool uploadingFont = false;

  //Dio object, used to make rich HTTP requests
  Dio dio = new Dio();


  void initState() {
    getCurrentFont();
  }

  //get current font from shared preferences if present
  void getCurrentFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      currentFont = prefs.getString("font");
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = Scaffold(
      //drawer for the settings, can be accessed by swiping inwards from the right hand side of the screen or by pressing the settings icon
      endDrawer: new Drawer(
        child: ListView(
          //Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            //drawer header
            DrawerHeader(
              child: Text('Settings', style: TextStyle(fontSize: 25.0, fontFamily: currentFont)),
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
            //fonts option
            ListTile(
              leading: Icon(Icons.font_download),
              title: Text('Fonts', style: TextStyle(fontSize: 20.0, fontFamily: currentFont)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FontSettings()));
              },
            ),
            //sign out option
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out', style: TextStyle(fontSize: 20.0, fontFamily: currentFont)),
              onTap: () {
                signOut();
              },
            ),
          ],
        ),
      ),
        appBar: new AppBar(
          title: new Text("Thomas Delaney"),
          actions: <Widget>[
            // action button for settings
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
          //create stack to layout all the following widgets
          new Stack(
            children: <Widget>[
              new Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 0.0),
                //dropdown for choosing the current font, the current fonts are stored in the assets folder
                child: new DropdownButton<String>(
                  //initial value
                  value: this.currentFont == "" ? null : this.currentFont,
                  hint: new Text("Choose a Font", style: TextStyle(fontSize: 20.0)),
                  items: <String>['Roboto', 'NotoSansTC', 'Montserrat'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value,  style: TextStyle(fontSize: 20.0)),
                    );
                  }).toList(),
                  //when the font is changed in the dropdown, change the current font state
                  onChanged: (String val){
                    setState(() {this.currentFont = val;});
                  },
                ),
              ),
              //container to display a piece of text, which shows off how the new font looks when selected from the dropdown
              new Container(alignment: Alignment.center, child: Text("Test the Font Here!", style: TextStyle(fontFamily: this.currentFont, fontSize: 35.0))),
              //container for button that submits the new font
              new Container(
                  padding: EdgeInsets.all(10.0),
                  alignment: Alignment.topRight,
                  child: new RaisedButton(
                    child: const Text('Okay', style: TextStyle(color: Colors.white)),
                    color: Theme.of(context).accentColor,
                    elevation: 4.0,
                    splashColor: Colors.blueGrey,
                    onPressed: () {
                      //if the font is empty, show a snackbar with an error
                      this.currentFont == "" ? Scaffold.of(context).showSnackBar(new SnackBar(content: Text('Please Choose a new Font!'))) : changeFont(context);
                    },
                  )
              ),
              new Container(
                //if submitting font, show a circular progress indicator, with a modal barrier which ensures the user cannot interact with the app while submitting
                  alignment: Alignment.center,
                  child: uploadingFont ? new Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      new Container(
                          margin: MediaQuery.of(context).padding,
                          child: new ModalBarrier(color: Colors.black54, dismissible: false,)), new SizedBox(width: 50.0, height: 50.0, child: new CircularProgressIndicator(strokeWidth: 5.0,))
                    ],
                  )
                  : new Container()
              ),
            ],
          ),
        ),
    );

    return page;
  }

  //method to submit the new font
  void changeFont(BuildContext _context) async
  {
    //API URL for changing font
    String url = "http://mystudentlife-220716.appspot.com/font";

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //create form data for the request, with the new font
    FormData formData = new FormData.from({
      "id": await prefs.getString("id"),
      "refreshToken": await prefs.getString("refreshToken"),
      "font": currentFont
    });

    submit(true);

    try {
      //post the request and retrieve the response data
      var responseObj = await dio.post(url, data: formData);

      //if the refresh token is null, then print the error in the logs and show an error dialog
      if(responseObj.data['refreshToken'] == null) {
        print(responseObj.data['response']);

        showErrorDialog();
      }
      //else store the new refresh token and font in shared preferences, and display snackbar the font has been updated
      else {
        await prefs.setString("refreshToken", responseObj.data['refreshToken']);
        await prefs.setString("font", currentFont);
        Scaffold.of(_context).showSnackBar(new SnackBar(content: Text('Font Updated!!')));
        submit(false);
      }
    }
    //catch error and display error doalog
    on DioError catch(e)
    {
      print(e);
      showErrorDialog();
    }
  }

  //change submission state
  void submit(bool state)
  {
    setState(() {
      uploadingFont = state;
    });
  }

  //create an error alert dialog and display it to the user
  void showErrorDialog()
  {
    submit(false);

    AlertDialog errorDialog = new AlertDialog(
      content: new Text("An Error has occured. Please try again"),
      actions: <Widget>[
        new FlatButton(onPressed: () {Navigator.pop(context);}, child: new Text("OK"))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => errorDialog);
  }

  //method which displays a dialog telling the user that they are about to be signed out, if they press okay then handle the sign out
  void signOut()
  {
    AlertDialog signOutDialog = new AlertDialog(
      content: new Text("You are about to be Signed Out", style: TextStyle(fontFamily: currentFont)),
      actions: <Widget>[
        new FlatButton(onPressed: () => handleSignOut(), child: new Text("OK", style: TextStyle(fontFamily: currentFont)))
      ],
    );

    showDialog(context: context, barrierDismissible: false, builder: (_) => signOutDialog);
  }

  //clear shared preference information and route user back to the log in page
  void handleSignOut() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
    await prefs.remove("id");
    await prefs.remove("refreshToken");


    Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (Route<dynamic> route) => false);
  }
}
