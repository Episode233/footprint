import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';

import '../Page/User/Welcome/welcome_screen.dart';

class UserMiddleWare extends GetMiddleware {
  UserStateUtil userStateUtil = Get.find();

  @override
  int? get priority => -1;

//创建任何内容之前调用此函数
  @override
  GetPage? onPageCalled(GetPage? page) {
    if (userStateUtil.isLogin() && userStateUtil.user().id != 0) {
      return page;
    }
    return GetPage(
      name: '/welcome',
      page: () => WelcomeScreen(),
    );
  }

  //这个函数将在绑定初始化之前被调用。在这里您可以更改此页面的绑定。
  // @override
  // List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
  //   print('onBindingsStart1----');
  //   //return super.onBindingsStart(bindings);
  //   bindings?.add(LoginBinding());
  //   return bindings;
  // }

//此函数将在绑定初始化后立即调用。在这里，您可以在创建绑定之后和创建页面小部件之前执行一些操作
  // @override
  // GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
  //   print('onPageBuildStart1----');
  //   //return super.onPageBuildStart(page);
  //   return page;
  // }

  //该函数将在调用 GetPage.page 函数后立即调用，并为您提供函数的结果。并获取将显示的小部件
  // @override
  // Widget onPageBuilt(Widget page) {
  //   print('onPageBuilt1 ----');
  //   //return super.onPageBuilt(page);
  //   return page;
  // }

//此函数将在处理完页面的所有相关对象（控制器、视图等）后立即调用
  // @override
  // void onPageDispose() {
  //   print('onPageDispose1 ----');
  //   super.onPageDispose();
  // }
}
