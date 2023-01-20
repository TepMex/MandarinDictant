import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mandarin_dictant/dictant_bloc.dart';
import 'package:mandarin_dictant/dictant_controller.dart';
import 'package:mandarin_dictant/models/dictant_item.dart';
import 'package:mandarin_dictant/video_player_widget.dart';

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
  var _currentTask = DictantTasks.countSyllables;
  var _score = 0;
  var _lastCorrectAnswer = '';
  final Map<DictantTasks, String> taskDescriptions = {
    DictantTasks.countSyllables: 'How many syllables in this audio fragment?',
    DictantTasks.recoginizePinyin: 'Write pinyin with tone numbers',
    DictantTasks.recognizeTones: 'Write tone numbers',
  };

  @override
  void initState() {
    super.initState();
    _dictantController = DictantController();
    _contentLoading = _dictantController
        .loadContent()
        .then((value) => _currentDictant = _dictantController.nextTask());
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
            onAnswer();
          },
          child: const Icon(Icons.check),
        ));
  }

  void onAnswer() {
    var answer = _keyEditingController.text;
    var isCorrect = checkAnswer(answer);
    if (isCorrect) {
      setState(() {
        _score += pow(2, _currentTask.index) as int;
      });
    }
    showCorrectAnswer();

    _keyEditingController.clear();
    nextTaskOrNextPart();
  }

  void nextTaskOrNextPart() {
    if (_currentTask == DictantTasks.recoginizePinyin) {
      goToNextPart();
      return;
    }

    goToNextTask();
  }

  void goToNextTask() {
    var nextTask = getNextTask(_currentTask);
    setState(() {
      _currentTask = nextTask;
    });
  }

  void goToNextPart() {
    setState(() {
      _currentDictant = _dictantController.nextTask();
      _currentTask = DictantTasks.countSyllables;
    });
    context.read<DictantBloc>().nextVideo(_currentDictant.filePath);
  }

  Widget mainScreen() {
    return Column(
      children: [
        Center(
            child: Text(
          'Score: $_score',
          style: const TextStyle(fontSize: 36),
        )),
        Center(
          child: _videoPlayer,
        ),
        TextField(
          controller: _keyEditingController,
          onSubmitted: (value) {
            onAnswer();
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: taskDescriptions[_currentTask]),
        ),
        Center(
            child: Text(
          'Last correct anwer: $_lastCorrectAnswer',
          style: const TextStyle(fontSize: 24),
        )),
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
    var answArr = answer.split('');
    for (var i = 0; i < answArr.length; i++) {
      if (int.parse(answArr[i]) != currentDictant.tones[i]) {
        return false;
      }
    }
    return true;
  }

  bool checkPinyin(DictantItem currentDictant, String answer) {
    var answArr = answer.split(' ');
    for (var i = 0; i < answArr.length; i++) {
      if (answArr[i] != currentDictant.pinyinSyllables[i]) {
        return false;
      }
    }
    return true;
  }

  getNextTask(DictantTasks currentTask) {
    switch (currentTask) {
      case DictantTasks.countSyllables:
        return DictantTasks.recognizeTones;
      case DictantTasks.recognizeTones:
        return DictantTasks.recoginizePinyin;
      case DictantTasks.recoginizePinyin:
        return DictantTasks.recoginizePinyin;
    }
  }

  void showCorrectAnswer() {
    var correctAnswer = '';
    switch (_currentTask) {
      case DictantTasks.countSyllables:
        correctAnswer = _currentDictant.syllableCount.toString();
        break;
      case DictantTasks.recognizeTones:
        correctAnswer = _currentDictant.tones.join(', ');
        break;
      case DictantTasks.recoginizePinyin:
        correctAnswer = _currentDictant.pinyinSyllables.join(' ');
        break;
    }

    setState(() {
      _lastCorrectAnswer = correctAnswer;
    });
  }
}
