import 'dart:convert';

import 'package:flutter_shortcuts/flutter_shortcuts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class LibraryStateUtil extends GetxController {
  // 本地存储
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final FlutterShortcuts flutterShortcuts = Get.find();
  late Map loginForm;
  List likeSeat = [];
  String link = '';
  String cookie = '';
  String signLink = '';
  var hasLoginForm = false.obs;
  getLocalForm() async {
    var prefs = await _prefs;
    String? form = prefs.getString(USER_PATH);
    if (form == null) {
      return null;
    }
    Map loginForm = jsonDecode(form);
    this.loginForm = loginForm;
    return loginForm;
  }

  setLocalForm(String value) async {
    loginForm = jsonDecode(value);
    var prefs = await _prefs;
    prefs.setString(USER_PATH, value);
    hasLoginForm(true);
  }

  getLikeSeat() async {
    var prefs = await _prefs;
    likeSeat = jsonDecode(prefs.getString(LIKE_SEAT_PATH) ?? '[]');
  }

  setLikeSeat() async {
    var prefs = await _prefs;
    // print(jsonEncode(likeSeat));
    prefs.setString(LIKE_SEAT_PATH, jsonEncode(likeSeat));
  }

  void initShortcuts() async {
    var prefs = await _prefs;
    bool isInit = prefs.getBool(SHORT_CUTS_PATH) ?? false;
    if (!isInit) {
      prefs.setBool(SHORT_CUTS_PATH, true);
      flutterShortcuts.setShortcutItems(
        shortcutItems: <ShortcutItem>[
          const ShortcutItem(
            id: "1",
            action: 'toScanPage',
            shortLabel: '扫码签到',
            icon: 'assets/icons/qr-code.png',
          ),
          const ShortcutItem(
            id: "2",
            action: 'toScanPage',
            shortLabel: '无最近签到',
            icon: 'assets/icons/bag.png',
          ),
        ],
      );
    }
  }

  @override
  void onInit() {
    getLocalForm().then((value) {
      if (value != null && value != {}) {
        hasLoginForm(true);
      }
      loginForm = value ?? {};
    });
    getLikeSeat();
    if (GetPlatform.isAndroid) {
      initShortcuts();
    }

    super.onInit();
  }
}
