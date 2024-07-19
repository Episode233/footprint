import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class LibraryHttpUtil extends GetConnect {
  // 本地存储
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  bool get allowAutoSignedCert => true;
  var passNetCheck = 0.obs;
  var passCasCheck = 0.obs;
  var getLibToken = 0.obs;
  String cookie = '';
  @override
  void onInit() {
    super.onInit();
    httpClient.timeout = const Duration(seconds: 30);
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

  void setCookies(Response resp) {
    final cookies = resp.headers?['set-cookie'] ?? '';
    if (cookies != '') {
      httpClient.addRequestModifier<Object?>((request) {
        request.headers['cookie'] = cookies;
        return request;
      });
      cookie = cookies;
    }
  }

  Future<String> _encodePsw(String psw) async {
    Response resp = await post(
      API_ENCODE_PASSWORD,
      'pwd=$psw',
      headers: {'content-type': 'application/x-www-form-urlencoded'},
    );
    return jsonDecode(resp.body)['passwordEnc'];
  }

  String _getLt(String html) {
    final pattern = RegExp(r'LT-\d+-[a-zA-Z0-9]+');
    final match = pattern.firstMatch(html);

    if (match != null) {
      final result = html.substring(match.start, match.end);
      return result;
    }
    return '';
  }

  String parseUrl(originalString) {
    Uri originalUri = Uri.parse(originalString);

    String path = originalUri.path;
    String query = originalUri.query;
    String from =
        Uri.encodeQueryComponent(originalUri.queryParameters['from']!);

    Uri targetUri = Uri(
      scheme: originalUri.scheme,
      host: originalUri.host,
      path: path,
      query: query,
      fragment: originalUri.fragment,
    );

    String targetString = targetUri.replace(
      queryParameters: {
        'from': from,
        'path': '/',
      },
    ).toString();

    return targetString;
  }

  Future<List<String>> passNetworkCheck(
      String username, String password) async {
    passNetCheck(2);
    passCasCheck(2);
    getLibToken(2);
    Response getResp = await get(API_TO_NETWORK_CHECK);
    setCookies(getResp);

    Response resp = await post(API_PASS_NETWORK_CHECK,
        'auth_type=local&username=$username&sms_code=&password=$password',
        headers: {'content-type': 'application/x-www-form-urlencoded'});
    if (resp.statusCode == 302) {
      String redirectPath = resp.headers?['location'] ?? '';
      if (redirectPath
          .contains('http://lib2.ecjtu.edu.cn/wengine-auth/token-login')) {
        //验证1通过
        passNetCheck(1);
        var ret = [getResp.headers?['set-cookie'] ?? '', redirectPath];
        if (ret[0] == '' || ret[1] == '') {
          getLibToken(0);
        } else {
          getLibToken(1);
        }
        return ret;
        // Response html = await get(redirectPath);
        // setCookies(html);
        // String lt = _getLt(html.bodyString ?? '');
        // String encodedPsw = await _encodePsw(password);
        // Response casResp = await post(
        //   API_PASS_CAS_CHECK,
        //   'encodedService=http%253a%252f%252flib2.ecjtu.edu.cn%252floginmall.aspx&service=http%3A%2F%2Flib2.ecjtu.edu.cn%2Floginmall.aspx&serviceName=null&loginErrCnt=0&username=$username&password=$encodedPsw&lt=$lt',
        //   headers: {'content-type': 'application/x-www-form-urlencoded'},
        // );

        // passCasCheck(1);
        // var ret = [
        //   casResp.headers?['set-cookie'] ?? '',
        //   casResp.headers?['location'] ?? ''
        // ];
        // if (ret[0] == '' || ret[1] == '') {
        //   getLibToken(0);
        // } else {
        //   getLibToken(1);
        // }
        // return ret;
      } else {
        passNetCheck(0);
        passCasCheck(0);
        getLibToken(0);
      }
    }
    return ['', ''];
  }

  Future<List<String>> passSeatCheck(
      String username, String password, String seatLink) async {
    passNetCheck(2);
    passCasCheck(2);
    getLibToken(2);

    return ["",""];               // 待删

    Response getResp = await get(API_TO_NETWORK_CHECK);
    setCookies(getResp);
    Response resp = await post(API_PASS_NETWORK_CHECK,
        'auth_type=local&username=$username&sms_code=&password=$password',
        headers: {'content-type': 'application/x-www-form-urlencoded'});
    httpClient.followRedirects = false;
    Response seatResp = await get(seatLink);
    String seatSign = seatResp.headers?['location'] ?? '';
    passNetCheck(1);
    Response seatSignResp = await get(seatSign);
    setCookies(seatSignResp);
    String passCheckApi = seatSignResp.headers?['location'] ?? '';
    var ret = [cookie, passCheckApi];
    if (ret[0] == '' || ret[1] == '') {
      getLibToken(0);
    } else {
      getLibToken(1);
    }
    return ret;
  }
}
