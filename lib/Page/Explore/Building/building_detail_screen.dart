import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/blog.dart';
import 'package:vcommunity_flutter/Model/building.dart';
import 'package:vcommunity_flutter/Page/Blog/BlogList/components/blog_list_item.dart';
import 'package:vcommunity_flutter/components/notice_snackbar.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

class BuildingDetailScreen extends StatefulWidget {
  const BuildingDetailScreen({super.key});

  @override
  State<BuildingDetailScreen> createState() => _BuildingDetailScreenState();
}

class _BuildingDetailScreenState extends State<BuildingDetailScreen> {
  Building? _building;
  Color? _iconThemeColor;
  Color? _iconSecondaryThemeColor;
  Color? _onIconThemeColor;
  int timeStamp = DateTime.now().millisecondsSinceEpoch;
  List<Widget> pics = [];
  bool isLiking = false;

  List<int> pages = [1, 1];
  List<bool> notMore = [false, false];
  List<List<Blog>> _blogs = [[], []];

  /// 动态排序类型:
  ///   0按发表时间排序
  ///   1按评论时间排序
  int _blogType = 0;
  final HttpUtil _httpUtil = Get.find();
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getBuilding().then((value) {
      _getBlogsByBuilding(_building!.id);
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
        _getBlogsByBuilding(_building!.id, blogType: _blogType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Widget bodyContent = const Center(
      child: CircularProgressIndicator.adaptive(),
    );
    if (_building != null) {
      Building building = _building!;
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
        onRefresh: () async => _getBuilding(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              foregroundColor: _onIconThemeColor,
              title: Text(
                building.name,
              ),
              stretch: false,
              actions: [
                IconButton(
                    onPressed: () =>
                        Get.toNamed("/building/edit/${building.id}"),
                    icon: const Icon(Icons.edit)),
                Hero(
                  tag: 'search',
                  child: IconButton(
                    onPressed: () =>
                        Get.toNamed("/search?buildingId=${building.id}"),
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
                        Rect.fromLTRB(0, 100, bounds.width, bounds.bottom));
                  }),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                    child: Image.network(
                      building.icon,
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
                          Hero(
                            tag: "/building/${building.id}",
                            child: SizedBox(
                              height: 85,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(defaultBorderRadius)),
                                      image: DecorationImage(
                                          image: NetworkImage(building.icon),
                                          fit: BoxFit.cover)),
                                ),
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
                                  building.name,
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
                                  "${building.createTime.toString().split(' ').first}创建",
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .fontSize,
                                      color: _onIconThemeColor,
                                      height: 1.7),
                                ),
                                Text(
                                  "${building.follows}人关注",
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
                            icon: building.isLike
                                ? const Icon(Icons.check)
                                : const Icon(Icons.add),
                            label: building.isLike
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
                              building.introduce.isEmpty
                                  ? '暂无介绍'
                                  : building.introduce,
                              maxLines: 30,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  height: 1.8, color: _onIconThemeColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(largeBorderRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(defaultPadding,
                                defaultPadding / 2, defaultPadding, 0),
                            child: Text(
                              "详细:",
                              style: TextStyle(
                                  color: _onIconThemeColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: defaultPadding / 2,
                          ),
                          SizedBox(
                            height: 170,
                            child: PageView(
                              children: pics,
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

  Future<void> _getBuilding() async {
    timeStamp = DateTime.now().millisecondsSinceEpoch;
    String key = '';
    if (GetPlatform.isWeb) {
      key = webKey;
    } else {
      key = appKey;
    }
    final id = Get.parameters['buildingId'] ?? "-1";
    if (id == "-1") {
      NoticeSnackBar.showSnackBar("建筑不存在", type: NoticeType.WARN);
      Get.back();
    }
    final resp = await _httpUtil.get(apiGetBuildingDetail + id);
    try {
      _building =
          ApiResponse.fromJson(resp.body, (json) => Building.fromJson(json))
              .data;
    } catch (e) {
      Get.back();
    }

    PaletteGenerator? generator;
    if (!GetPlatform.isWeb) {
      generator = await _fetchImageColor(_building!.icon);
    }
    setState(
      () {
        _iconThemeColor = generator?.dominantColor?.color ??
            Theme.of(context).colorScheme.primary;
        double backgroundBrightness = _iconThemeColor!.computeLuminance();
        Color textColor =
            backgroundBrightness > 0.5 ? Colors.black : Colors.white;

        _iconSecondaryThemeColor = textColor.withAlpha(25);
        _onIconThemeColor = textColor.withAlpha(200);
        pics.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(defaultPadding,
                defaultPadding / 2, defaultPadding, defaultPadding * 1.5),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                boxShadow: [
                  BoxShadow(
                      color:
                          Theme.of(context).colorScheme.primary.withAlpha(50),
                      offset: const Offset(4, 3.4),
                      blurRadius: 6,
                      spreadRadius: 1.5)
                ],
              ),
              child: FlutterMap(
                options: MapOptions(
                  enableScrollWheel: false,
                  enableMultiFingerGestureRace: false,
                  interactiveFlags: InteractiveFlag.none,
                  center: LatLng(_building!.latitude, _building!.longitude),
                  zoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://t0.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key",
                  ),
                  TileLayer(
                    backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                    urlTemplate:
                        "https://t0.tianditu.gov.cn/cva_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key",
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point:
                            LatLng(_building!.latitude, _building!.longitude),
                        width: 60,
                        height: 60,
                        builder: (context) {
                          return Card(
                            elevation: defaultMapCardElevate,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            color: Theme.of(context).colorScheme.inversePrimary,
                            child: Center(
                              child: Icon(
                                Icons.domain_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
        // print(_building!.toJson());
        if (_building!.images != '') {
          var picUrls = _building!.images.split(',');
          for (var item in picUrls) {
            pics.add(
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                onTap: () {
                  Get.toNamed("/imageView?path=$item");
                },
                child: Hero(
                  tag: item,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          defaultPadding,
                          defaultPadding / 2,
                          defaultPadding,
                          defaultPadding * 1.5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(defaultBorderRadius),
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha(50),
                                offset: const Offset(4, 3.4),
                                blurRadius: 6,
                                spreadRadius: 1.5)
                          ],
                          image: DecorationImage(
                              image: NetworkImage(item), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  _getBlogsByBuilding(int buildingId, {int blogType = 0}) async {
    if (notMore[blogType]) {
      return;
    }
    Response response = await _httpUtil.get(
        '$apiSearchBlog?buildingId=$buildingId&lastId=$timeStamp&page=${pages[blogType]}&size=$blogPageSize&sortType=$blogType');
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
    if (_building!.isLike) {
      await _httpUtil.delete('$apiFollowBuilding?id=${_building!.id}');
    } else {
      await _httpUtil.post('$apiFollowBuilding?id=${_building!.id}', {});
    }
    setState(() {
      _building!.isLike = !_building!.isLike;
      _building!.isLike ? _building!.follows++ : _building!.follows--;
      isLiking = false;
    });
  }
}
