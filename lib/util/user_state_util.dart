import 'dart:convert';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vcommunity_flutter/Model/user.dart';

import '../constants.dart';

class UserStateUtil extends GetxController {
  // 本地存储
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late Map loginForm;
  late String token;
  // LatLng nowPos = LatLng(28.746858, 115.863804);
  LatLng nowPos = LatLng(39.80818, 116.10586);
  var user = User.empty().obs;
  var isLogin = false.obs;
  getLocalToken() async {
    var prefs = await _prefs;
    String? token = prefs.getString(userTokenPath);
    return token;
  }

  rmLocalToken() async {
    var prefs = await _prefs;
    prefs.remove(userTokenPath);
  }

  getLocalForm() async {
    var prefs = await _prefs;
    String? form = prefs.getString(userLoginPath);
    if (form == null) {
      return null;
    }
    Map loginForm = jsonDecode(form);
    return loginForm;
  }

  rmLocalForm() async {
    var prefs = await _prefs;
    prefs.remove(userLoginPath);
  }

  @override
  void onInit() {
    getLocalForm().then((value) {
      if (value != null && value != {}) {
        isLogin(true);
      }
      loginForm = value ?? {};
    });
    getLocalToken().then((value) {
      token = value ?? "";
    });
    super.onInit();
  }
}
