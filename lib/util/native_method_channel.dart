import 'package:flutter/services.dart';

class NativeMethodChannel {

  static String blogList = '';

  static const MethodChannel methodChannel = MethodChannel("NativeMethodChannel");

  static Future<void> showAugmentedReality() async {
    await methodChannel.invokeMethod(
      'showAugmentedReality',
      blogList,
    );
  }

}