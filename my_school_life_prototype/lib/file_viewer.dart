import 'package:flutter/material.dart';

class FileViewer extends StatefulWidget
{
  FileViewer({Key key, this.list, this.i}) : super(key: key);

  static const String routeName = "/HomePage";
  final List<String> list;
  final int i;


  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer>
{

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Hero(tag: "imageView"+widget.i.toString(), child: Image.network(widget.list[widget.i])),
    );
  }
}
