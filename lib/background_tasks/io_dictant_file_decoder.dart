import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:mandarin_dictant/background_tasks/dictant_file_decoder.dart';

class IoDecodingTask {
  List<int> bytes;
  SendPort sendPort;
  IoDecodingTask(this.bytes, this.sendPort);
}

class IoDictantFileDecoder extends DictantFileDecoder {
  void backgroundDecode(IoDecodingTask task) {
    final decoded = ZipDecoder().decodeBytes(task.bytes);
    task.sendPort.send(decoded);
  }

  @override
  Future<Map<String, Uint8List>> decode(Uint8List? bytes) async {
    final receivePort = ReceivePort();
    IoDecodingTask task =
        IoDecodingTask(bytes as List<int>, receivePort.sendPort);
    await Isolate.spawn<IoDecodingTask>(backgroundDecode, task);
    final archive = await receivePort.first as Archive;

    final filesInZip = <String, Uint8List>{};
    for (final file in archive) {
      filesInZip[file.name] = file.content;
    }

    return filesInZip;
  }
}
