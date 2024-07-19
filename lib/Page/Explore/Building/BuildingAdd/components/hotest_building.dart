import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/topicList.dart';
import 'package:vcommunity_flutter/components/card_title.dart';
import 'package:vcommunity_flutter/constants.dart';

import '../../../../../Model/building.dart';

class HotestBuilding extends StatelessWidget {
  HotestBuilding(this.data, {super.key});
  late BuildingList data;

  List<Widget> _buildHotestBuildingTileList(BuildContext context) {
    List<Widget> widgets = [];
    for (var i in data.buildings) {
      widgets.add(
        InkWell(
            borderRadius:
                const BorderRadius.all(Radius.circular(defaultBorderRadius)),
            onTap: () => Get.toNamed('/building/${i.id}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadius)),
              ),
              height: 140,
              width: 70,
              child: Column(
                children: [
                  SizedBox(
                    width: 50,
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(defaultBorderRadius)),
                              image: DecorationImage(
                                  image: NetworkImage(i.icon),
                                  fit: BoxFit.cover)),
                        )),
                  ),
                  const SizedBox(
                    height: defaultPadding / 2,
                  ),
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        Text(i.name.toString(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              height: 1.2,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .fontSize,
                            )),
                        Text('${i.follows}人关注',
                            maxLines: 2,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .fontSize,
                              color: Theme.of(context).colorScheme.outline,
                            )),
                      ]))
                ],
              ),
            )),
      );
    }
    return widgets;
  }

  Widget _buildHotestTile(BuildContext context) {
    List<Widget> widgets = _buildHotestBuildingTileList(context);
    return Row(
      children: [
        Expanded(
            child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.start,
          runSpacing: defaultPadding / 3,
          children: widgets,
        ))
      ],
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
                  const CardTitle('今日热门'),
                  const SizedBox(
                    height: defaultPadding,
                  ),
                  _buildHotestTile(context)
                ],
              )),
        ));
  }
}
