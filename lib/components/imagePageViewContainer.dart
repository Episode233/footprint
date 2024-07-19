import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageViewContainer extends StatefulWidget {
  String url;
  PageViewContainer(this.url, {super.key});

  @override
  State<PageViewContainer> createState() => _PageViewContainerState();
}

class _PageViewContainerState extends State<PageViewContainer>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InkWell(
      onTap: () {
        Get.toNamed("/imageView?path=${widget.url}");
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.url), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
