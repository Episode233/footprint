import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/user.dart';
import 'package:vcommunity_flutter/Page/Visual/components/list_screen.dart';
import 'package:vcommunity_flutter/Page/Visual/components/map_widget.dart';
import 'package:vcommunity_flutter/components/card_title.dart';
import 'package:vcommunity_flutter/components/responsive.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';

class VisualScreen extends StatefulWidget {
  const VisualScreen({super.key});

  @override
  State<VisualScreen> createState() => _VisualScreenState();
}

class _VisualScreenState extends State<VisualScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final UserStateUtil _userStateUtil = Get.find();
  final HttpUtil _httpUtil = Get.find();
  bool _useMap = true;
  final tabs = [
    const Tab(
      text: "附近400m",
      icon: Icon(Icons.radar_rounded),
      iconMargin: EdgeInsets.only(bottom: 3.0),
      height: 56,
    ),
    const Tab(
      text: "阅览",
      icon: Icon(Icons.visibility_rounded),
      iconMargin: EdgeInsets.only(bottom: 3.0),
      height: 56,
    ),
    const Tab(
      text: "最新",
      icon: Icon(Icons.newspaper_rounded),
      iconMargin: EdgeInsets.only(bottom: 3.0),
      height: 56,
    ),
  ];
  late List<Widget> pages;
  late TabController _tabController;
  void _showMenu(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(defaultPadding),
              height: 300, //对话框高度就是此高度
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                        child: Container(
                      width: 30,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).colorScheme.primary),
                    )),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              Get.toNamed("blog/add?type=article");
                            },
                            style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            icon: Column(
                              children: const [
                                Icon(Icons.article),
                                Text("发表图文")
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: defaultPadding / 2,
                        ),
                        Expanded(
                            child: IconButton(
                                onPressed: () {
                                  Get.toNamed("blog/add");
                                },
                                style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                icon: Column(
                                  children: const [
                                    Icon(Icons.edit_document),
                                    Text("发表动态")
                                  ],
                                )))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              Get.toNamed('/building/add');
                            },
                            style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            icon: Column(
                              children: const [
                                Icon(Icons.corporate_fare_rounded),
                                Text("添加建筑")
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: defaultPadding / 2,
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              Get.toNamed('/topic/add');
                            },
                            style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            icon: Column(
                              children: const [
                                Icon(Icons.control_point_duplicate_rounded),
                                Text("添加话题")
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: defaultPadding / 2,
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () =>
                                Get.toNamed("/tool/library_tool/scan"),
                            style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            icon: Column(
                              children: const [
                                Icon(Icons.qr_code),
                                Text("扫一扫")
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: defaultPadding / 2,
                        ),
                        Expanded(
                            child: IconButton(
                                onPressed: () => _httpUtil.logout(),
                                style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                icon: Column(
                                  children: const [
                                    Icon(Icons.logout_rounded),
                                    Text("退出登录")
                                  ],
                                )))
                      ],
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                  ]),
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    pages = [
      ListBlogScreen(
        '$apiNearbyBlog?range=400',
        notLastId: true,
      ),
      ListBlogScreen('$apiSearchBlog?sortType=0&lastId='),
      ListBlogScreen('$apiSearchBlog?sortType=1&lastId='),
    ];
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? tabBar;
    if (!_useMap) {
      tabBar = TabBar(
          controller: _tabController,
          tabs: tabs,
          labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
          unselectedLabelStyle: Theme.of(context).textTheme.bodySmall);
    }

    return Responsive(
      mobile: Scaffold(
        appBar: AppBar(
            elevation: 0,
            leading: Container(
              padding: const EdgeInsets.only(left: defaultPadding),
              child: Obx(
                () => CircleAvatar(
                  foregroundImage: NetworkImage(_userStateUtil.user().icon),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Ink(
                    height: 36,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Hero(
                      tag: 'search',
                      child: Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          onTap: () {
                            Get.toNamed('/search');
                          },
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(6, 7, 0, 7),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        4, 10, 10, 10),
                                    child: Text(
                                      "中央民族大学",
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .fontSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ))
                              ]),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            actions: [
              Switch(
                value: _useMap,
                onChanged: (value) {
                  setState(() {
                    _useMap = value;
                  });
                },
                thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return const Icon(Icons.list_alt_rounded);
                  }
                  return _useMap
                      ? const Icon(Icons.map_rounded)
                      : const Icon(Icons.view_stream_rounded);
                }),
              ),

              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.list_alt_rounded),
              // ),
              IconButton(
                onPressed: () => _showMenu(context),
                icon: const Icon(Icons.crop_free_rounded),
              ),
            ],
            bottom: tabBar),
        body: Stack(children: [
          Offstage(
            offstage: !_useMap,
            child: HeroMode(enabled: _useMap, child: MapWidget()),
          ),
          Offstage(
            offstage: _useMap,
            child: HeroMode(
                enabled: !_useMap,
                child: TabBarView(controller: _tabController, children: pages)),
          )
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.toNamed("blog/add");
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            )),
      ),
      desktop: Scaffold(
        appBar: AppBar(
            elevation: 0,
            leading: Container(
              padding: const EdgeInsets.only(left: defaultPadding),
              child: Obx(
                () => CircleAvatar(
                  foregroundImage: NetworkImage(_userStateUtil.user().icon),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Ink(
                    height: 36,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Hero(
                      tag: 'search',
                      child: Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          onTap: () {
                            Get.toNamed('/search');
                          },
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(6, 7, 0, 7),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        4, 10, 10, 10),
                                    child: Text(
                                      "中央民族大学",
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .fontSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ))
                              ]),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            actions: [
              Switch(
                value: _useMap,
                onChanged: (value) {
                  setState(() {
                    _useMap = value;
                  });
                },
                thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return const Icon(Icons.list_alt_rounded);
                  }
                  return _useMap
                      ? const Icon(Icons.map_rounded)
                      : const Icon(Icons.view_stream_rounded);
                }),
              ),

              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.list_alt_rounded),
              // ),
              IconButton(
                onPressed: () => _showMenu(context),
                icon: const Icon(Icons.crop_free_rounded),
              ),
            ],
            bottom: tabBar),
        body: Stack(children: [
          Offstage(
            offstage: !_useMap,
            child: HeroMode(enabled: _useMap, child: MapWidget()),
          ),
          Offstage(
            offstage: _useMap,
            child: HeroMode(
                enabled: !_useMap,
                child: TabBarView(controller: _tabController, children: pages)),
          )
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
