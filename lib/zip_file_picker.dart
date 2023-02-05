import 'dart:typed_data';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:mandarin_dictant/background_tasks/io_dictant_file_decoder.dart';
import 'package:mandarin_dictant/background_tasks/sync_dictant_file_decoder.dart';
import 'package:mandarin_dictant/background_tasks/web_dictant_file_decoder.dart';

class ZipFilePicker extends StatefulWidget {
  final ValueChanged<Map<String, Uint8List>> onFilesInZipSelected;

  const ZipFilePicker({Key? key, required this.onFilesInZipSelected})
      : super(key: key);

  @override
  ZipFilePickerState createState() => ZipFilePickerState();
}

class ZipFilePickerState extends State<ZipFilePicker> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return buttonOrLoader();
  }

  Widget buttonOrLoader() {
    if (_isLoading) {
      return const CircularProgressIndicator.adaptive();
    }
    return ElevatedButton(
      onPressed: _pickZip,
      child: const Text('Pick Zip'),
    );
  }

  void _pickZip() async {
    setState(() {
      _isLoading = true;
    });
    // final filePickerResult = await FilePicker.platform.pickFiles(
    //   withData: true,
    //   type: FileType.any,
    //   onFileLoading: (p0) => print(p0.name),
    // );
    FilePickerCross filePickerResult = await FilePickerCross.importFromStorage(
        type: FileTypeCross
            .custom, // Available: `any`, `audio`, `image`, `video`, `custom`. Note: not available using FDE
        fileExtension:
            'dictant' // Only if FileTypeCross.custom . May be any file extension like `dot`, `ppt,pptx,odp`
        );
    final zipFile = filePickerResult.toUint8List();
    final decoder = kIsWeb ? SyncDictantFileDecoder() : IoDictantFileDecoder();
    final filesInZip = await decoder.decode(zipFile);
    widget.onFilesInZipSelected(filesInZip);
    setState(() {
      _isLoading = false;
    });
  }
}
