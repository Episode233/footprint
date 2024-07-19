import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vcommunity_flutter/components/formfield.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

import '../../../../components/already_have_an_account_acheck.dart';
import 'package:vcommunity_flutter/constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final HttpUtil _httpUtil = Get.find();
  // 本地存储
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Map form = {"account": "", "code": "", "email": "", "password": ""};
  bool isSendCode = false;
  // 发送验证码
  void _sendCode(BuildContext context) async {
    if (isSendCode) return null;

    _formKey.currentState!.save();
    RegExp reg = RegExp(r'[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');
    if (!reg.hasMatch(form['email']!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('邮箱格式错误'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));

      return;
    }
    setState(() {
      isSendCode = true;
    });
    final String email = form['email'];
    final response = await _httpUtil.post(apiSendCode + email, "");
    if (!response.body['success']) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.body['errorMsg']),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('发送成功'),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      behavior: SnackBarBehavior.floating,
    ));
    setState(() {
      isSendCode = true;
    });
  }

  // 注册用户
  void _regist(BuildContext context) async {
    final response = await _httpUtil.post(apiRegister, form);
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
    var prefs = await _prefs;
    prefs.setString(userTokenPath, token);
    Map saveForm = {"account": form["account"], "password": form["password"]};
    prefs.setString(userLoginPath, jsonEncode(saveForm));
    // 更新token
    _httpUtil.setToken(token);
    Get.offAllNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          TextFormField(
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: Theme.of(context).colorScheme.primary,
            onSaved: (email) {
              form["email"] = email;
            },
            decoration: MyFormField()
                .getTextFieldDecoration('注册邮箱', context, Icons.mail_rounded),
            validator: (value) {
              RegExp reg =
                  RegExp(r'[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');
              if (!reg.hasMatch(value!)) {
                return '请输入正确的邮箱';
              }
              return null;
            },
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      onSaved: (code) {
                        form['code'] = code;
                      },
                      decoration: MyFormField().getTextFieldDecoration(
                          '验证码', context, Icons.message_rounded),
                      validator: (value) {
                        if (value!.length != 6) {
                          return "验证码格式错误";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                      width: 140,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: ElevatedButton.icon(
                          onPressed:
                              isSendCode ? null : () => _sendCode(context),
                          label: const Icon(Icons.send),
                          icon: const Padding(
                            padding: EdgeInsets.all(defaultButtonPadding),
                            child: Text("发送"),
                          ),
                        ),
                      )),
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
            child: TextFormField(
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: Theme.of(context).colorScheme.primary,
              onSaved: (account) {
                form['account'] = account;
              },
              decoration: MyFormField().getTextFieldDecoration(
                  '账号', context, Icons.account_circle_rounded),
              validator: (value) {
                RegExp reg = RegExp(r'^\w{6,15}$');
                if (!reg.hasMatch(value!)) {
                  return '账号长度为6-15位';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
            child: TextFormField(
              textInputAction: TextInputAction.next,
              obscureText: true,
              cursorColor: Theme.of(context).colorScheme.primary,
              onSaved: (password) {
                form['password'] = password;
              },
              decoration: MyFormField().getTextFieldDecoration(
                  '密码', context, Icons.password_rounded),
              validator: (value) {
                if (value == null) return '密码不为空';
                RegExp reg = RegExp(r'^\w{6,32}$');
                if (!reg.hasMatch(value)) {
                  return '密码长度为6-32位';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: Theme.of(context).colorScheme.primary,
              decoration: MyFormField()
                  .getTextFieldDecoration('确认密码', context, Icons.lock),
              validator: (value) {
                _formKey.currentState!.save();
                if (form['password'] != value!) {
                  return '确认密码不一致';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.save();
                    if (_formKey.currentState!.validate()) {
                      _regist(context);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(defaultButtonPadding),
                    child: Text("注册"),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () => Get.offNamed("login"),
          )
        ],
      ),
    );
  }
}
