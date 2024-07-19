import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/constants.dart';

class ImageCardWithShow extends StatelessWidget {
  ImageCardWithShow(this.borderRadius, this.size,
      {super.key, this.url, this.hasHero = true});
  String? url;
  bool hasHero;
  final double size;
  final BorderRadiusGeometry borderRadius;
  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
            borderRadius: borderRadius, color: Colors.transparent),
      );
    }

    if (hasHero) {
      InkWell(
        onTap: () => Get.toNamed("/imageView?path=$url"),
        child: Hero(
          tag: url!,
          child: Container(
            height: size,
            width: size,
            //超出部分，可裁剪
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
            ),
            child: Image.network(
              url!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    return InkWell(
      onTap: () => Get.toNamed("/imageView?path=$url"),
      child: Container(
        height: size,
        width: size,
        //超出部分，可裁剪
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
        ),
        child: Image.network(
          url!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
