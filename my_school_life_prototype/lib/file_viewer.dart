import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:photo_view/photo_view.dart';

//Widget that displays an interactive file list
class FileViewer extends StatefulWidget
{
  FileViewer({Key key, this.list, this.i}) : super(key: key);

  //list of file URLS
  final List<String> list;

  //current selected index (passed in from page in which it was invoked)
  final int i;

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer>
{
  @override
  Widget build(BuildContext context) {
    return Container(
      //hero animation for moving smoothly from the page in which the image was selected, to the file viewer
      //the tag allows both pages to know where to return to when the user presses the back button
      child: Hero(tag: "imageView"+widget.i.toString(),
          //swiper widget allows to swipe between a list
          child: new Swiper(
            itemBuilder: (BuildContext context, int index){
              //photo view allows for zooming in and out of images
              return new PhotoView(
                  maxScale: PhotoViewComputedScale.contained * 2.0,
                  minScale: (PhotoViewComputedScale.contained) * 0.5,
                  //get a cached network image from the current URL in the list, this will ensure the image URL does not need to be loaded every time
                  imageProvider: new CachedNetworkImageProvider(widget.list[index]));
            },
            itemCount: widget.list.length,
            pagination: new SwiperPagination(),
            control: new SwiperControl(color: Colors.white70),
            //start the wiper on the index of the image selected
            index: widget.i,
          )
      ),
    );
  }
}
