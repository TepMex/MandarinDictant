import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mandarin_dictant/dictant_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'content/Vws4DE7UvtM/dummy.mp4',
    );

    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DictantBloc, String>(builder: (context, nextUri) {
      var nextPath = p.join('content', nextUri);
      _controller = VideoPlayerController.asset(nextPath);
      _initializeVideoPlayerFuture = _controller.initialize();
      return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return videoPlayerScreen();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    });
  }

  Widget videoPlayerScreen() {
    return Row(
      children: [
        const Spacer(flex: 1),
        Column(
          children: [videoContent(), videoControlButtons()],
        ),
        const Spacer(
          flex: 1,
        )
      ],
    );
  }

  Center videoControlButtons() {
    return Center(
      child: ButtonBar(
        children: [
          ElevatedButton(
              child: _controller.value.isPlaying
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.replay),
              onPressed: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                  return;
                }
                _controller.play();
              })
        ],
      ),
    );
  }

  SizedBox videoContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
