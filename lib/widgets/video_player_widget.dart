import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mandarin_dictant/dictant_bloc.dart';
import 'package:mandarin_dictant/models/dictant_item.dart';
import 'package:mandarin_dictant/video_utils/io_bytes_parser.dart';
import 'package:mandarin_dictant/video_utils/web_bytes_parser.dart';
import 'package:video_player/video_player.dart';

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
    return BlocBuilder<DictantBloc, DictantItem>(builder: (context, item) {
      if (item.bytes.isEmpty) {
        return const Text('error');
      }
      if (kIsWeb) {
        _controller =
            VideoPlayerController.network(WebBytesParser.parse(item.bytes));
      } else {
        _controller =
            VideoPlayerController.file(IoBytesParser.parse(item.bytes));
      }
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
                  : const Icon(Icons.play_arrow),
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
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var widthCoeff = 1;
    var heightCoeff = 0.75;
    if (screenHeight > screenWidth) {
      heightCoeff = 0.5;
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthCoeff,
      height: MediaQuery.of(context).size.height * heightCoeff,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
