import 'dart:math';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_shortcuts/flutter_shortcuts.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:home_widget/home_widget_callback_dispatcher.dart';
import 'package:vcommunity_flutter/Page/Tool/LibraryTool/util/http_util.dart';
import 'package:vcommunity_flutter/Page/Tool/LibraryTool/util/state_util.dart';
import 'package:vcommunity_flutter/Page/Tool/ScheduleTool/util/scheduleUtil.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';
import 'package:workmanager/workmanager.dart';
import 'Page/home_page.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'routes.dart';

void main() {
  if (GetPlatform.isAndroid && !GetPlatform.isWeb) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  }
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());
}

@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  final ScheduleUtil scheduleUtil = ScheduleUtil();
  await scheduleUtil.init();
  if (scheduleUtil.userToken == '') {
    HomeWidget.saveWidgetData<String>('location_0', '未输入用户token，请进入app');
    await HomeWidget.updateWidget(
        name: scheduleAndroidWidgetName, iOSName: scheduleIOSWidgetName);
    return;
  }
  DateTime now = DateTime.now();
  int hour = int.parse(DateFormat('HH').format(now));
  List courses = [];
  String updateTime = '更新:${DateFormat('HH:mm').format(now)}';
  String scheduleDate = '';
  if (hour >= 21) {
    DateTime tomorrow = now.add(const Duration(days: 1));
    String formattedDate = DateFormat('yyyy-MM-dd').format(tomorrow);
    scheduleDate = '明日:$formattedDate课表';
    //TODO
    courses = await scheduleUtil.getSchedule('&date=$formattedDate');
    // courses = await scheduleUtil.getSchedule('&date=2020-10-20');
  } else {
    //TODO
    // courses = await scheduleUtil.getSchedule('&date=2020-10-20');
    courses = await scheduleUtil.getSchedule('');
    String formattedDate = DateFormat('MM月dd日').format(now);
    scheduleDate = '今日:$formattedDate课程';
  }
  if (data == null) {
    return;
  }
  await HomeWidget.saveWidgetData<String>('scheduleDate', scheduleDate);
  await HomeWidget.saveWidgetData<String>('updateTime', updateTime);
  for (var i = 0; i < courses.length; i++) {
    var item = courses[i];
    HomeWidget.saveWidgetData<String>('order_$i', '节次:${item['order']}');
    HomeWidget.saveWidgetData<String>('className_$i', item['className']);
    HomeWidget.saveWidgetData<String>('time_$i', item['time']);
    HomeWidget.saveWidgetData<String>('location_$i', '教室:${item['location']}');
    HomeWidget.saveWidgetData<String>('teacher_$i', item['teacher']);
  }
  await HomeWidget.updateWidget(
      name: scheduleAndroidWidgetName, iOSName: scheduleIOSWidgetName);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Set<PointerDeviceKind> kTouchLikeDeviceTypes = <PointerDeviceKind>{
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
      PointerDeviceKind.unknown
    };
    Get.put(UserStateUtil());
    Get.put(HttpUtil());
    Get.put(FlutterShortcuts());
    // LibraryTool
    Get.put(LibraryHttpUtil());
    Get.put(LibraryStateUtil());
    Get.put(ScheduleUtil());
    final LibraryStateUtil libraryStateUtil = Get.find();
    if (GetPlatform.isAndroid && !GetPlatform.isWeb) {
      final FlutterShortcuts flutterShortcuts = Get.find();
      flutterShortcuts.initialize(debug: true);

      flutterShortcuts.listenAction((String incomingAction) {
        if (incomingAction == 'toScanPage') {
          Get.toNamed('/tool/library_tool/scan');
        } else if (incomingAction.contains('toSignSeat')) {
          String link = incomingAction.split('@@@')[1];
          libraryStateUtil.signLink = link;
          Get.toNamed('/tool/library_tool/signSeat');
        }
      });

      HomeWidget.registerBackgroundCallback(backgroundCallback);
      HomeWidget.initiallyLaunchedFromHomeWidget().then((Uri? data) {
        print('click$data');
      });
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        print(lightDynamic);
        return GetMaterialApp(
          locale: ui.window.locale,
          scrollBehavior: const MaterialScrollBehavior()
              .copyWith(scrollbars: true, dragDevices: kTouchLikeDeviceTypes),
          debugShowCheckedModeBanner: false,
          title: '足记',
          unknownRoute: GetPage(name: '/notfound', page: () => HomePage()),
          initialRoute: '/',
          getPages: routes,
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'OPlusSans3',
            colorSchemeSeed: darkDynamic?.primary ?? seed,
            cardTheme: const CardTheme(
              elevation: 0,
              color: Colors.black,
              margin: EdgeInsets.all(defaultPadding),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleSmall!.fontSize),
                ),
              ),
            ),
            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleSmall!.fontSize),
                ),
              ),
            ),
          ),
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'OPlusSans3',
            colorSchemeSeed: lightDynamic?.primary ?? seed,
            scaffoldBackgroundColor: ColorScheme.fromSeed(
              seedColor: lightDynamic?.primary ?? seed,
            ).onInverseSurface,
            appBarTheme: AppBarTheme(
              backgroundColor: ColorScheme.fromSeed(
                seedColor: lightDynamic?.primary ?? seed,
              ).onInverseSurface,
            ),
            cardTheme: CardTheme(
              elevation: 0,
              color: ColorScheme.fromSeed(
                seedColor: lightDynamic?.primary ?? seed,
              ).background,
              margin: const EdgeInsets.all(defaultPadding),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleSmall!.fontSize),
                ),
              ),
            ),
            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleSmall!.fontSize),
                ),
              ),
            ),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
