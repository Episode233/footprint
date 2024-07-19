import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/topicList.dart';
import 'package:vcommunity_flutter/Page/Explore/Building/BuildingAdd/components/my_favorite_building.dart';
import 'package:vcommunity_flutter/Page/Explore/Topic/components/my_favorite_topic.dart';
import 'package:vcommunity_flutter/Page/User/Info/components/user_information_screen.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';

import '../../../Model/building.dart';
import '../../../constants.dart';
import '../../../util/http_util.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final HttpUtil _httpUtil = Get.find();
  final UserStateUtil _userStateUtil = Get.find();
  BuildingList likeBuilding = BuildingList([]);
  TopicList likeTopic = TopicList([]);
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("我的"), actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ]),
        body: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: ListView(
              children: [
                const UserInformationScreen(),
                Card(
                    margin: const EdgeInsets.only(top: defaultPadding),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(defaultPadding / 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.volume_down_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const Text("欢迎使用足记！！！"),
                        ],
                      ),
                    )),
                const SizedBox(
                  height: defaultPadding,
                ),
                MyFavoriteBuilding(
                  likeBuilding,
                  title: '收藏建筑',
                ),
                MyFavoriteTopic(
                  likeTopic,
                  title: '收藏话题',
                ),
              ],
            ),
          ),
        ));
  }

  _refresh() async {
    if (_userStateUtil.isLogin()) {
      await _httpUtil.getMyInfo();
      int lastId = DateTime.now().millisecondsSinceEpoch;

      var likeResp = await _httpUtil.get(apiFollowBuildingList);
      var likeResp1 = await _httpUtil.get(apiFollowTopicList);
      setState(() {
        if (likeResp.body != null) {
          likeBuilding = ApiResponse.fromJson(
              likeResp.body, (json) => BuildingList.fromJson(json)).data;
        }
        if (likeResp1.body != null) {
          likeTopic = ApiResponse.fromJson(
              likeResp1.body, (json) => TopicList.fromJson(json)).data;
        }
      });
    }
  }
}
