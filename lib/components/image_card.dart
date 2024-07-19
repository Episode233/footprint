import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:vcommunity_flutter/constants.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({Key? key, required this.file, required this.deleteCallback})
      : super(key: key);

  final ImageFile file;
  final Function(ImageFile file) deleteCallback;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        Positioned.fill(
            child: Container(
          //超出部分，可裁剪
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
          child: !file.hasPath
              ? Image.memory(
                  file.bytes!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('No Preview'));
                  },
                )
              : Image.file(
                  File(file.path!),
                  fit: BoxFit.cover,
                ),
        )),
        Positioned(
          right: 0,
          top: 0,
          child: InkWell(
            excludeFromSemantics: true,
            onLongPress: () {},
            child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(150),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                )),
            onTap: () {
              deleteCallback(file);
            },
          ),
        ),
      ],
    );
  }
}
