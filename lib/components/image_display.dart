import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vcommunity_flutter/components/notice_snackbar.dart';

class ImageDisplayScreen extends StatefulWidget {
  const ImageDisplayScreen({Key? key}) : super(key: key);

  @override
  State<ImageDisplayScreen> createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    String tag = Get.parameters['path'] ?? "";
    if (tag == '') {
      NoticeSnackBar.showSnackBar("图片不存在", type: NoticeType.ERROR);
      Get.back();
    }
    return GestureDetector(
      onTap: (() {
        Navigator.pop(context);
      }),
      child: Hero(
        tag: tag,
        child: Scaffold(
          body: Center(
            child: PhotoView(imageProvider: NetworkImage(tag)),
          ),
        ),
      ),
    );
  }
}
