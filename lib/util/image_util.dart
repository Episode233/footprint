import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';

/// 图片压缩 File -> Uint8List
Future<Uint8List?> compressFile(File file) async {
  if (GetPlatform.isMobile) {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
    );
    return result;
  }
  return file.readAsBytes();
}

/// 图片压缩 Uint8List -> Uint8List
Future<Uint8List> comporessList(Uint8List list) async {
  if (GetPlatform.isMobile) {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 1920,
      minWidth: 1080,
      quality: 96,
    );
    return result;
  }
  return list;
}
