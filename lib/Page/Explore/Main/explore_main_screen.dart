import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Page/Explore/Building/building_main_screen.dart';
import 'package:vcommunity_flutter/Page/Explore/Topic/topic_main_screen.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';

class ExploreMainScreen extends StatelessWidget {
  ExploreMainScreen({super.key});
  final UserStateUtil _userStateUtil = Get.find();
  final tabs = [
    const Tab(
      text: "话题",
      icon: Icon(Icons.casino),
      iconMargin: EdgeInsets.only(bottom: 3.0),
      height: 56,
    ),
    const Tab(
      text: "建筑",
      icon: Icon(Icons.corporate_fare_rounded),
      iconMargin: EdgeInsets.only(bottom: 3.0),
      height: 56,
    ),
  ];
  final pages = [
    TopicMainScreen(),
    BuildingMainScreen(),
  ];

  void _toAddPage(context) {
    Get.toNamed('/topic/add');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.background,
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
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
              ),
              IconButton(
                onPressed: () => _toAddPage(context),
                icon: const Icon(Icons.add),
              ),
            ],
            bottom: TabBar(
                tabs: tabs,
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                unselectedLabelStyle: Theme.of(context).textTheme.bodySmall),
          ),
          body: TabBarView(children: pages),
        ));
  }
}
