import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../constants.dart';
import '../components/AuthorCard.dart';
import '../components/CardListTile.dart';
import '../util/http_util.dart';
import '../util/state_util.dart';

class LibrarySignSeatPage extends StatefulWidget {
  const LibrarySignSeatPage({super.key});

  @override
  State<LibrarySignSeatPage> createState() => _LibrarySignSeatPageState();
}

class _LibrarySignSeatPageState extends State<LibrarySignSeatPage> {
  final LibraryHttpUtil _httpUtil = Get.find();
  final LibraryStateUtil _stateUtil = Get.find();
  bool loading = false;
  bool getToken = false;
  bool first = true;
  String username = '';
  String password = '';
  String link = '未获得';
  String cookies = '未获得';
  String signLink = '';
  @override
  void initState() {
    super.initState();
    signLink = _stateUtil.signLink;
    _stateUtil.signLink = '';
  }

  void passCheck() async {
    setState(() {
      getToken = false;
      loading = true;
      first = false;
    });
    var ret = await _httpUtil.passSeatCheck(username, password, signLink);
    if (ret[0] == '' || ret[1] == '') {
      // Get.snackbar('错误', '服务器异常或账号密码错误');
      Get.snackbar('提示', '本功能仍在开发中');
    } else {
      setState(() {
        getToken = true;
        cookies = ret[0];
        link = ret[1];
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            Theme.of(context).colorScheme.inverseSurface));
    return Scaffold(
      appBar: AppBar(
        title: const Text('座位签到'),
      ),
      floatingActionButton: FloatingActionButton.extended(
          extendedIconLabelSpacing: 10,
          extendedPadding: const EdgeInsets.all(defaultPadding),
          heroTag: 'toWebview',
          onPressed: getToken
              ? () {
                  _stateUtil.link = link;
                  _stateUtil.cookie = cookies;
                  Get.toNamed('/tool/library_tool/webview');
                }
              : null,
          label: loading
              ? const CircularProgressIndicator()
              : const Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
          icon: loading
              ? const Text(
                  '正在加载',
                  style: TextStyle(fontSize: 17),
                )
              : const Text(
                  '前往签到',
                  style: TextStyle(fontSize: 17),
                )),
      // bottomNavigationBar: BottomAppBar(
      //   child: Row(children: [
      //     Expanded(
      //       child: Row(
      //         children: [
      //           // FilledButton.icon(
      //           //     onPressed: loading ? null : passCheck,
      //           //     icon: const Icon(Icons.insert_page_break_rounded),
      //           //     label: const Text('过校验'))
      //         ],
      //       ),
      //     ),
      //     const SizedBox(
      //       height: defaultPadding / 2,
      //     ),
      //     FilledButton.icon(
      //         onPressed: loading ? null : passCheck,
      //         icon: const Icon(Icons.insert_page_break_rounded),
      //         label: const Text('过校验'))
      //   ]),
      // ),
      body: ListView(
        children: [
          const AuthorCard(),
          const SizedBox(
            height: defaultPadding,
          ),
          Obx(() {
            if (_stateUtil.hasLoginForm()) {
              username = _stateUtil.loginForm['username'];
              password = _stateUtil.loginForm['password'];
              if (!getToken && !loading && first) {
                Future.delayed(const Duration(milliseconds: 500)).then(
                  (value) {
                    passCheck();
                  },
                );
              }
            }

            return CardListTile(
              '获得座位链接',
              mode: signLink != '' ? 1 : 0,
            );
          }),
          Obx(
            () => CardListTile(
              '通过校园网网关认证',
              mode: _httpUtil.passNetCheck(),
            ),
          ),
          // Obx(
          //   () => CardListTile(
          //     '通过智慧交大认证',
          //     mode: _httpUtil.passCasCheck(),
          //   ),
          // ),
          Obx(
            () => CardListTile(
              '获得图书馆身份认证token',
              mode: _httpUtil.getLibToken(),
            ),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '链接',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      link,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: defaultPadding / 2,
                    ),
                    Text(
                      'COOKIE',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      cookies,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
