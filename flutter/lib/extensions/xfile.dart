import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

extension XFilExt on XFile {
  Future<MultipartFile> toMultipartFile() async {
    if (kIsWeb) {
      return MultipartFile.fromBytes(await readAsBytes(), filename: name);
    } else {
      // Mobile (IO-based) handling
      return await MultipartFile.fromFile(path, filename: name);
    }
  }
}
