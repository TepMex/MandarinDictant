import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mandarin_dictant/models/dictant_item.dart';

class DictantController extends ChangeNotifier {
  bool isContentLoaded = false;
  List<DictantItem> _items = List.empty();

  Future<void> loadContent() async {
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

  nextVideo() {
    if (_items.isNotEmpty) {
      return _items.last.filePath;
    }

    return '';
  }
}
