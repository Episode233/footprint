import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/building.dart';
import 'package:vcommunity_flutter/Model/topicList.dart';
import 'package:vcommunity_flutter/components/card_title.dart';
import 'package:vcommunity_flutter/constants.dart';

class MyFavoriteBuilding extends StatelessWidget {
  MyFavoriteBuilding(this.data, {super.key, this.title = '我的收藏'});
  String title;
  BuildingList data;

  List<Widget> _buildFollowTileList() {
    List<Widget> widgets = [];
    for (var i in data.buildings) {
      String? icon = i.icon.toString();
      widgets.add(
        InkWell(
            borderRadius:
                const BorderRadius.all(Radius.circular(defaultBorderRadius)),
            onTap: () => Get.toNamed('/building/${i.id}'),
            child: Container(
              padding: const EdgeInsets.all(defaultPadding / 3),
              width: 140,
              child: Row(
                children: [
                  SizedBox(
                    height: 20,
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(3),
                          ),
                          image: DecorationImage(
                              image: NetworkImage(icon), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: defaultPadding / 2,
                  ),
                  Expanded(
                      child: Text(
                    i.name,
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                  ))
                ],
              ),
            )),
      );
    }
    return widgets;
  }

  Widget _buildFollowTile() {
    List<Widget> tiles = _buildFollowTileList();
    return Row(
      children: [
        Expanded(
            child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: defaultPadding / 3,
          children: tiles,
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
                  CardTitle(title),
                  const SizedBox(
                    height: defaultPadding,
                  ),
                  _buildFollowTile()
                ],
              )),
        ));
  }
}
