import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vcommunity_flutter/components/formfield.dart';

import '../../../../components/already_have_an_account_acheck.dart';
import '../../../../constants.dart';
import '../../../../util/http_util.dart';
import '../../Signup/signup_screen.dart';

class LoginForm extends StatelessWidget {
  LoginForm({
    Key? key,
  }) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final HttpUtil _httpUtil = Get.find();
  // 本地存储
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Map form = {"account": "", "password": ""};
  // 登录
  void _login(BuildContext context) async {
    var prefs = await _prefs;
    _httpUtil.post(apiLogin, form).then((response) {
      if (!response.body['success']) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.body['errorMsg']),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          behavior: SnackBarBehavior.floating,
        ));
      }
      // 存储用户token
      String token = response.body['data'];
      prefs.setString(userTokenPath, token);
      Map saveForm = {"account": form["account"], "password": form["password"]};
      prefs.setString(userLoginPath, jsonEncode(saveForm));
      // 更新token
      _httpUtil.setToken(token);
      Get.offAllNamed('/');
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("服务器连接失败，请稍后再试"),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: Theme.of(context).colorScheme.primary,
            onSaved: (account) {
              form['account'] = account;
            },
            decoration: MyFormField().getTextFieldDecoration(
                '登录账号', context, Icons.account_circle_rounded),
            validator: (value) {
              RegExp reg = RegExp(r'^\w{6,15}$');
              if (!reg.hasMatch(value!)) {
                return '账号长度为6-15位';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: Theme.of(context).colorScheme.primary,
              onSaved: (password) {
                form['password'] = password;
              },
              decoration: MyFormField()
                  .getTextFieldDecoration('登录密码', context, Icons.lock),
              validator: (value) {
                if (value == null) return '验证码不为空';
                RegExp reg = RegExp(r'^\w{6,32}$');
                if (!reg.hasMatch(value)) {
                  return '密码长度为6-32位';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: defaultPadding),
          Row(
            children: [
              Expanded(
                child: Hero(
                  tag: "login_btn",
                  child: ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.save();
                      if (_formKey.currentState!.validate()) {
                        _login(context);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(defaultButtonPadding),
                      child: Text("登录"),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Get.offNamed("/signup");
            },
          ),
        ],
      ),
    );
  }
}
