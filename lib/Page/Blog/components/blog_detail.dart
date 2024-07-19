import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/blog.dart';

import '../../../components/imagePageViewContainer.dart';
import '../../../components/quill_config.dart';
import '../../../constants.dart';
import '../../../util/string_util.dart';

class BlogDetailWidget extends StatefulWidget {
  Blog blog;
  bool notClickReturn;
  BlogDetailWidget(this.blog, {super.key, this.notClickReturn = true});

  @override
  State<BlogDetailWidget> createState() => _BlogDetailWidgetState();
}

class _BlogDetailWidgetState extends State<BlogDetailWidget> {
  final PageController _pageController = PageController();

  late ValueNotifier<double> _pageNotifier;
  late Blog blog;
  int _pos = 0;
  @override
  void initState() {
    super.initState();
    blog = widget.blog;
    _pageNotifier = ValueNotifier(0.0);
    _pageController.addListener(() {
      _pageNotifier.value = _pageController.page!;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  Widget imagePageView(BuildContext context, List<String> images) {
    List<String> backgroundImages = images;
    Size size = MediaQuery.of(context).size;
    double picHeight = min(size.height * 0.6, 350);
    double picWidth =
        size.width > largeScreenWidth ? size.width / 2 : size.width;
    return AnimatedBuilder(
      animation: _pageNotifier,
      builder: (context, _) {
        int currentIndex = _pageNotifier.value.floor();
        int nextPageIndex = currentIndex + 1;
        if (nextPageIndex >= backgroundImages.length) {
          nextPageIndex = 0;
        }
        double t = _pageNotifier.value - currentIndex;

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
                  child: SizedBox(
                    height: picHeight,
                    width: picWidth,
                    child: Image.network(
                      backgroundImages[currentIndex],
                      fit: BoxFit.fill,
                    ),
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
                  child: SizedBox(
                    height: picHeight,
                    width: picWidth,
                    child: Image.network(
                      backgroundImages[nextPageIndex],
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (value) => setState(() {
                _pos = value;
              }),
              itemBuilder: (context, index) {
                return PageViewContainer(images[index]);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasTitle = blog.title != '';
    List<Widget> topicList = [];
    List<Widget> indicater = [];
    int picLen = blog.images.split(',').length;
    Size size = MediaQuery.of(context).size;
    double picHeight = min(size.height * 0.6, 350);
    bool noPic = false;
    List<String> images = [];
    for (var i in blog.images.split(',')) {
      if (i == '') {
        noPic = true;
        break;
      }
      images.add(i);
    }
    for (int i = 0; i < picLen; i++) {
      indicater.add(InkWell(
        onTap: () {
          _pageController.animateToPage(i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.bounceInOut);
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          height: 7,
          width: 7,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: _pos == i
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryContainer),
        ),
      ));
    }
    for (var i in blog.topics) {
      topicList.add(
        Padding(
          padding: const EdgeInsets.only(right: defaultPadding / 3),
          child: TextButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                minimumSize: const Size(1, 1),
                padding: const EdgeInsets.all(3)),
            onPressed: () => Get.toNamed('/topic/${i.id}'),
            icon: CircleAvatar(
              backgroundImage: NetworkImage(i.icon),
              radius: 7,
            ),
            label: Text(
              i.name,
              style: const TextStyle(fontSize: 10, height: 1),
            ),
          ),
        ),
      );
    }
    List<Widget> imageWidget = noPic
        ? []
        : [
            SizedBox(
              height: picHeight,
              child: imagePageView(context, images),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: indicater,
              ),
            ),
          ];
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          // const SizedBox(
          //   height: defaultPadding / 2,
          // ),
          ...imageWidget,
          Padding(
            padding: const EdgeInsets.fromLTRB(
                defaultPadding, 0, defaultPadding, defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hasTitle
                    ? Text(
                        blog.title,
                        maxLines: 2,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .fontSize),
                      )
                    : const SizedBox(),
                Container(
                  padding: const EdgeInsets.only(bottom: defaultPadding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  child: QuillConfig().onlyShowLarge(context, blog.content),
                ),
                Row(
                  children: topicList,
                ),
                Text(
                  '发布于${blog.createTime.toString().split(' ').first}',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
