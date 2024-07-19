import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Model/blog.dart';
import '../../../components/quill_config.dart';
import '../../../constants.dart';

class BlogItemInMap extends StatelessWidget {
  Blog blog;
  String dateInfo = '';
  String distInfo = '';
  BlogItemInMap(this.blog, {super.key});

  Widget userWidget(var context, bool isMale) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 40),
      // width: 40,
      padding: const EdgeInsets.only(right: defaultPadding / 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundImage: NetworkImage(blog.user?.icon ?? defaultAvatar),
          ),
          // const SizedBox(
          //   width: defaultPadding / 6,
          // ),

          Text(
            blog.user?.nickName ?? '已删除用户',
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 8,
              overflow: TextOverflow.ellipsis,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Icon(
          //   isMale ? Icons.female_rounded : Icons.male_rounded,
          //   color: isMale ? Colors.pinkAccent : Colors.blue,
          //   size: 8,
          // ),
          Text(
            dateInfo,
            style: TextStyle(
              fontSize: 7,
              color: Theme.of(context).colorScheme.secondary,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            distInfo,
            style: TextStyle(
              fontSize: 7,
              color: Theme.of(context).colorScheme.tertiary,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMale = blog.user?.gender ?? false;
    bool hasTitle = blog.title != '';
    List<Widget> imageList = [];
    List<Widget> topicList = [];
    List<Widget> posList = [];
    dateInfo = calculateTimeDifference(blog.createTime);
    distInfo = calculateLocationDifference(blog.distanceValue);
    return Hero(
      tag: '/blog/${blog.id}',
      child: Material(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius)),
        borderOnForeground: false,
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/blog/${blog.id}'),
          child: Container(
            clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.fromLTRB(
                  defaultPadding / 4, defaultPadding / 4, 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withAlpha(50),
                      offset: const Offset(4, 3.4),
                      blurRadius: 6,
                      spreadRadius: 1.5)
                ],
                color: Theme.of(context).colorScheme.background,
              ),
              child: Row(
                children: [
                  userWidget(context, isMale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        hasTitle
                            ? Text(
                                blog.title,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8),
                              )
                            : const SizedBox(),
                        Expanded(
                          child: AbsorbPointer(
                            child: Container(
                              padding:
                                  const EdgeInsets.only(bottom: defaultPadding),
                              clipBehavior: Clip.hardEdge,
                              // constraints: const BoxConstraints(maxHeight: 30),
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(
                                          defaultBorderRadius))),
                              child: QuillConfig()
                                  .onlyShowSmall(context, blog.content),
                            ),
                          ),
                        ),
                        Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(defaultBorderRadius)),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: defaultPadding / 6,
                            runSpacing: defaultPadding / 6,
                            children: imageList,
                          ),
                        ),
                        Row(
                          children: topicList,
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  String calculateTimeDifference(DateTime datetime) {
    DateTime now = DateTime.now();
    Duration diff = now.difference(datetime);

    if (diff.inSeconds < 60) {
      return "不足一分钟前";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} 分钟前";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} 小时前";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} 天前";
    } else {
      return "${datetime.year} 年 ${datetime.month} 月 ${datetime.day} 日";
    }
  }

  String calculateLocationDifference(double distance) {
    if (distance == -1) {
      return '';
    }
    if (distance < 50) {
      return "不足50m";
    } else if (distance < 100) {
      return "不足100m";
    } else if (distance < 500) {
      return "不足500m";
    } else if (distance < 1000) {
      return "不足1km";
    } else {
      return "${distance ~/ 1000}km";
    }
  }
}
