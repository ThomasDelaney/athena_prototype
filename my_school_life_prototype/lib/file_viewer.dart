import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:photo_view/photo_view.dart';

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
      child: Hero(tag: "imageView"+widget.i.toString(),
          child: new Swiper(
            itemBuilder: (BuildContext context, int index){
              return new PhotoView(
                  maxScale: PhotoViewComputedScale.contained * 2.0,
                  minScale: (PhotoViewComputedScale.contained) * 0.5,
                  //initialScale: 1.0,
                  imageProvider: new CachedNetworkImageProvider(widget.list[index]));
            },
            itemCount: widget.list.length,
            pagination: new SwiperPagination(),
            control: new SwiperControl(color: Colors.white70),
            index: widget.i,
          )
      ),
    );
  }
}
