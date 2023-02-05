import 'dart:typed_data';

abstract class DictantFileDecoder {
  Future<Map<String, Uint8List>> decode(Uint8List bytes);
}
