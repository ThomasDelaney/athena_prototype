import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TimetablePage extends StatefulWidget 
{
  TimetablePage({Key key, this.initialDay}) : super(key: key);

  final String initialDay;
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {

  List<String> weekdays = const <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];

  @override
  Widget build(BuildContext context)
  {
    return Container(
      child: DefaultTabController(
        initialIndex: weekdays.indexOf(widget.initialDay),
        length: weekdays.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Timetables'),
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
                child: TimeslotCard(placeholder: day),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class TimeslotCard extends StatelessWidget {
  const TimeslotCard({Key key, this.placeholder}) : super(key: key);

  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(placeholder, style: textStyle),
          ],
        ),
      ),
    );
  }
}
