import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';

class ZipFilePicker extends StatefulWidget {
  final ValueChanged<Map<String, Uint8List>> onFilesInZipSelected;

  const ZipFilePicker({Key? key, required this.onFilesInZipSelected})
      : super(key: key);

  @override
  ZipFilePickerState createState() => ZipFilePickerState();
}

class ZipFilePickerState extends State<ZipFilePicker> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _pickZip,
      child: const Text('Pick Zip'),
    );
  }

  void _pickZip() async {
    final filePickerResult = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['dictant']);
    if (filePickerResult == null || filePickerResult.files.isEmpty) {
      return;
    }
    final zipFile = filePickerResult.files.first;
    final archive = ZipDecoder().decodeBytes(zipFile.bytes as List<int>);
    final filesInZip = <String, Uint8List>{};
    for (final file in archive) {
      filesInZip[file.name] = file.content;
    }

    widget.onFilesInZipSelected(filesInZip);
  }
}
