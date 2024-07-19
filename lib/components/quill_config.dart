import 'dart:convert';
import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';
import 'package:flutter/material.dart' as md;
import '../Model/DataModel/update_file_response.dart';
import '../Model/api_response.dart';
import '../constants.dart';
import '../universal_ui/universal_ui.dart';
import '../util/http_util.dart';
import '../util/image_util.dart';

class QuillConfig {
  final HttpUtil _httpUtil = Get.find();
  final UserStateUtil _userStateUtil = Get.find();
  Future<String> onImagePickCallback(File file) async {
    Map<String, dynamic> data = {};
    int i = 0;
    MultipartFile mFile;
    if (GetPlatform.isWeb) {
      List<int> imgBytes = await comporessList(file.readAsBytesSync());
      mFile = MultipartFile(imgBytes, filename: file.path);
    } else {
      List<int> imgBytes = await compressFile(file) as List<int>;
      mFile = MultipartFile(imgBytes, filename: file.path);
    }
    data.addAll({"file$i": mFile});
    final formData = FormData(data);
    final response = await _httpUtil.post(apiSendFile, formData);
    if (response.status.hasError) {
      return "";
    }
    if (response.body['success']) {
      ApiResponse<UpdateFileData> resp = ApiResponse.fromJson(
          response.body, (json) => UpdateFileData.fromJson(json));
      Map<String, String> pics = resp.data.succMap;
      var keys = pics.keys;
      List<String> picUrls = [];
      for (var element in keys) {
        picUrls.add(pics[element]!);
      }
      return picUrls.first;
    }
    // Copies the picked file from temporary cache to applications directory
    return "";
  }

  Future<String?> webImagePickImpl(
      OnImagePickCallback onImagePickCallback) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result == null) {
      return null;
    }

    Map<String, dynamic> data = {};
    int i = 0;
    List<int> imgBytes = await comporessList(result.files.first.bytes!);
    MultipartFile mFile =
        MultipartFile(imgBytes, filename: result.files.first.name);
    data.addAll({"file$i": mFile});
    final formData = FormData(data);
    final response = await _httpUtil.post(apiSendFile, formData);
    if (response.status.hasError) {
      return "";
    }
    if (response.body['success']) {
      ApiResponse<UpdateFileData> resp = ApiResponse.fromJson(
          response.body, (json) => UpdateFileData.fromJson(json));
      Map<String, String> pics = resp.data.succMap;
      var keys = pics.keys;
      List<String> picUrls = [];
      for (var element in keys) {
        picUrls.add(pics[element]!);
      }
      return picUrls.first;
    }
    return "";
  }

  Future<String?> openFileSystemPickerForDesktop(BuildContext context) async {
    var a = await FilesystemPicker.open(
      context: context,
      rootDirectory: await getApplicationDocumentsDirectory(),
      fsType: FilesystemType.file,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
    return a;
  }

  Future<String> onImagePaste(Uint8List imageBytes) async {
    Map<String, dynamic> data = {};
    int i = 0;
    List<int> imgBytes = await comporessList(imageBytes);
    MultipartFile mFile = MultipartFile(imgBytes, filename: 'pastepic.png');
    data.addAll({"file$i": mFile});
    final formData = FormData(data);
    final response = await _httpUtil.post(apiSendFile, formData);
    if (response.status.hasError) {
      return "";
    }
    if (response.body['success']) {
      ApiResponse<UpdateFileData> resp = ApiResponse.fromJson(
          response.body, (json) => UpdateFileData.fromJson(json));
      Map<String, String> pics = resp.data.succMap;
      var keys = pics.keys;
      List<String> picUrls = [];
      for (var element in keys) {
        picUrls.add(pics[element]!);
      }
      return picUrls.first;
    }
    return "";
  }

  void _onLaunchUrl(value) {
    if (GetUtils.isURL(value)) {
      showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: false,
          useRootNavigator: true,
          useSafeArea: true,
          builder: (BuildContext context) {
            return SizedBox(
                height: 250, //对话框高度就是此高度
                child: ListView(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      title: const md.Text("点击跳转"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: AnyLinkPreview(
                        link: value,
                        proxyUrl:
                            GetPlatform.isWeb ? "" : null,
                        displayDirection: UIDirection.uiDirectionHorizontal,
                        cache: const Duration(hours: 1),
                        borderRadius: defaultBorderRadius,
                        previewHeight: 180,
                        backgroundColor:
                            Theme.of(Get.context!).colorScheme.background,
                        errorWidget: Container(
                          color: Theme.of(Get.context!).colorScheme.background,
                          child: const md.Center(
                            child: md.Text('网页无法打开'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
          });
    } else {
      Get.toNamed(value.split('https://')[1]);
    }
  }

  void _getMetadata(String url) async {
    Metadata? _metadata = await AnyLinkPreview.getMetadata(
      link: url,
      cache: const Duration(days: 7),
      proxyUrl: "https://cors-anywhere.herokuapp.com/", // Needed for web app
    );
  }

  Widget onlyShow(BuildContext context, String content, String blogId) {
    Color onBackground = Theme.of(context).colorScheme.onBackground;
    QuillController quillController = QuillController(
        document: Document.fromJson(jsonDecode(content)),
        selection: const TextSelection.collapsed(offset: 0));
    Widget showWidget = QuillEditor(
      showCursor: false,
      controller: quillController,
      onImagePaste: onImagePaste,
      scrollController: ScrollController(),
      scrollable: false,
      padding: EdgeInsets.zero,
      onLaunchUrl: _onLaunchUrl,
      onTapUp: (a, b) {
        Get.toNamed('/blog/$blogId');
        return true;
      },
      focusNode: FocusNode(skipTraversal: true),
      autoFocus: false,
      expands: false,
      readOnly: true, // true for view only mode
      // padding:
      //     const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 0),

      embedBuilders: GetPlatform.isWeb
          ? defaultEmbedBuildersWeb
          : [...FlutterQuillEmbeds.builders()],
      customStyles: DefaultStyles(
        link: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
        paragraph: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 13,
              color: onBackground,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(2, 0),
            const Tuple2(0, 0),
            null),
        h1: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 28,
              color: onBackground,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(8, 0),
            const Tuple2(0, 0),
            null),
        h2: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 24,
              color: onBackground,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(6, 0),
            const Tuple2(0, 0),
            null),
        h3: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 20,
              color: onBackground,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(5, 0),
            const Tuple2(0, 0),
            null),
      ),
      locale: const Locale('zh', 'cn'),
    );
    return showWidget;
  }

  Widget onlyShowLarge(BuildContext context, String content) {
    // _getMetadata("https://www.baidu.com");
    Color onBackground = Theme.of(context).colorScheme.onBackground;
    QuillController quillController = QuillController(
        document: Document.fromJson(jsonDecode(content)),
        selection: const TextSelection.collapsed(offset: 0));
    Widget showWidget = QuillEditor(
      showCursor: false,
      controller: quillController,
      onImagePaste: onImagePaste,
      scrollController: ScrollController(),
      scrollable: false,
      padding: EdgeInsets.zero,
      onLaunchUrl: _onLaunchUrl,
      focusNode: FocusNode(skipTraversal: true),
      autoFocus: false,
      expands: false,
      readOnly: true, // true for view only mode
      // padding:
      //     const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 0),

      embedBuilders: GetPlatform.isWeb
          ? defaultEmbedBuildersWeb
          : [...FlutterQuillEmbeds.builders()],
      customStyles: DefaultStyles(
        link: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
        paragraph: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 16,
              color: onBackground,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(3.5, 0),
            const Tuple2(0, 0),
            null),
        h1: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 32,
              color: onBackground,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(8, 0),
            const Tuple2(0, 0),
            null),
        h2: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 28,
              color: onBackground,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(6, 0),
            const Tuple2(0, 0),
            null),
        h3: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 23,
              color: onBackground,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(5, 0),
            const Tuple2(0, 0),
            null),
      ),
      locale: const Locale('zh', 'cn'),
    );
    return showWidget;
  }

  Widget onlyShowSmall(BuildContext context, String content) {
    Color onBackground = Theme.of(context).colorScheme.onBackground;
    QuillController quillController = QuillController(
        document: Document.fromJson(jsonDecode(content)),
        selection: const TextSelection.collapsed(offset: 0));
    Widget showWidget = QuillEditor(
      showCursor: false,
      controller: quillController,
      onImagePaste: onImagePaste,
      scrollController: ScrollController(),
      scrollable: false,
      padding: EdgeInsets.zero,
      onLaunchUrl: _onLaunchUrl,
      focusNode: FocusNode(),
      autoFocus: false,
      expands: false,
      readOnly: true, // true for view only mode
      // padding:
      //     const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 0),

      embedBuilders: GetPlatform.isWeb
          ? defaultEmbedBuildersWeb
          : [...FlutterQuillEmbeds.builders()],
      customStyles: DefaultStyles(
        link: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
        paragraph: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 8,
              color: onBackground,
              height: 1.3,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(0, 0),
            const Tuple2(0, 0),
            null),
        h1: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 12,
              color: onBackground,
              height: 1.2,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(0, 0),
            const Tuple2(0, 0),
            null),
        h2: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 11,
              color: onBackground,
              height: 1.2,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(0, 0),
            const Tuple2(0, 0),
            null),
        h3: DefaultTextBlockStyle(
            TextStyle(
              fontSize: 10,
              color: onBackground,
              height: 1.2,
              fontWeight: FontWeight.w400,
            ),
            const Tuple2(0, 0),
            const Tuple2(0, 0),
            null),
      ),
      locale: const Locale('zh', 'cn'),
    );
    return showWidget;
  }
}
