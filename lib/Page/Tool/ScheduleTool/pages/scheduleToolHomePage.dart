import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Page/Tool/ScheduleTool/util/scheduleUtil.dart';
import 'package:vcommunity_flutter/constants.dart';

class ScheduleToolHomePage extends StatefulWidget {
  const ScheduleToolHomePage({super.key});

  @override
  State<ScheduleToolHomePage> createState() => _ScheduleToolHomePageState();
}

class _ScheduleToolHomePageState extends State<ScheduleToolHomePage> {
  final ScheduleUtil _scheduleUtil = Get.find();
  final TextEditingController textEditingController = TextEditingController();
  List info = [
    {
      'version': '介绍',
      'detail': ['本工具数据来源于中央民族大学教务系统的数据，用户需要在下方输入本学期课表链接才能正常使用桌面组件']
    },
    {
      'version': '首次使用',
      'detail': [
        '1.打开中央民族大学信息门户',
        '2.在信息门户界面中选择本科生教务系统',
        '3.待页面加载完成后点击左上角三个横杠',
        '4.依次选择选课管理、本学期课表，查看网页源代码，复制代码',
        '5.点击本应用下方按钮，粘贴代码',
        '6.长按手机主界面，添加本应用小组件'
      ]
    },
    {
      'version': '使用提示',
      'detail': [
        '1.点击桌面小组件即可刷新课表',
        '2.每天晚上9点后获取的是第二天课表',
      ]
    },
  ];
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for (var i in info) {
      List<Widget> info = [];
      for (var j in i['detail']) {
        info.add(
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
              '${i["version"]}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...info,
          ]),
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('课表桌面小组件'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: FilledButton.icon(
            label: const Icon(Icons.token_rounded),
            icon: const Text('输入我的课程源代码'),
            onPressed: () {
              Get.defaultDialog(
                title: '我的课程源代码',
                onCancel: Get.back,
                onConfirm: saveUserToken,
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      defaultPadding, 0, defaultPadding, defaultPadding),
                  child: Column(children: [
                    TextField(
                      controller: textEditingController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: "代码",
                        hintText: "本科生教务系统->查看网页源代码",
                        prefixIcon: Icon(Icons.token_rounded),
                      ),
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    const Text('应用仅会将信息保存至本地，不会上传至任何第三方'),
                  ]),
                ),
              );
            },
        ),
      ),
      body: ListView(
        children: list,
      ),
    );
  }

  void saveUserToken() {
    String token = textEditingController.text;
    final pattern = RegExp(r'weiXinID=([\w]+)');
    final match = pattern.firstMatch(token);




    Get.back();
    Get.snackbar('提示', '本功能仍在开发中'); // 待删




    // if (match != null) {
    //   String id = match.group(1) ?? '';
    //   _scheduleUtil.setScheduleToken(id);
    // } else {
    //   Get.snackbar('提示', '输入错误，请输入完整的链接');
    // }
    // Get.back();
  }
}
