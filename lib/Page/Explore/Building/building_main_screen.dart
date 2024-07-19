import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Page/Explore/Building/BuildingAdd/components/my_favorite_building.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

import '../../../Model/building.dart';
import 'BuildingAdd/components/hotest_building.dart';
import 'BuildingAdd/components/latest_building.dart';

class BuildingMainScreen extends StatefulWidget {
  const BuildingMainScreen({super.key});

  @override
  State<BuildingMainScreen> createState() => _BuildingMainScreenState();
}

class _BuildingMainScreenState extends State<BuildingMainScreen>
    with AutomaticKeepAliveClientMixin {
  final HttpUtil _httpUtil = Get.find();
  BuildingList likeBuilding = BuildingList([]);
  BuildingList newestBuilding = BuildingList([]);
  BuildingList hotestBuilding = BuildingList([]);

  _init() async {
    int lastId = DateTime.now().millisecondsSinceEpoch;
    var likeResp = await _httpUtil.get(apiFollowBuildingList);
    var newestResp =
        await _httpUtil.get("$apiSearchBuilding?lastId=$lastId&size=10");
    var hotestResp = await _httpUtil
        .get("$apiSearchBuilding?lastId=$lastId&sortType=1&size=10");
    setState(() {
      if (likeResp.body != null) {
        likeBuilding = ApiResponse.fromJson(
            likeResp.body, (json) => BuildingList.fromJson(json)).data;
      }

      newestBuilding = ApiResponse.fromJson(
          newestResp.body, (json) => BuildingList.fromJson(json)).data;
      hotestBuilding = ApiResponse.fromJson(
          hotestResp.body, (json) => BuildingList.fromJson(json)).data;
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: ListView(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  children: [
                    MyFavoriteBuilding(likeBuilding),
                    LatestBuilding(newestBuilding),
                    HotestBuilding(hotestBuilding)
                  ],
                )),
          ],
        ),
        onRefresh: () => _init());
  }

  @override
  bool get wantKeepAlive => true;
}
