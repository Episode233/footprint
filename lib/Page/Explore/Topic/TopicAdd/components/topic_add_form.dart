import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/_http/_stub/_file_decoder_stub.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:vcommunity_flutter/Model/DataModel/update_file_response.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/topic.dart';
import 'package:vcommunity_flutter/components/card_title.dart';
import 'package:vcommunity_flutter/components/image_card.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

class TopicAddForm extends StatefulWidget {
  String? topicId;
  TopicAddForm({Key? key, this.topicId}) : super(key: key);

  @override
  State<TopicAddForm> createState() => _TopicAddForm();
}

class _TopicAddForm extends State<TopicAddForm> {
  HttpUtil _httpUtil = Get.find();
  final _nameController = TextEditingController();
  final _introduceController = TextEditingController();
  final _controller = MultiImagePickerController(
      maxImages: 1,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );

  bool isSending = false;
  bool _isEdit = false;
  bool _isLoadingTopic = false;
  late Topic _topic;

  @override
  initState() {
    if (widget.topicId != null) {
      _isEdit = true;
      _isLoadingTopic = true;
    }

    if (_isEdit) {
      _loadTopic();
    }

    super.initState();
  }

  Future<void> _sendTopic(BuildContext context) async {
    final images = _controller.images;
    var name = _nameController.text;
    var introduce = _introduceController.text;
    var imageSize = images.length;
    var warnMess = "";
    if (name.isEmpty) {
      warnMess += "话题名称不能为空\n";
    }
    if (imageSize == 0) {
      warnMess += "尚未选择话题ICON";
    }
    if (warnMess.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(warnMess),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

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
    var topic = Topic(name: name, introduce: introduce, icon: picUrls.first);
    var addResp;
    if (_isEdit) {
      topic.id = int.parse(widget.topicId!);
      print(topic.id);
      addResp = await _httpUtil.put(apiAddTopic, topic.toJson());
    } else {
      addResp = await _httpUtil.post(apiAddTopic, topic.toJson());
    }
    if (addResp.status.hasError) {
      setState(() {
        isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('服务器错误，添加话题失败'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (addResp.body['success']) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('添加成功，等待审核'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTopic) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return ListView(children: [
      Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(children: [
          TextField(
            controller: _nameController,
            maxLength: 20,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            decoration: InputDecoration(
              labelText: "话题名称",
              hintText: "输入你想添加的话题名称",
              filled: true,
              fillColor: Theme.of(context).colorScheme.background,
              prefixIcon: const Icon(Icons.topic),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadius)),
              ),
            ),
          ),
          const CardTitle(
            "话题ICON",
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
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadius))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.add), Text('添加')]),
                    onPressed: () {
                      pickerCallback();
                    },
                  ),
                ),
              ]);
            },
            itemBuilder: (context, file, deleteCallback) {
              return ImageCard(file: file, deleteCallback: deleteCallback);
            },
          ),
          const SizedBox(
            height: defaultPadding * 2,
          ),
          TextField(
            controller: _introduceController,
            minLines: 5,
            maxLines: 10,
            maxLength: 200,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            decoration: InputDecoration(
              labelText: "话题介绍(选填)",
              hintText: "输入你想添加的话题的简介",
              filled: true,
              fillColor: Theme.of(context).colorScheme.background,
              prefixIcon: const Icon(Icons.bookmark),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadius)),
              ),
            ),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: isSending ? null : () => _sendTopic(context),
                  child: const Padding(
                    padding: EdgeInsets.all(defaultButtonPadding),
                    child: Text("提交"),
                  ),
                ),
              )
            ],
          ),
        ]),
      ),
    ]);
  }

  void _loadTopic() async {
    final resp = await _httpUtil.get(apiGetTopicDetail + widget.topicId!);
    final loadTopic =
        ApiResponse.fromJson(resp.body, (json) => Topic.fromJson(json)).data;
    _topic = loadTopic;
    _nameController.text = _topic.name;
    _introduceController.text = _topic.introduce ?? '';

    if (_topic.icon.removeAllWhitespace != "") {
      var iconData =
          (await NetworkAssetBundle(Uri.parse(_topic.icon)).load(_topic.icon))
              .buffer
              .asUint8List();
      ImageFile iconFile = ImageFile(_topic.icon,
          extension: 'png', name: _topic.icon, bytes: iconData);
      setState(
        () {
          _controller.addImage(iconFile);
        },
      );
    }

    setState(() {
      _isLoadingTopic = false;
    });
  }
}
