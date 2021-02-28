import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'gradient_fab.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget(this.videoUrl);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState(videoUrl);
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final VideoPlayerController videoPlayerController;
  final String videoUrl;
  double videoDuration = 0;
  double currentDuration = 0;

  _VideoPlayerWidgetState(this.videoUrl)
      : videoPlayerController = VideoPlayerController.network(videoUrl);

  @override
  void initState() {
    super.initState();
    videoPlayerController.initialize().then((_) {
      setState(() {
        videoDuration =
            videoPlayerController.value.duration.inMilliseconds.toDouble();
      });
    });

    videoPlayerController.addListener(() {
      setState(() {
        currentDuration =
            videoPlayerController.value.position.inMilliseconds.toDouble();
      });
    });
    print(videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Container(
              color: Colors.black,
              // This line set the transparent background
              child: Container(
                  color: Colors.black87,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        child: BackButton(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        color: Colors.black87,
                        alignment: Alignment.center,
                        constraints: BoxConstraints(maxHeight: 400),
                        child: videoPlayerController.value.initialized
                            ? AspectRatio(
                          aspectRatio: videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(videoPlayerController),
                        )
                            : CircularProgressIndicator(

                        ),
                      ),
                      Slider(
                        activeColor: Colors.white,
                        value: currentDuration,
                        max: videoDuration,
                        onChanged: (value) => videoPlayerController
                            .seekTo(Duration(milliseconds: value.toInt())),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: IconButton(
                          icon: videoPlayerController.value.isPlaying
                              ? new Icon(Icons.pause, color: Colors.white)
                              : new Icon(Icons.play_arrow, color: Colors.white),
                          onPressed: () => setStateVideoPlayerController(),
                        ),
                      )],
                  )),
            ),
          )
        ),
      )
    );
  }

  void setStateVideoPlayerController() {
    setState(() {
      videoPlayerController.value.isPlaying
          ? videoPlayerController.pause()
          : videoPlayerController.play();
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }
}
