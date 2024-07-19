import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'dart:convert';
import '../constants.dart';

class ScheduleUtil extends GetConnect {
  String userToken = ''; // 本地存储
  late SharedPreferences _prefs;
  @override
  bool get allowAutoSignedCert => true;
  @override
  void onInit() {
    super.onInit();
    init();
  }

  init() async {
    _prefs = await SharedPreferences.getInstance();
    getScheduleToken();
    initHeader();
  }

  void initHeader() {
    httpClient.removeRequestModifier<Object?>(
      (request) {
        request.headers['user-agent'] =
            'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36 NetType/WIFI MicroMessenger/7.0.20.1781(0x6700143B) WindowsWechat(0x63060012),';
        return request;
      },
    );
  }

  getScheduleToken() {
    userToken = _prefs.getString(scheduleUserTokenPath) ?? '';
  }

  setScheduleToken(String userToken) {
    _prefs.setString(scheduleUserTokenPath, userToken);
  }

  Future<List<Map>> getSchedule(String? addTail) async {
    String? body = await _getData(addTail);
    String content = '';
    if (body == null) {
    } else {
      content = body;
    }
    final document = parse(content);
    final ul = document.querySelector('ul.rl_info');
    final liList = ul!.querySelectorAll('li');
    final List<Map<String, String>> courses = [];

    for (final li in liList) {
      final p = li.querySelector('p');
      List lines = p!.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();
      if (lines.isNotEmpty) {
        Map<String, String> course = {
          'order': lines[0],
          'className': lines[1],
          'time': lines[2].split('：')[1],
          'location': lines[3].split('：')[1],
          'teacher': lines[4].split('：')[1],
        };
        courses.add(course);
      }
    }

    return courses;
  }

  Future<String?> _getData(String? addTail) async {
    final req = await get(scheduleQueryPath + userToken + (addTail ?? ''));
    return req.bodyString;
  }
}
