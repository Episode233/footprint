import 'package:flutter/services.dart';

class AndroidIntentLauncher {
  static const platform = MethodChannel('com.yourapp/channel');

  static Future<void> launchActivity(String className) async {
    // 创建一个 Map 来传递参数
    final Map<String, String> params = {
      'className': className
    };

    // 使用平台通道调用原生代码
    await platform.invokeMethod('launchActivity', params);
  }
}
