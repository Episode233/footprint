import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/user.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';

class HttpUtil extends GetConnect {
  // 本地存储
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  UserStateUtil userStateUtil = Get.find();

  Future<void> getMyInfo() async {
    final meResp = await get(apiMyInfo);
    User me =
        ApiResponse.fromJson(meResp.body, (json) => User.fromJson(json)).data;
    userStateUtil.user(me);
  }

  @override
  onInit() async {
    httpClient.timeout = const Duration(seconds: 90);
    httpClient.baseUrl = api;
    Map? form = await userStateUtil.getLocalForm();
    FlutterNativeSplash.remove();
    int tryTime = 2;
    if (form != {}) {
      while (tryTime > 0) {
        tryTime--;
        try {
          final response = await post("user/login", jsonEncode(form));
          final token = response.body['data'];
          setToken(token);
          tryTime = 0;
        } catch (e) {
          //
        }
      }
    }

    httpClient.addAuthenticator<Object?>((request) async {
      Map? form = await userStateUtil.getLocalForm();
      if (form == null) {
        return request;
      }
      final response = await post("user/login", form);
      final token = response.body['data'];
      var prefs = await _prefs;
      prefs.setString(userTokenPath, token);
      // Set the header
      request.headers['Authorization'] = "$token";
      return request;
    });

    httpClient.maxAuthRetries = 3;
  }

  void setToken(String token) {
    userStateUtil.isLogin(true);
    httpClient.addRequestModifier<Object?>((request) {
      request.headers['authorization'] = token;
      return request;
    });
    getMyInfo();
  }

  void logout() {
    userStateUtil.isLogin(false);
    userStateUtil.loginForm = {};
    userStateUtil.token = '';
    userStateUtil.user(User.empty());
    userStateUtil.rmLocalForm();
    userStateUtil.rmLocalToken();
    httpClient.removeRequestModifier<Object?>((request) => request);
  }
}
