import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/topicList.dart';
import 'package:vcommunity_flutter/Page/Explore/Topic/components/hotest_topic.dart';
import 'package:vcommunity_flutter/Page/Explore/Topic/components/latest_topic.dart';
import 'package:vcommunity_flutter/Page/Explore/Topic/components/my_favorite_topic.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

class TopicMainScreen extends StatefulWidget {
  const TopicMainScreen({super.key});

  @override
  State<TopicMainScreen> createState() => _TopicMainScreenState();
}

class _TopicMainScreenState extends State<TopicMainScreen>
    with AutomaticKeepAliveClientMixin {
  final HttpUtil _httpUtil = Get.find();
  TopicList likeTopic = TopicList([]);
  TopicList newestTopic = TopicList([]);
  TopicList hotestTopic = TopicList([]);

  _init() async {
    int lastId = DateTime.now().millisecondsSinceEpoch;
    var likeResp = await _httpUtil.get(apiFollowTopicList);
    var newestResp =
        await _httpUtil.get("$apiSearchTopic?lastId=$lastId&size=10");
    var hotestResp = await _httpUtil
        .get("$apiSearchTopic?lastId=$lastId&sortType=1&size=10");
    setState(() {
      if (likeResp.body != null) {
        likeTopic = ApiResponse.fromJson(
            likeResp.body, (json) => TopicList.fromJson(json)).data;
      }

      newestTopic = ApiResponse.fromJson(
          newestResp.body, (json) => TopicList.fromJson(json)).data;
      hotestTopic = ApiResponse.fromJson(
          hotestResp.body, (json) => TopicList.fromJson(json)).data;
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
                    MyFavoriteTopic(likeTopic),
                    LatestTopic(newestTopic),
                    HotestTopic(hotestTopic)
                  ],
                )),
          ],
        ),
        onRefresh: () => _init());
  }

  @override
  bool get wantKeepAlive => true;
}
