import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/user.dart';
import 'package:vcommunity_flutter/constants.dart';

import '../../../../util/user_state_util.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final UserStateUtil _userStateUtil = Get.find();

  Widget _buildTile() {
    double width = Get.width / 3;
    return Row(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: Obx(() => CircleAvatar(
              foregroundImage: NetworkImage(_userStateUtil.user().icon))),
        ),
        Expanded(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(_userStateUtil.user().nickName)),
                    const SizedBox(
                      height: defaultPadding / 3,
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          width: width,
                          child: Obx(
                            () => Text(
                              "Lv.${_userStateUtil.user().level}",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .fontSize),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Obx(
                            () => Text(
                              "${_userStateUtil.user().exp}/20000",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: defaultPadding / 4,
                    ),
                    Stack(
                      children: [
                        Positioned(
                            child: Container(
                          height: 6,
                          width: width,
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                        )),
                        Positioned(
                            child: Container(
                          height: 6,
                          width: width / 20000,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                        ))
                      ],
                    )
                  ],
                ))),
        SizedBox(
          width: 90,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Obx(
              () => ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.background),
                onPressed: () {
                  Get.toNamed("/user/${_userStateUtil.user().id}");
                },
                icon: _userStateUtil.isLogin()
                    ? const Icon(Icons.edit_note_rounded)
                    : const Icon(Icons.login_rounded),
                label: _userStateUtil.isLogin()
                    ? const Icon(Icons.keyboard_arrow_right)
                    : const Text('登录'),
              ),
            )
          ]),
        )
      ],
    );
  }

// 创建动态、关注、粉丝
  Widget _buildTriple() {
    return Row(
      children: [
        Obx(() => _buildTripleItem("动态", _userStateUtil.user().blogs,
            () => Get.toNamed("/user/blogs"))),
        SizedBox(
          height: 30,
          child: VerticalDivider(
              color: Theme.of(context).colorScheme.primaryContainer),
        ),
        _buildTripleItem(
            "关注", _userStateUtil.user().follows, () => Get.toNamed("/test")),
        SizedBox(
          height: 30,
          child: VerticalDivider(
              color: Theme.of(context).colorScheme.primaryContainer),
        ),
        _buildTripleItem("粉丝", _userStateUtil.user().fans, () {}),
      ],
    );
  }

  Widget _buildTripleItem(String type, int number, Function()? onTap) {
    return Expanded(
        flex: 1,
        child: InkWell(
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultBorderRadius)),
          onTap: onTap,
          child: Column(children: [
            Text(
              number.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium!.fontSize,
                  height: 1),
            ),
            Text(
              type,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodySmall!.fontSize),
            )
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    double width = Get.width / 3;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: defaultPadding),
          child: _buildTile(),
        ),
        Card(
          margin: const EdgeInsets.only(top: defaultPadding),
          elevation: 0,
          child: Padding(
              padding: const EdgeInsets.all(defaultPadding / 2),
              child: _buildTriple()),
        )
      ],
    );
  }
}
