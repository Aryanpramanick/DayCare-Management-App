import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/*
* This widget is used to display images in the feed
*/
class ImageWidget extends StatefulWidget {
  final String url;

  const ImageWidget({Key? key, required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Image.network(widget.url),
      ),
    );
  }
}
