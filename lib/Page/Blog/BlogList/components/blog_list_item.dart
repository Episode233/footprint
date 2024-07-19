import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/blog.dart';
import 'package:vcommunity_flutter/components/image_card_with_show.dart';
import 'package:vcommunity_flutter/components/quill_config.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

import '../../../../util/string_util.dart';

class BlogListItem extends StatefulWidget {
  BlogListItem(this.blog, {super.key});
  Blog blog;
  @override
  State<BlogListItem> createState() => _BlogListItemState();
}

class _BlogListItemState extends State<BlogListItem> {
  final HttpUtil _httpUtil = Get.find();
  late Blog blog;
  String dateInfo = '';
  String distInfo = '';
  bool isLiking = false;
  @override
  void initState() {
    super.initState();
    blog = widget.blog;
  }

  @override
  Widget build(BuildContext context) {
    bool isMale = blog.user?.gender ?? false;
    bool hasTitle = blog.title != '';
    List<Widget> imageList = [];
    List<Widget> topicList = [];
    Size size = MediaQuery.of(context).size;
    double picSize = min((size.width - defaultPadding * 3), 450);
    int picLen = blog.images.split(',').length;
    bool noPic = false;
    dateInfo = calculateTimeDifference(blog.createTime);
    distInfo = calculateLocationDifference(blog.distanceValue);
    if (!noPic) {
      switch (picLen) {
        case 1:
        case 2:
        case 4:
          {
            picSize = (picSize - defaultPadding / 6) / 2;
          }
          break;
        case 3:
        case 6:
        case 9:
          {
            picSize = (picSize - defaultPadding / 3) / 3;
          }
          break;
        case 5:
        case 7:
        case 8:
          {
            picSize = (picSize - defaultPadding / 3) / 3;
          }
      }
    }
    for (var i in blog.images.split(',')) {
      if (i == '') {
        noPic = true;
        break;
      }
      imageList.add(ImageCardWithShow(
        BorderRadius.circular(3),
        picSize,
        url: i,
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
    List<Widget> posList = [];
    if (distInfo != '') {
      posList = [
        Icon(
          Icons.location_on_rounded,
          color: Theme.of(context).colorScheme.outline,
          size: Theme.of(context).textTheme.labelSmall!.fontSize,
        ),
        Text(
          distInfo,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
            color: Theme.of(context).colorScheme.outline,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: defaultPadding / 2,
        ),
      ];
    }
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(
          defaultPadding, 0, defaultPadding, defaultPadding),
      child: InkWell(
        borderRadius:
            const BorderRadius.all(Radius.circular(defaultBorderRadius)),
        onTap: () {
          Get.toNamed('/blog/${blog.id}');
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              defaultPadding / 2, defaultPadding / 2, defaultPadding / 2, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            color: Get.isDarkMode ? Colors.black : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        NetworkImage(blog.user?.icon ?? defaultAvatar),
                  ),
                  Icon(
                    isMale ? Icons.female_rounded : Icons.male_rounded,
                    color: isMale ? Colors.pinkAccent : Colors.blue,
                    size: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blog.user?.nickName ?? '已删除用户',
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .fontSize,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          dateInfo,
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .fontSize,
                            color: Theme.of(context).colorScheme.outline,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            ...posList,
                            Icon(
                              Icons.credit_card_rounded,
                              color: Theme.of(context).colorScheme.outline,
                              size: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .fontSize,
                            ),
                            Text(
                              blog.user?.introduce ?? '已删除用户',
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .fontSize,
                                color: Theme.of(context).colorScheme.outline,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: defaultPadding,
                  )
                ],
              ),
              const SizedBox(
                height: defaultPadding / 2,
              ),
              hasTitle
                  ? Text(
                      blog.title,
                      maxLines: 2,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              Theme.of(context).textTheme.titleSmall!.fontSize),
                    )
                  : const SizedBox(),
              // AbsorbPointer(
              //   child:
              Container(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                clipBehavior: Clip.hardEdge,
                constraints: const BoxConstraints(maxHeight: 100),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(3)),
                child: QuillConfig().onlyShow(context, blog.content, blog.id),
              ),
              // ),
              const SizedBox(
                height: defaultPadding / 2,
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(defaultBorderRadius)),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: defaultPadding / 6,
                  runSpacing: defaultPadding / 6,
                  children: imageList,
                ),
              ),
              SizedBox(
                height: topicList.isNotEmpty ? defaultPadding / 2 : 0,
              ),
              Row(
                children: topicList,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: handlerThumbUp,
                      icon: Icon(
                        blog.isLike
                            ? Icons.thumb_up_alt_rounded
                            : Icons.thumb_up_alt_outlined,
                        color: Theme.of(context).colorScheme.outline,
                        size: 18,
                      ),
                      label: Text(blog.liked.toString(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline)),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () {
                        Get.toNamed('/blog/${blog.id}');
                      },
                      icon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Theme.of(context).colorScheme.outline,
                        size: 18,
                      ),
                      label: Text(blog.comments.toString(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline)),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () {
                        Get.toNamed('/blog/${blog.id}');
                      },
                      icon: Icon(
                        Icons.visibility_rounded,
                        color: Theme.of(context).colorScheme.outline,
                        size: 18,
                      ),
                      label: Text(blog.views.toString(),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handlerThumbUp() async {
    setState(() {
      isLiking = true;
    });
    if (blog.isLike) {
      await _httpUtil.delete('$apiFollowBlog?id=${blog.id}');
    } else {
      await _httpUtil.post('$apiFollowBlog?id=${blog.id}', {});
    }
    setState(() {
      blog.isLike = !blog.isLike;
      blog.isLike ? blog.liked++ : blog.liked--;
      isLiking = false;
    });
  }
}
