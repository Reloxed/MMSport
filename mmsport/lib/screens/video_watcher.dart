import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/video_player_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoWatcher extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _VideoWatcherState();
  }
}

class _VideoWatcherState extends State<VideoWatcher> {
  String videoUrl;

  Future<String> getVideoUrl() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    videoUrl = sharedPreferences.getString("videoToPlay");
    return videoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getVideoUrl(),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if(snapshot.hasData) {
          return Material(
            child: VideoPlayerWidget(videoUrl),
          );
        } else {
          return loadingHome();
        }
      }
    );
  }

}