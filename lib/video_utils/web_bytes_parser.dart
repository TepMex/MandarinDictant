// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';

class WebBytesParser {
  static String parse(Uint8List bytes) {
    Blob blob = Blob([bytes], 'video/mp4');
    return Url.createObjectUrlFromBlob(blob);
  }
}
