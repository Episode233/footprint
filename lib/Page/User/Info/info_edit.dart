import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:vcommunity_flutter/Model/DataModel/update_file_response.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/user.dart';
import 'package:vcommunity_flutter/components/card_title.dart';
import 'package:vcommunity_flutter/components/formfield.dart';
import 'package:vcommunity_flutter/components/image_card.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

class UserEditScreen extends StatefulWidget {
  UserEditScreen({super.key});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  late final int userId;
  User? user;
  HttpUtil _httpUtil = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _introduceController = TextEditingController();
  final _controller = MultiImagePickerController(
      maxImages: 1,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );
  @override
  void initState() {
    userId = int.parse(Get.parameters['userId'] ?? "-1");
    _loadUser();
    super.initState();
  }

  bool isSending = false;
  Future<void> _updateUser(BuildContext context) async {
    final images = _controller.images;
    setState(() {
      isSending = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('正在提交...请勿关闭'),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      behavior: SnackBarBehavior.floating,
    ));
    Map<String, dynamic> data = {};
    int i = 0;
    if (images.length > 0) {
      for (final image in images) {
        MultipartFile file;
        if (image.hasPath) {
          file = MultipartFile(File(image.path!), filename: image.name);
        } else {
          // File file = File.fromRawPath(image.bytes!);
          // files.add(MultipartFile(file, filename: image.name));
          List<int> imgBytes = image.bytes as List<int>;
          file = MultipartFile(imgBytes, filename: image.name);
        }
        data.addAll({"file$i": file});
        i++;
      }
      final formData = FormData(data);
      final response = await _httpUtil.post(apiSendFile, formData);
      if (response.status.hasError) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('提交失败，未知错误'),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          behavior: SnackBarBehavior.floating,
        ));
        setState(() {
          isSending = false;
        });
        return;
      }
      if (response.body['success']) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('图片上传成功'),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('提交失败，图片上传失败'),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          behavior: SnackBarBehavior.floating,
        ));
        setState(() {
          isSending = false;
        });
        return;
      }
      ApiResponse<UpdateFileData> resp = ApiResponse.fromJson(
          response.body, (json) => UpdateFileData.fromJson(json));
      Map<String, String> pics = resp.data.succMap;
      var keys = pics.keys;
      List<String> picUrls = [];
      for (var element in keys) {
        picUrls.add(pics[element]!);
      }
      if (picUrls.isNotEmpty) {
        user!.icon = picUrls.first;
      }
      // else {
      //   user!.icon = user!.icon.split('')[1];
      // }
    } else {
      user!.icon = user!.icon.split('')[1];
    }
    var updateResp = await _httpUtil.put(apiUserInfo, user!.toJson());
    if (updateResp.status.hasError) {
      setState(() {
        isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('服务器错误，修改用户失败'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (updateResp.body['success']) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('修改成功'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
    }
    _httpUtil.getMyInfo();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(title: Text("用户信息修改")),
        body: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: ListView(
            children: [
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: [
                    const CardTitle(
                      "用户头像",
                      watchMore: false,
                    ),
                    const SizedBox(
                      height: defaultPadding / 2,
                    ),
                    MultiImagePickerView(
                      controller: _controller,
                      initialContainerBuilder: (context, pickerCallback) {
                        return Row(children: [
                          SizedBox(
                            height: 130,
                            width: 130,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          defaultBorderRadius))),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add),
                                    Text('添加')
                                  ]),
                              onPressed: () {
                                pickerCallback();
                              },
                            ),
                          ),
                        ]);
                      },
                      itemBuilder: (context, file, deleteCallback) {
                        return ImageCard(
                            file: file, deleteCallback: deleteCallback);
                      },
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    const CardTitle(
                      "邮箱",
                      watchMore: false,
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    TextFormField(
                      controller: _emailController,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      decoration: MyFormField().getTextFieldDecoration(
                          '注册邮箱', context, Icons.mail_rounded),
                      validator: (value) {
                        RegExp reg = RegExp(
                            r'[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');
                        if (!reg.hasMatch(value!)) {
                          return '请输入正确的邮箱';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    const CardTitle(
                      "昵称",
                      watchMore: false,
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    TextFormField(
                      controller: _nickNameController,
                      textInputAction: TextInputAction.next,
                      maxLength: 32,
                      onSaved: (nickName) {
                        user!.nickName = nickName!;
                      },
                      decoration: MyFormField().getTextFieldDecoration('昵称',
                          context, Icons.drive_file_rename_outline_rounded),
                      validator: (value) {
                        if (value == null) return '昵称不为空';
                        RegExp reg = RegExp(r"^[\w\u4e00-\u9fa5]{1,32}$");
                        print(value);
                        if (!reg.hasMatch(value)) {
                          return '昵称长度为1-32位';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    const CardTitle(
                      "简介",
                      watchMore: false,
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    TextFormField(
                      controller: _introduceController,
                      textInputAction: TextInputAction.next,
                      onSaved: (introduce) {
                        user!.introduce = introduce!;
                      },
                      maxLength: 200,
                      minLines: 3,
                      maxLines: 5,
                      decoration: MyFormField().getTextFieldDecoration('简介(可选)',
                          context, Icons.perm_contact_calendar_rounded),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const CardTitle(
                      "生日",
                      watchMore: false,
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    FormField(
                      builder: (state) => Row(
                        children: [
                          Expanded(
                            child: InkWell(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                onTap: () => _handlerDateUpdate(),
                                child: Container(
                                    padding:
                                        const EdgeInsets.all(defaultPadding),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(50),
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.date_range_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inverseSurface),
                                        const SizedBox(
                                          width: defaultPadding,
                                        ),
                                        Text(
                                          user!.birthday
                                              .toString()
                                              .split(" ")
                                              .first,
                                          style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .fontSize),
                                        ),
                                      ],
                                    ))),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    const CardTitle(
                      "性别",
                      watchMore: false,
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Row(
                      children: [
                        const Text("男"),
                        Switch(
                          value: user!.gender,
                          onChanged: (value) {
                            setState(() {
                              user!.gender = value;
                            });
                          },
                          thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Icon(Icons.list_alt_rounded);
                            }
                            return user!.gender
                                ? const Icon(Icons.female_rounded)
                                : const Icon(Icons.male_rounded);
                          }),
                        ),
                        const Text("女"),
                      ],
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: isSending
                                ? null
                                : () {
                                    _formKey.currentState!.save();
                                    if (_formKey.currentState!.validate()) {
                                      _updateUser(context);
                                    }
                                  },
                            child: const Padding(
                              padding: EdgeInsets.all(defaultButtonPadding),
                              child: Text("修改"),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: defaultPadding),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  _handlerDateUpdate() async {
    final DateTime? dateTime = await showDatePicker(
      context: context,
      //定义控件打开时默认选择日期
      initialDate: user!.birthday ?? DateTime.now(),
      //定义控件最早可以选择的日期
      firstDate: DateTime(1970, 1),
      //定义控件最晚可以选择的日期
      lastDate: DateTime(2050, 1),
    );
    if (dateTime != null) {
      setState(() {
        user!.birthday = dateTime;
      });
    }
  }

  void _loadUser() async {
    Response response = await _httpUtil.get(apiUserInfo + userId.toString());
    if (response.body['data'] != null) {
      User getUser =
          ApiResponse.fromJson(response.body, (json) => User.fromJson(json))
              .data;
      setState(() {
        user = getUser;
        _emailController.text = user!.email;
        _nickNameController.text = user!.nickName;
        _introduceController.text = user!.introduce;
      });
      if (getUser.icon != "") {
        var iconData = (await NetworkAssetBundle(Uri.parse(getUser.icon))
                .load(getUser.icon))
            .buffer
            .asUint8List();
        ImageFile iconFile = ImageFile(getUser.icon,
            extension: 'png', name: getUser.icon, bytes: iconData);
        setState(
          () {
            _controller.addImage(iconFile);
          },
        );
      }
    }
  }
}
