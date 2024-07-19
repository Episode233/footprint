import 'package:flutter/material.dart';

import '../../../../constants.dart';

class LibraryUpdateInfoPage extends StatelessWidget {
  LibraryUpdateInfoPage({super.key});
  List updateInfo = [
    {
      'version': 'v1.0.4',
      'detail': ['1.整合至足记', '2.尝试修复图书馆服务器异常时自动刷新']
    },
    {
      'version': 'v1.0.3',
      'detail': ['1.添加ShortCuts']
    },
    {
      'version': 'v1.0.2',
      'detail': [
        '1.实现图书馆签到界面座位收藏',
        '2.优化验证过期时自动通过验证',
        '3.修改主页布局，将签到与预约置于同一层级'
      ]
    },
    {
      'version': 'v1.0.1',
      'detail': ['1.实现图书馆座位扫码签到', '2.实现图书馆座位通过本地相册扫码签到', '3.修改界面布局，便于进入图书馆预约界面']
    },
    {
      'version': 'v1.0.0',
      'detail': ['1.实现跳过打开微信公众号']
    },
  ];
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for (var i in updateInfo) {
      List<Widget> updateInfo = [];
      for (var j in i['detail']) {
        updateInfo.add(
          Text(
            j,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      }
      list.add(Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${i["version"]}更新日志',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...updateInfo,
          ]),
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('更新日志')),
      body: ListView(
        children: list,
      ),
    );
  }
}
