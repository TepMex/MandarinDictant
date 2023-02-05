import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:mandarin_dictant/background_tasks/dictant_file_decoder.dart';

class SyncDictantFileDecoder extends DictantFileDecoder {
  @override
  Future<Map<String, Uint8List>> decode(Uint8List? bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes as List<int>);

    final filesInZip = <String, Uint8List>{};
    for (final file in archive) {
      filesInZip[file.name] = file.content;
    }

    return Future.value(filesInZip);
  }
}
