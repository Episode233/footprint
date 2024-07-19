import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Page/Explore/Main/explore_main_screen.dart';
import 'package:vcommunity_flutter/Page/Tool/tool_screen.dart';
import 'package:vcommunity_flutter/Page/User/Info/info_screen.dart';
import 'package:vcommunity_flutter/Page/User/Welcome/welcome_screen.dart';
import 'package:vcommunity_flutter/Page/Visual/visual_screen.dart';
import 'package:vcommunity_flutter/components/responsive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 首页能切换的页面
  List<Map> homePages = [
    {
      'widget': VisualScreen(),
      'icon': const Icon(Icons.map_rounded),
      'label': "地图视野"
    },
    {
      'widget': ExploreMainScreen(),
      'icon': const Icon(Icons.all_inclusive),
      'label': "探索"
    },
    {
      'widget': ToolScreenPage(),
      'icon': const Icon(Icons.toll_rounded),
      'label': "发现"
    },
    {
      'widget': InfoScreen(),
      'icon': const Icon(Icons.account_circle_outlined),
      'label': "我的"
    }
  ];
  int selectedIndex = 0;
  List<NavigationDestination> _getDestinations() {
    List<NavigationDestination> destinations = [];
    for (var i in homePages) {
      destinations
          .add(NavigationDestination(icon: i['icon'], label: i['label']));
    }
    return destinations;
  }

  List<NavigationRailDestination> _getRailDestinations() {
    List<NavigationRailDestination> destinations = [];
    for (var i in homePages) {
      destinations.add(
          NavigationRailDestination(icon: i['icon'], label: Text(i['label'])));
    }
    return destinations;
  }

  @override
  Widget build(BuildContext context) {
    List<Offstage> pages = [];
    int i = 0;
    for (var item in homePages) {
      pages.add(Offstage(
        offstage: selectedIndex != i,
        child: HeroMode(enabled: selectedIndex == i, child: item['widget']),
      ));
      i++;
    }
    Color navColor = ElevationOverlay.applySurfaceTint(
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.surfaceTint,
        3);
    final myTheme =
        SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: navColor);
    SystemChrome.setSystemUIOverlayStyle(myTheme);

    return Responsive(
      mobile: Scaffold(
        body: Stack(children: pages),
        bottomNavigationBar: NavigationBar(
          destinations: _getDestinations(),
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
        ),
      ),
      desktop: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                destinations: _getRailDestinations(),
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                groupAlignment: 0,
                leading: FloatingActionButton(
                  elevation: 0,
                  onPressed: () {
                    Get.toNamed("blog/add");
                  },
                  child: const Icon(Icons.add),
                ),
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
              Expanded(
                child: Stack(
                  children: pages,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
