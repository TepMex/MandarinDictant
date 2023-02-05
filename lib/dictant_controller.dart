import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mandarin_dictant/models/dictant_item.dart';

class DictantController extends ChangeNotifier {
  bool isContentLoaded = false;
  List<DictantItem> _items = [
    DictantItem(-1, 'filePath', 0, [0], [''], '')
  ];
  int _current = 0;

  Future<void> loadLocalContent() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final files = json.decode(manifestJson) as Map;
    final jsonConfigFile = files.keys
        .firstWhere((key) =>
            key.toString().startsWith('content/Vws4DE7UvtM/') &&
            key.toString().endsWith('.json'))
        .toString();

    var jsonConfigStr = await rootBundle.loadString(jsonConfigFile);
    var jsonConfig = jsonDecode(jsonConfigStr) as List<dynamic>;
    _items =
        jsonConfig.map((jsonItem) => DictantItem.fromJson(jsonItem)).toList();
    isContentLoaded = _items.isNotEmpty;
  }

  void loadZippedContent(Map<String, Uint8List> zipFiles) {
    final jsonConfigFile = zipFiles.keys
        .firstWhere((key) => key.toString().endsWith('.json'), orElse: () => '')
        .toString();
    if (jsonConfigFile.isEmpty || !zipFiles.containsKey(jsonConfigFile)) {
      return;
    }
    var jsonConfigStr = utf8.decode(zipFiles[jsonConfigFile] as List<int>);
    var jsonConfig = jsonDecode(jsonConfigStr) as List<dynamic>;
    _items =
        jsonConfig.map((jsonItem) => DictantItem.fromJson(jsonItem)).toList();
    for (var item in _items) {
      if (!zipFiles.containsKey(item.filePath)) {
        continue;
      }
      item.bytes = zipFiles[item.filePath]!;
    }
    isContentLoaded = _items.isNotEmpty;
    _current = 0;
    notifyListeners();
  }

  nextTask() {
    if (_items.length > _current) {
      _current++;
    }
    //notifyListeners();
  }

  get currentItem {
    return _items[_current];
  }
}
