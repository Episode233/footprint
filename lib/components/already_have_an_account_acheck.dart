import 'package:flutter/material.dart';

import '../constants.dart';

class AlreadyHaveAnAccountCheck extends StatelessWidget {
  final bool login;
  final Function? press;
  const AlreadyHaveAnAccountCheck({
    Key? key,
    this.login = true,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? "没有账号吗 ? " : "已经有账号吗 ? ",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        GestureDetector(
          onTap: press as void Function()?,
          child: Text(
            "前往${login ? '注册' : '登录'}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: defaultPadding,
        )
      ],
    );
  }
}
