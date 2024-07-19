import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: "login_btn",
          child: ElevatedButton(
            onPressed: () => Get.offNamed("/login"),
            child: const Padding(
              padding: EdgeInsets.all(defaultButtonPadding),
              child: Text("登录"),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Get.offNamed("/signup"),
          style: ElevatedButton.styleFrom(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.onSecondary,
              elevation: 0),
          child: const Padding(
            padding: EdgeInsets.all(defaultButtonPadding),
            child: Text("注册"),
          ),
        ),
      ],
    );
  }
}
