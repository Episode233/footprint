import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../util/state_util.dart';

class LibraryWebviewPage extends StatefulWidget {
  const LibraryWebviewPage({super.key});
  @override
  State<LibraryWebviewPage> createState() => _LibraryWebviewPageState();
}

class _LibraryWebviewPageState extends State<LibraryWebviewPage> {
  final LibraryStateUtil _stateUtil = Get.find();
  int progress = 0;
  bool isShowSnackbar = false;
  bool isReload = false;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            setState(() {
              this.progress = progress;
            });
          },
          onPageStarted: (url) {
            final WebViewCookieManager cookieManager = WebViewCookieManager();

            final cookieRegex =
                RegExp(r'(_?.*)=([\S\s]*); path=(\S+); HttpOnly');
            final cookieRegex2 =
                RegExp(r'(_.*)=([\S\s]*); path=(\S+); HttpOnly');
            for (String i in _stateUtil.cookie.split(',')) {
              final matches = cookieRegex.allMatches(i);
              for (Match match in matches) {
                final name = match.group(1);
                final value = match.group(2);
                final path = match.group(3);
                cookieManager.setCookie(
                  WebViewCookie(
                    name: name ?? '',
                    value: value ?? '',
                    domain: 'http://lib2.ecjtu.edu.cn/',
                    path: path ?? '/',
                  ),
                );
              }
              final matches2 = cookieRegex2.allMatches(i);
              for (Match match in matches2) {
                final name = match.group(1);
                final value = match.group(2);
                final path = match.group(3);
                cookieManager.setCookie(
                  WebViewCookie(
                    name: name ?? '',
                    value: value ?? '',
                    domain: 'http://lib2.ecjtu.edu.cn/',
                    path: path ?? '/',
                  ),
                );
              }
            }
          },
          onPageFinished: (String url) async {
            webViewController
                .runJavaScriptReturningResult(
                    'document.documentElement.innerHTML.indexOf("服务器错误") !== -1')
                .then((value) {
              if (value.toString().contains('true') && !isReload) {
                webViewController.reload().then((value) => isReload = true);
              }
            });

            webViewController
                .runJavaScriptReturningResult(
                    'document.getElementById("username").value = "${_stateUtil.loginForm["username"]}";document.getElementById("password").value = "${_stateUtil.loginForm["password"]}";submitInfo();')
                .then((resp) {
              if (!resp.toString().contains('Error')) {
                if (!isShowSnackbar) {
                  isShowSnackbar = true;
                  // Get.snackbar('提示', '检查到cookie失效,自动通过');
                }
              }
            });
            String loginNewJs =
                'document.getElementById("user_name").value = "${_stateUtil.loginForm["username"]}";document.querySelector("input[name=\'password\']").value = "${_stateUtil.loginForm["password"]}";document.querySelector(".el-button-login").click();';
            print(loginNewJs);
            webViewController
                .runJavaScriptReturningResult(loginNewJs)
                .then((resp) {
              if (!resp.toString().contains('Error')) {
                if (!isShowSnackbar) {
                  isShowSnackbar = true;
                  // Get.snackbar('提示', '检查到cookie失效,自动通过');
                }
              }
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(_stateUtil.link)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_stateUtil.link));
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'toWebview',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('座位预约系统'),
        ),
        body: Column(
          children: [
            if (progress != 100)
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            Expanded(
              child: WebViewWidget(
                controller: webViewController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
