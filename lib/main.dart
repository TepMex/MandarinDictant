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

enum DictantTasks { countSyllables, recognizeTones, recoginizePinyin }

class _MyHomePageState extends State<MyHomePage> {
  late DictantController _dictantController;
  late Future _contentLoading;
  final _videoPlayer = const VideoPlayerWidget();
  final _keyEditingController = TextEditingController();
  late DictantItem _currentDictant;
  final _currentTask = DictantTasks.countSyllables;
  var _score = 0;

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
              _currentDictant = _dictantController.nextTask();
              return mainScreen();
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var answer = _keyEditingController.text;
            var isCorrect = checkAnswer(answer);
            if (isCorrect) {
              setState(() {
                _score++;
              });
            }
            _keyEditingController.clear();
            _currentDictant = _dictantController.nextTask();
            context.read<DictantBloc>().nextVideo(_currentDictant.filePath);
          },
          child: const Icon(Icons.check),
        ));
  }

  Widget mainScreen() {
    return Column(
      children: [
        Center(
          child: _videoPlayer,
        ),
        TextField(
          controller: _keyEditingController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'How many syllables in this audio fragment?'),
        ),
        Text('$_score'),
      ],
    );
  }

  bool checkAnswer(answer) {
    switch (_currentTask) {
      case DictantTasks.countSyllables:
        return checkCountSyllables(_currentDictant, answer);
      case DictantTasks.recognizeTones:
        return checkTones(_currentDictant, answer);
      case DictantTasks.recoginizePinyin:
        return checkPinyin(_currentDictant, answer);
    }
  }

  bool checkCountSyllables(DictantItem currentDictant, String answer) {
    return int.parse(answer) == currentDictant.syllableCount;
  }

  bool checkTones(DictantItem currentDictant, String answer) {
    return false;
  }

  bool checkPinyin(DictantItem currentDictant, String answer) {
    return false;
  }
}
