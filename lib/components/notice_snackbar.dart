import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NoticeType { SUCCESS, INFO, WARN, ERROR }

class NoticeSnackBar {
  static showSnackBar(String info, {NoticeType type = NoticeType.INFO}) {
    Color bgColor;
    Color fgColor;
    switch (type) {
      case NoticeType.SUCCESS:
        {
          bgColor = Colors.green;
          fgColor = Colors.white;
        }
        break;
      case NoticeType.INFO:
        {
          bgColor = Colors.blueAccent;
          fgColor = Colors.white;
        }
        break;
      case NoticeType.WARN:
        {
          bgColor = const Color.fromARGB(255, 255, 165, 91);
          fgColor = Colors.white;
        }
        break;
      case NoticeType.ERROR:
        {
          bgColor = Colors.redAccent;
          fgColor = Colors.white;
        }
        break;
    }
    ScaffoldMessenger.of(Get.overlayContext!).showSnackBar(SnackBar(
      content: Text(
        info,
        style: TextStyle(color: fgColor),
      ),
      backgroundColor: bgColor,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
