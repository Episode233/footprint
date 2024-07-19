import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePageView extends StatefulWidget {
  List<String> images;
  ValueNotifier<double> _pageNotifier;
  PageController _pageController;

  int _pos;
  ImagePageView(
    this.images,
    this._pageController,
    this._pageNotifier,
    this._pos, {
    super.key,
  });

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(
    BuildContext context,
  ) {
    super.build(context);
    List<String> images = widget.images;
    List<String> backgroundImages = images;
    Size size = MediaQuery.of(context).size;
    double picHeight = min(size.height * 0.6, 350);
    return AnimatedBuilder(
      animation: widget._pageNotifier,
      builder: (context, _) {
        int currentIndex = widget._pageNotifier.value.floor();
        int nextPageIndex = currentIndex + 1;
        if (nextPageIndex >= backgroundImages.length) {
          nextPageIndex = 0;
        }
        double t = widget._pageNotifier.value - currentIndex;

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: ShaderMask(
                shaderCallback: ((bounds) {
                  return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(1 - t),
                        Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(1 - t)
                      ]).createShader(
                      Rect.fromLTRB(0, 0, bounds.width, bounds.bottom));
                }),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                  child: Image.network(
                    backgroundImages[currentIndex],
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: ShaderMask(
                shaderCallback: ((bounds) {
                  return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.background.withOpacity(t),
                        Theme.of(context).colorScheme.background.withOpacity(t)
                      ]).createShader(
                      Rect.fromLTRB(0, 0, bounds.width, bounds.bottom));
                }),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                  child: Image.network(
                    backgroundImages[nextPageIndex],
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            PageView.builder(
              controller: widget._pageController,
              itemCount: images.length,
              onPageChanged: (value) => setState(() {
                widget._pos = value;
              }),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Get.toNamed("/imageView?path=${images[currentIndex]}");
                  },
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(images[index]),
                            fit: BoxFit.contain),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
