import 'dart:io';
import 'dart:typed_data';

class IoBytesParser {
  static File parse(Uint8List bytes) {
    return File.fromRawPath(bytes);
  }
}
