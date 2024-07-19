import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/topicList.dart';
import 'package:vcommunity_flutter/components/card_title.dart';
import 'package:vcommunity_flutter/constants.dart';

class LatestTopic extends StatelessWidget {
  LatestTopic(this.data, {super.key});
  late TopicList data;

  List<Widget> _buildLatestTopicTileList(BuildContext context) {
    List<Widget> widgets = [];
    for (var i in data.topics) {
      widgets.insert(0,
        Padding(
          padding: EdgeInsets.only(right: defaultPadding / 2),
          child: InkWell(
              borderRadius:
                  const BorderRadius.all(Radius.circular(defaultBorderRadius)),
              onTap: () => Get.toNamed('/topic/${i.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 1.5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(defaultBorderRadius)),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                width: 230,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.name,
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary)),
                          Text(
                            '${i.follows}人关注',
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .fontSize,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: defaultPadding / 2,
                    ),
                    SizedBox(
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(defaultBorderRadius)),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        i.icon.removeAllWhitespace == ''
                                            ? defaultAvatar
                                            : i.icon),
                                    fit: BoxFit.cover)),
                          )),
                    ),
                  ],
                ),
              )),
        ),
      );
    }
    return widgets;
  }

  Widget _buildLatestTile(BuildContext context) {
    List<Widget> widgets = _buildLatestTopicTileList(context);
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: widgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(top: defaultPadding),
        elevation: 0,
        child: InkWell(
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultBorderRadius)),
          onTap: () {},
          child: Padding(
              padding: const EdgeInsets.all(defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardTitle('最新话题'),
                  const SizedBox(
                    height: defaultPadding,
                  ),
                  _buildLatestTile(context)
                ],
              )),
        ));
  }
}
