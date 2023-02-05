import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mandarin_dictant/dictant_bloc.dart';
import 'package:mandarin_dictant/dictant_controller.dart';
import 'package:mandarin_dictant/models/dictant_item.dart';
import 'package:mandarin_dictant/video_player_widget.dart';
import 'package:mandarin_dictant/zip_file_picker.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (context) => DictantController(),
    child: const MyApp(),
  ));
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

enum DictantTasks { countSyllables, recognizeTones, recoginizePinyin, cloze }

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final _videoPlayer = const VideoPlayerWidget();
  final _keyEditingController = TextEditingController();
  var _currentTask = DictantTasks.countSyllables;
  var _score = 0;
  var _zipLoadedOnce = false;
  var _lastCorrectAnswer = '';
  final Map<DictantTasks, String> taskDescriptions = {
    DictantTasks.countSyllables: 'How many syllables in this audio fragment?',
    DictantTasks.recoginizePinyin: 'Write pinyin with tone numbers',
    DictantTasks.recognizeTones: 'Write tone numbers',
    DictantTasks.cloze: 'Fill in the gaps',
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Consumer<DictantController>(builder: (context, notifier, widget) {
          return appBody();
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            onAnswer();
          },
          child: const Icon(Icons.check),
        ));
  }

  Widget appBody() {
    if (!Provider.of<DictantController>(context, listen: false)
        .isContentLoaded) {
      return Center(
        child: ZipFilePicker(
            onFilesInZipSelected:
                Provider.of<DictantController>(context, listen: false)
                    .loadZippedContent),
      );
    }
    if (!_zipLoadedOnce) {
      context.read<DictantBloc>().nextItem(
          Provider.of<DictantController>(context, listen: false).currentItem);
      _zipLoadedOnce = true;
    }
    return mainScreen();
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
      Provider.of<DictantController>(context, listen: false).nextTask();
      _currentTask = DictantTasks.countSyllables;
    });
    context.read<DictantBloc>().nextItem(
        Provider.of<DictantController>(context, listen: false).currentItem);
  }

  Widget mainScreen() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: $_score',
              style: const TextStyle(fontSize: 36),
            ),
          ],
        ),
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
    var currentItem =
        Provider.of<DictantController>(context, listen: false).currentItem;
    switch (_currentTask) {
      case DictantTasks.countSyllables:
        return checkCountSyllables(currentItem, answer);
      case DictantTasks.recognizeTones:
        return checkTones(currentItem, answer);
      case DictantTasks.recoginizePinyin:
        return checkPinyin(currentItem, answer);
      case DictantTasks.cloze:
        return checkCloze(currentItem, answer);
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
      case DictantTasks.cloze:
        // TODO: Handle this case.
        break;
    }
  }

  void showCorrectAnswer() {
    var correctAnswer = '';

    var currentItem =
        Provider.of<DictantController>(context, listen: false).currentItem;
    switch (_currentTask) {
      case DictantTasks.countSyllables:
        correctAnswer = currentItem.syllableCount.toString();
        break;
      case DictantTasks.recognizeTones:
        correctAnswer = currentItem.tones.join(', ');
        break;
      case DictantTasks.recoginizePinyin:
        correctAnswer = currentItem.pinyinSyllables.join(' ');
        break;
      case DictantTasks.cloze:
        // TODO: Handle this case.
        break;
    }

    setState(() {
      _lastCorrectAnswer = correctAnswer;
    });
  }

  bool checkCloze(DictantItem currentDictant, answer) {
    return false;
  }
}
