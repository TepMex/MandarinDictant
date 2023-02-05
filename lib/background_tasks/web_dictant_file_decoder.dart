import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:isolated_worker/js_isolated_worker.dart';

class WebDictantFileDecoder {
  Future<Archive> decode(Uint8List? bytes) async {
    print(bytes?.length ?? 'zalupa no bytes');
    final bool loaded = await JsIsolatedWorker()
        .importScripts(['../../web/dictant_file_decoder.js']);
    if (loaded) {
      var result = await JsIsolatedWorker()
          .run(functionName: ['A', 'decodeZip'], arguments: bytes);
      var resultObj = jsonDecode(result) as Map<String, dynamic>;
      final filesInZip = <String, Uint8List>{};
      for (final file in resultObj.keys) {
        print(file);
        filesInZip[file] = jsonDecode(resultObj[file]) as Uint8List;
      }
      print(filesInZip);
    } else {
      print('zalupa not loaded');
    }

    return Future.value(Archive());
  }
}
