import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mandarin_dictant/dictant_bloc.dart';
import 'package:mandarin_dictant/dictant_controller.dart';
import 'package:mandarin_dictant/models/dictant_item.dart';
import 'package:mandarin_dictant/video_player_widget.dart';
import 'package:video_player/video_player.dart';

Future<void> initializeContent() async {
  final manifestJson = await rootBundle.loadString('AssetManifest.json');
  final files = json.decode(manifestJson) as Map;
  final jsonConfigFile = files.keys
      .firstWhere((key) =>
          key.toString().startsWith('content/Vws4DE7UvtM/') &&
          key.toString().endsWith('.json'))
      .toString();

  var jsonConfigStr = await rootBundle.loadString(jsonConfigFile);
  var jsonConfig = jsonDecode(jsonConfigStr) as List<dynamic>;
  var test = DictantItem.fromJson(jsonConfig[0]);
  var dictantItems =
      jsonConfig.map((jsonItem) => DictantItem.fromJson(jsonItem)).toList();
  assert(dictantItems.runtimeType == List<DictantItem>);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeContent();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mandarin Dictant',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: BlocProvider(
          create: (_) => DictantBloc(),
          child: const MyHomePage(title: 'Mandarin Dictant')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DictantController _dictantController;
  late Future _contentLoading;
  VideoPlayerWidget videoPlayer = const VideoPlayerWidget();

  @override
  void initState() {
    super.initState();
    _dictantController = DictantController();
    _contentLoading = _dictantController.loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: _contentLoading,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }
              return mainScreen();
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context
                .read<DictantBloc>()
                .nextVideo(_dictantController.nextVideo());
          },
          // child: Icon(
          //   _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          // ),
        ));
  }

  Widget mainScreen() {
    return Center(
      child: videoPlayer,
    );
  }
}
