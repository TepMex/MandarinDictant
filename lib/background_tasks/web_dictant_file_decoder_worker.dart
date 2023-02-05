import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:js/js.dart';

main() {
  allowInterop(decodeZip);
}

// NOTE: To get valid JS-worker
// dart compile js .\lib\background_tasks\web_dictant_file_decoder_worker.dart -o .\web\dictant_file_decoder.js
// remove IIFE declaration
// https://stackoverflow.com/questions/72495706/is-it-possible-to-only-convert-a-dart-function-to-javascript
// NOTE: NOW JS CODE IS MANUALLY EDITED AND ALMOST WORKS
// TODO: Consider using JS-native approach in worker and JSZip library
@JS('decodeZip')
Map decodeZip(Uint8List? bytes) {
  var archive = ZipDecoder().decodeBytes(bytes as List<int>);
  final filesInZip = <String, Uint8List>{};
  for (final file in archive) {
    filesInZip[file.name] = file.content;
  }
  return filesInZip;
}
