import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class TimetablePage extends StatefulWidget 
{
  TimetablePage({Key key, this.initialDay}) : super(key: key);

  final String initialDay;
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {

  List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  String font = "";
  void getFont() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.setState((){font = prefs.getString("font");});
  }

  @override
  Widget build(BuildContext context)
  {
    getFont();

    return Container(
      child: DefaultTabController(
        initialIndex: weekdays.indexOf(widget.initialDay),
        length: weekdays.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Timetables', style: TextStyle(fontFamily: font)),
            bottom: TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.fromLTRB(12.5, 0.0, 12.5, 0.0),
              tabs: weekdays.map((String day) {
                return Tab(
                  text: day,
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: weekdays.map((String day) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: TimeslotCard(placeholder: day, font: font,),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class TimeslotCard extends StatelessWidget {
  const TimeslotCard({Key key, this.placeholder, this.font}) : super(key: key);

  final font;
  final String placeholder;

  final List<Map> subjectMap = const [
        {
          "subject": "Maths",
          "colour": "255,0,0",
          "time": "9:30am",
          "teacher": "Ms. McBride",
          "room": "Maths Room",
        },
        {
          "subject": "Irish",
          "colour": "0,255,0",
          "time": "10:10am",
          "teacher": "Ms. O'Carroll",
          "room": "Irish Room",
        },
        {
          "subject": "Science",
          "colour": "255,0,255",
          "time": "10:50am",
          "teacher": "Ms. Whelan",
          "room": "Science Room",
        },
        {
          "subject": "English",
          "colour": "0,0,255",
          "time": "11:20am",
          "teacher": "Mr. Clarke",
          "room": "English Room",
        },
        {
          "subject": "French",
          "colour": "255,212,0",
          "time": "12:00pm",
          "teacher": "Mr. Brehony",
          "room": "French Room",
        }
      ];

  @override
  Widget build(BuildContext context) {
      return Center(
        child: ListView.builder(
          itemCount: subjectMap.length,
          itemBuilder: (context, position) {
              return Card(
                margin: new EdgeInsets.symmetric(vertical: 6.0),
                elevation: 3.0,
                child: new ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    child: new SizedBox(width: 100.0, height: 25.0, child: Text(
                      subjectMap[position]["time"],
                      style: TextStyle(fontSize: 22.5, fontFamily: font, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  )),
                  title: Text(
                    subjectMap[position]["subject"],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        fontFamily: font, color:
                        Color.fromRGBO(int.parse(subjectMap[position]["colour"].split(',')[0]), int.parse(subjectMap[position]["colour"].split(',')[1]),
                        int.parse(subjectMap[position]["colour"].split(',')[2]), 1.0)),
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.location_on, color: Colors.grey, size: 17.5,),
                            Padding(padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),),
                            Text(
                              subjectMap[position]["room"],
                              style: TextStyle(fontSize: 18.0, fontFamily: font),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.face, color: Colors.grey, size: 17.5,),
                            Padding(padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),),
                            Text(
                              subjectMap[position]["teacher"],
                              style: TextStyle(fontSize: 18.0, fontFamily: font),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.business_center, color: Colors.grey, size: 32.0,),
                ),
              );
            },
          )
        );
  }
}
