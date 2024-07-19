import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/blog.dart';
import 'package:vcommunity_flutter/Model/topic.dart';
import 'package:vcommunity_flutter/Page/Blog/BlogList/components/blog_list_item.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({super.key});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  Topic? _topic;
  Color? _iconThemeColor;
  Color? _onIconThemeColor;
  int timeStamp = DateTime.now().millisecondsSinceEpoch;
  bool isLiking = false;
  List<int> pages = [1, 1];
  List<bool> notMore = [false, false];
  final List<List<Blog>> _blogs = [[], []];

  /// 动态排序类型:
  ///   0按发表时间排序
  ///   1按评论时间排序
  final int _blogType = 0;
  final HttpUtil _httpUtil = Get.find();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getTopic().then((value) {
      _getBlogsByTopic(_topic!.id!);
    });
    _scrollController.addListener(() {
      _scrollListener();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // 滚动到底部
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
        });
        // 触发加载事件
        _getBlogsByTopic(_topic!.id!, blogType: _blogType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Widget bodyContent = const Center(
      child: CircularProgressIndicator.adaptive(),
    );
    if (_topic != null) {
      Topic topic = _topic!;
      Widget tipsWidget = const SizedBox();
      if (_isLoading) {
        tipsWidget = const Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (notMore[_blogType]) {
        tipsWidget = Center(
            child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "没有更多了",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ));
      }
      bodyContent = RefreshIndicator(
        onRefresh: () async => _getTopic(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              foregroundColor: _onIconThemeColor,
              title: Text(
                topic.name,
              ),
              stretch: false,
              actions: [
                IconButton(
                    onPressed: () => Get.toNamed("/topic/edit/${topic.id}"),
                    icon: const Icon(Icons.edit)),
                Hero(
                  tag: 'search',
                  child: IconButton(
                    onPressed: () => Get.toNamed("/search?topicId=${topic.id}"),
                    icon: const Icon(Icons.search_rounded),
                  ),
                )
              ],
              pinned: true,
              expandedHeight: 250,
              backgroundColor: _iconThemeColor,
              surfaceTintColor: _iconThemeColor,
              flexibleSpace: FlexibleSpaceBar(
                background: ShaderMask(
                  shaderCallback: ((bounds) {
                    return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(255),
                          _iconThemeColor!.withAlpha(0),
                        ]).createShader(
                        Rect.fromLTRB(0, 0, bounds.width, bounds.bottom));
                  }),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                    child: Image.network(
                      topic.icon,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: _iconThemeColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(largeBorderRadius),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 85,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(defaultBorderRadius)),
                                    image: DecorationImage(
                                        image: NetworkImage(topic.icon),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: defaultPadding,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.name,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: (Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .fontSize ??
                                              25) -
                                          3,
                                      fontWeight: FontWeight.bold,
                                      color: _onIconThemeColor,
                                      height: 2),
                                ),
                                Text(
                                  "${topic.follows}人关注",
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .fontSize,
                                      color: _onIconThemeColor,
                                      height: 1.7),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: isLiking ? null : () => _handlerLike(),
                            icon: topic.isLike
                                ? const Icon(Icons.check)
                                : const Icon(Icons.add),
                            label: topic.isLike
                                ? const Text("已关注")
                                : const Text("关注"),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      alignment: Alignment.topLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "介绍:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                height: 1.8,
                                color: _onIconThemeColor),
                          ),
                          Expanded(
                            child: Text(
                              (topic.introduce ?? '').isEmpty
                                  ? '暂无介绍'
                                  : topic.introduce!,
                              maxLines: 30,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  height: 1.8, color: _onIconThemeColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return BlogListItem(_blogs[_blogType][index]);
              }, childCount: _blogs[_blogType].length),
            ),
            SliverToBoxAdapter(child: tipsWidget)
          ],
        ),
      );
    }
    return Scaffold(body: bodyContent);
  }

  Future<void> _getTopic() async {
    timeStamp = DateTime.now().millisecondsSinceEpoch;
    String key = '';
    if (GetPlatform.isWeb) {
      key = webKey;
    } else {
      key = appKey;
    }
    final id = Get.parameters['topicId'] ?? "-1";
    if (id == "-1") {
      Get.back();
    }
    final resp = await _httpUtil.get(apiGetTopicDetail + id);
    _topic =
        ApiResponse.fromJson(resp.body, (json) => Topic.fromJson(json)).data;
    PaletteGenerator? generator;
    if (!GetPlatform.isWeb) {
      generator = await _fetchImageColor(_topic!.icon);
    }
    setState(() {
      _iconThemeColor = generator?.dominantColor?.color ??
          Theme.of(context).colorScheme.primary;
      double backgroundBrightness = _iconThemeColor!.computeLuminance();
      Color textColor =
          backgroundBrightness > 0.5 ? Colors.black : Colors.white;

      _onIconThemeColor = textColor.withAlpha(200);
    });
  }

  _getBlogsByTopic(int topicId, {int blogType = 0}) async {
    if (notMore[blogType]) {
      return;
    }
    Response response = await _httpUtil.get(
        '$apiSearchBlog?topicId=$topicId&lastId=$timeStamp&page=${pages[blogType]}&size=$blogPageSize&sortType=$blogType');
    pages[blogType]++;
    List<Blog> blogs =
        ApiResponse.fromJson(response.body, ((json) => BlogList.fromJson(json)))
            .data
            .blogs;
    setState(() {
      _blogs[blogType].addAll(blogs);
      if (blogs.length < blogPageSize) {
        notMore[blogType] = true;
      }
      _isLoading = false;
    });
  }

  Future<PaletteGenerator> _fetchImageColor(String url) async {
    ImageProvider imageProvider = NetworkImage(url);

    var generator = await PaletteGenerator.fromImageProvider(
      imageProvider,
      maximumColorCount: 20, // 颜色样本最大数量
    );
    return generator;
  }

  _handlerLike() async {
    setState(() {
      isLiking = true;
    });
    if (_topic!.isLike) {
      await _httpUtil.delete('$apiFollowTopic?id=${_topic!.id}');
    } else {
      await _httpUtil.post('$apiFollowTopic?id=${_topic!.id}', {});
    }
    setState(() {
      _topic!.isLike = !_topic!.isLike;
      _topic!.isLike ? _topic!.follows++ : _topic!.follows--;
      isLiking = false;
    });
  }
}
