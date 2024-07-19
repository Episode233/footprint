library universal_ui;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'responsive_widget.dart';
import 'fake_ui.dart' if (dart.library.html) 'real_ui.dart' as ui_instance;

class PlatformViewRegistryFix {
  void registerViewFactory(dynamic x, dynamic y) {
    if (kIsWeb) {
      ui_instance.PlatformViewRegistry.registerViewFactory(
        x,
        y,
      );
    }
  }
}

class UniversalUI {
  PlatformViewRegistryFix platformViewRegistry = PlatformViewRegistryFix();
}

var ui = UniversalUI();

class ImageEmbedBuilderWeb implements EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
  ) {
    final imageUrl = node.value.data;
    if (isImageBase64(imageUrl)) {
      // TODO: handle imageUrl of base64
      return const SizedBox();
    }
    final image = Image.network(imageUrl);
    var width = 4.obs;
    var height = 3.obs;
    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener(
      (ImageInfo info, bool _) {
        width(info.image.width);
        height(info.image.height);
      },
    ));
    final size = MediaQuery.of(context).size;
    UniversalUI().platformViewRegistry.registerViewFactory(
        imageUrl, (viewId) => html.ImageElement()..src = imageUrl);
    return Obx(() {
      var showWidth = size.width;
      var showHeight = showWidth * height() / width();
      if (size.width > 650) {
        showHeight /= 2;
      }
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (size.width - showWidth) / 2,
        ),
        child: SizedBox(
          height: showHeight,
          child: HtmlElementView(
            viewType: imageUrl,
          ),
        ),
      );
    });
  }
}

class VideoEmbedBuilderWeb implements EmbedBuilder {
  @override
  String get key => BlockEmbed.videoType;

  @override
  Widget build(BuildContext context, QuillController controller, Embed node,
      bool readOnly) {
    var videoUrl = node.value.data;

    UniversalUI().platformViewRegistry.registerViewFactory(
        videoUrl,
        (id) => html.IFrameElement()
          ..width = MediaQuery.of(context).size.width.toString()
          ..height = MediaQuery.of(context).size.height.toString()
          ..src = videoUrl
          ..style.border = 'none');

    return SizedBox(
      height: 500,
      child: HtmlElementView(
        viewType: videoUrl,
      ),
    );
  }
}

List<EmbedBuilder> get defaultEmbedBuildersWeb => [
      ImageEmbedBuilderWeb(),
      VideoEmbedBuilderWeb(),
    ];
