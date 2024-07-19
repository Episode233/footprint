// ignore: file_names
import 'dart:async';
import 'dart:convert';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart' hide Node;
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'dart:io';
import 'package:vcommunity_flutter/Model/blog.dart';
import 'package:vcommunity_flutter/Model/building.dart';
import 'package:vcommunity_flutter/Model/topicList.dart';
import 'package:vcommunity_flutter/components/image_card.dart';
import 'package:vcommunity_flutter/components/notice_snackbar.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/universal_ui/universal_ui.dart';
import 'package:vcommunity_flutter/util/http_util.dart';
import 'package:vcommunity_flutter/util/image_util.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';
import 'package:tuple/tuple.dart';
import 'package:file_picker/file_picker.dart';
import '../../../Model/DataModel/update_file_response.dart';
import '../../../Model/api_response.dart';
import '../../../Model/topic.dart';
import '../../../components/quill_config.dart';

enum _SelectionType {
  none,
  word,
  line,
}

class BlogEditScreen extends StatefulWidget {
  const BlogEditScreen({super.key});

  @override
  State<BlogEditScreen> createState() => _BlogEditScreenState();
}

class _BlogEditScreenState extends State<BlogEditScreen> {
  final HttpUtil _httpUtil = Get.find();
  final UserStateUtil _userStateUtil = Get.find();
  final QuillConfig quillConfig = QuillConfig();
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  final _imagesController = MultiImagePickerController(
      maxImages: 9,
      allowedImageTypes: ['png', 'jpg', 'jpeg', 'gif'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );

  bool isSending = false;
  final FocusNode _focusNode = FocusNode();
  bool _isArticle = false;
  bool _isEmojiSelected = false;
  bool _isTextStyleSelected = true;
  Category _initCategory = Category.RECENT;
  Timer? _selectAllTimer;
  _SelectionType _selectionType = _SelectionType.none;
  Blog blog = Blog("", "", "", 0, 0);
  int _lastId = 0;
  int page = 1;
  String searchkey = "";
  bool hasMore = true;
  bool isLoadingMore = false;
  var topics = [].obs;
  List<Building> buildings = [];

  String? _errorText;
  @override
  void initState() {
    _lastId = DateTime.now().millisecondsSinceEpoch;
    blog.latitude = _userStateUtil.nowPos.latitude;
    blog.longitude = _userStateUtil.nowPos.longitude;
    _titleController.text = blog.title;
    if (Get.parameters['type'] != null && Get.parameters['type'] == 'article') {
      _isArticle = true;
    }
    _getTopics("");
    _getBuildings();
    super.initState();
  }

  bool _onTripleClickSelection() {
    final controller = _controller;

    _selectAllTimer?.cancel();
    _selectAllTimer = null;

    // If you want to select all text after paragraph, uncomment this line
    if (_selectionType == _SelectionType.line) {
      final selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.document.length,
      );

      controller.updateSelection(selection, ChangeSource.REMOTE);

      _selectionType = _SelectionType.none;

      return true;
    }

    if (controller.selection.isCollapsed) {
      _selectionType = _SelectionType.none;
    }

    if (_selectionType == _SelectionType.none) {
      _selectionType = _SelectionType.word;
      _startTripleClickTimer();
      return false;
    }

    if (_selectionType == _SelectionType.word) {
      final child = controller.document.queryChild(
        controller.selection.baseOffset,
      );
      final offset = child.node?.documentOffset ?? 0;
      final length = child.node?.length ?? 0;

      final selection = TextSelection(
        baseOffset: offset,
        extentOffset: offset + length,
      );

      controller.updateSelection(selection, ChangeSource.REMOTE);

      // _selectionType = _SelectionType.line;

      _selectionType = _SelectionType.none;

      _startTripleClickTimer();

      return true;
    }

    return false;
  }

  void _startTripleClickTimer() {
    _selectAllTimer = Timer(const Duration(milliseconds: 900), () {
      _selectionType = _SelectionType.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color onBackground = Theme.of(context).colorScheme.onBackground;
    Widget editor = QuillEditor(
      onImagePaste: quillConfig.onImagePaste,
      controller: _controller,
      scrollController: ScrollController(),
      onLaunchUrl: (value) {
        Get.toNamed(value);
      },
      scrollable: true,
      focusNode: _focusNode,
      autoFocus: false,
      readOnly: false, // true for view only mode
      expands: true,
      placeholder: _isArticle ? "图文正文" : "动态正文",
      padding:
          const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 0),
      onTapUp: (details, p1) {
        return _onTripleClickSelection();
      },
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
    Widget toolBarExceptRollback = QuillToolbar.basic(
      locale: const Locale('zh', 'cn'),
      controller: _controller,
      toolbarIconAlignment: WrapAlignment.start,
      toolbarIconSize: 20,
      iconTheme: QuillIconTheme(
          borderRadius: defaultBorderRadius,
          iconSelectedFillColor: Theme.of(context).colorScheme.primary,
          iconUnselectedFillColor:
              Theme.of(context).colorScheme.primaryContainer),
      showAlignmentButtons: true,
      showFontFamily: false,
      showFontSize: false,
      showBackgroundColorButton: false,
      showColorButton: false,
      showDirection: false,
      showCenterAlignment: false,
      showJustifyAlignment: false,
      showLeftAlignment: false,
      showRightAlignment: false,
      showLink: false,
      showSearchButton: false,
      showItalicButton: false,
      showListBullets: false,
      showUnderLineButton: false,
      showDividers: false,
      showIndent: false,
      // showInlineCode: false,
      showInlineCode: false,
      showListNumbers: false,
      showListCheck: false,
      showRedo: false,
      showUndo: false,
      afterButtonPressed: _focusNode.requestFocus,
    );
    Widget toolBarOnlyRollback = QuillToolbar.basic(
      locale: const Locale('zh', 'cn'),
      controller: _controller,
      toolbarIconAlignment: WrapAlignment.start,
      toolbarIconSize: 20,
      iconTheme: QuillIconTheme(
          borderRadius: defaultBorderRadius,
          iconSelectedFillColor: Theme.of(context).colorScheme.primary,
          iconUnselectedFillColor:
              Theme.of(context).colorScheme.primaryContainer),
      showAlignmentButtons: true,
      showFontFamily: false,
      showFontSize: false,
      showBackgroundColorButton: false,
      showColorButton: false,
      showDirection: false,
      showCenterAlignment: false,
      showJustifyAlignment: false,
      showLeftAlignment: false,
      showRightAlignment: false,
      showLink: false,
      showSearchButton: false,
      showItalicButton: false,
      showListBullets: false,
      showUnderLineButton: false,
      showDividers: false,
      showIndent: false,
      showInlineCode: false,
      showListNumbers: false,
      showListCheck: false,
      showBoldButton: false,
      showClearFormat: false,
      showCodeBlock: false,
      showHeaderStyle: false,
      showQuote: false,
      showSmallButton: false,
      showStrikeThrough: false,
      afterButtonPressed: _focusNode.requestFocus,
    );
    Widget bottomAppBar = QuillToolbar.basic(
      locale: const Locale('zh', 'cn'),
      controller: _controller,
      toolbarSectionSpacing: 0,
      embedButtons: FlutterQuillEmbeds.buttons(
        onImagePickCallback: quillConfig.onImagePickCallback,
        showVideoButton: false,
        showCameraButton: false,
        webImagePickImpl: quillConfig.webImagePickImpl,
        filePickImpl: quillConfig.openFileSystemPickerForDesktop,
      ),
      toolbarIconSize: 23,
      iconTheme: QuillIconTheme(
          borderRadius: largeBorderRadius,
          iconUnselectedColor: Theme.of(context).colorScheme.onSurfaceVariant,
          iconUnselectedFillColor: const Color.fromARGB(0, 0, 0, 0)),
      showAlignmentButtons: true,
      showFontFamily: false,
      showFontSize: false,
      showBackgroundColorButton: false,
      showColorButton: false,
      showDirection: false,
      showCenterAlignment: false,
      showJustifyAlignment: false,
      showLeftAlignment: false,
      showRightAlignment: false,
      showSearchButton: false,
      showItalicButton: false,
      showListBullets: false,
      showUnderLineButton: false,
      showDividers: false,
      showLink: false,
      showIndent: false,
      showInlineCode: false,
      showListNumbers: false,
      showListCheck: false,
      showBoldButton: false,
      showClearFormat: false,
      showCodeBlock: false,
      showHeaderStyle: false,
      showQuote: false,
      showSmallButton: false,
      showStrikeThrough: false,
      showRedo: false,
      showUndo: false,
      afterButtonPressed: _focusNode.requestFocus,
    );
    Widget saveButton = FilledButton.icon(
      onPressed: isSending ? null : _sendBlog,
      style: FilledButton.styleFrom(
        elevation: 0,
      ),
      icon: const Text("发布"),
      label: const Icon(Icons.send_rounded),
    );
    Widget titleInput = TextField(
      autofocus: true,
      controller: _titleController,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: "标题",
        hintText: "最多20字",
        errorText: _errorText,
        prefixIcon: const Icon(Icons.title_rounded),
      ),
      onEditingComplete: () => blog.title = _titleController.text,
    );
    bool isKeyboardShow = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
      appBar: AppBar(
        title: _isArticle ? const Text("发布图文") : const Text("发布动态"),
        actions: [
          saveButton,
          const SizedBox(
            width: defaultPadding,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                isSelected: _isTextStyleSelected,
                onPressed: () {
                  setState(() {
                    _isTextStyleSelected = !_isTextStyleSelected;
                  });
                },
                icon: const Icon(Icons.text_fields_rounded)),
            IconButton(
                isSelected: _isEmojiSelected,
                onPressed: () {
                  setState(() {
                    _isEmojiSelected = !_isEmojiSelected;
                  });
                },
                icon: const Icon(Icons.tag_faces_rounded)),
            _isArticle
                ? bottomAppBar
                : IconButton(
                    onPressed: () {
                      _imagesController.pickImages();
                    },
                    icon: const Icon(Icons.image_rounded),
                  ),
            IconButton(
              onPressed: () => addRefer('topic'),
              icon: const Icon(Icons.explore_rounded),
            ),
            IconButton(
                onPressed: () => addRefer('building'),
                icon: const Icon(Icons.corporate_fare_rounded)),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.add_circle_outline)),
          ],
        ),
      ),
      body: Column(
        children: GetPlatform.isDesktop
            ? [
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Row(
                    children: [
                      SizedBox(
                        child: toolBarOnlyRollback,
                      ),
                      Expanded(
                        child: SizedBox(
                            height: 40,
                            child: ListView(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 8),
                                scrollDirection: Axis.horizontal,
                                children: [toolBarExceptRollback])),
                      )
                    ],
                  ),
                ),
                Offstage(
                  offstage: !_isEmojiSelected,
                  child: SizedBox(
                      height: 250,
                      child: EmojiPicker(
                        textEditingController: _emojiController,
                        onEmojiSelected: (Category? category, Emoji emoji) {
                          final index = _controller.selection.baseOffset;
                          final emojiStr = emoji.emoji;
                          _initCategory = category ?? Category.RECENT;
                          setState(() {
                            _controller.document.insert(index, emojiStr);
                            _isEmojiSelected = false;
                          });
                        },
                        config: Config(
                          columns: 7,
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          emojiSizeMax: 32 *
                              (foundation.defaultTargetPlatform ==
                                      TargetPlatform.iOS
                                  ? 1.30
                                  : 1.0),
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          gridPadding: const EdgeInsets.all(defaultPadding / 2),
                          initCategory: _initCategory,
                          bgColor: Theme.of(context).colorScheme.background,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          iconColor: Theme.of(context).colorScheme.secondary,
                          iconColorSelected:
                              Theme.of(context).colorScheme.primary,
                          backspaceColor: Theme.of(context).colorScheme.primary,
                          skinToneDialogBgColor:
                              Theme.of(context).colorScheme.primary,
                          skinToneIndicatorColor:
                              Theme.of(context).colorScheme.background,
                          enableSkinTones: true,
                          showRecentsTab: true,
                          recentsLimit: 28,
                          replaceEmojiOnLimitExceed: false,
                          noRecents: Text(
                            '没有更多了',
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            textAlign: TextAlign.center,
                          ),
                          loadingIndicator: const SizedBox.shrink(),
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL,
                          checkPlatformCompatibility: true,
                        ),
                      )),
                ),
                _isArticle
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(
                            defaultPadding, 0, defaultPadding, 0),
                        child: titleInput,
                      ),
                Expanded(flex: 15, child: editor),
                !_isArticle
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: MultiImagePickerView(
                          controller: _imagesController,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 110,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: defaultPadding / 2,
                                  mainAxisSpacing: defaultPadding / 2),
                          initialContainerBuilder: (context, pickerCallback) {
                            return Row(children: [
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              defaultBorderRadius))),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                        ),
                      )
                    : const SizedBox(),
              ]
            : [
                _isArticle
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(
                            defaultPadding, 0, defaultPadding, 0),
                        child: titleInput,
                      ),
                Expanded(flex: 15, child: editor),
                isKeyboardShow && !_isArticle
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: MultiImagePickerView(
                          controller: _imagesController,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 110,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: defaultPadding / 2,
                                  mainAxisSpacing: defaultPadding / 2),
                          initialContainerBuilder: (context, pickerCallback) {
                            return Row(children: [
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              defaultBorderRadius))),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      )
                    : const SizedBox(),
                Offstage(
                  offstage: !_isTextStyleSelected,
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Row(
                      children: [
                        SizedBox(
                          child: toolBarOnlyRollback,
                        ),
                        Expanded(
                          child: SizedBox(
                              height: 40,
                              child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 8),
                                  scrollDirection: Axis.horizontal,
                                  children: [toolBarExceptRollback])),
                        )
                      ],
                    ),
                  ),
                ),
                Offstage(
                  offstage: !_isEmojiSelected,
                  child: SizedBox(
                      height: 250,
                      child: EmojiPicker(
                        textEditingController: _emojiController,
                        onEmojiSelected: (Category? category, Emoji emoji) {
                          final index = _controller.selection.baseOffset;
                          final emojiStr = emoji.emoji;
                          _initCategory = category ?? Category.RECENT;
                          setState(() {
                            _controller.document.insert(index, emojiStr);
                            _isEmojiSelected = false;
                          });
                        },
                        config: Config(
                          columns: 7,
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          emojiSizeMax: 32 *
                              (foundation.defaultTargetPlatform ==
                                      TargetPlatform.iOS
                                  ? 1.30
                                  : 1.0),
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          gridPadding: const EdgeInsets.all(defaultPadding / 2),
                          initCategory: _initCategory,
                          bgColor: Theme.of(context).colorScheme.background,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          iconColor: Theme.of(context).colorScheme.secondary,
                          iconColorSelected:
                              Theme.of(context).colorScheme.primary,
                          backspaceColor: Theme.of(context).colorScheme.primary,
                          skinToneDialogBgColor:
                              Theme.of(context).colorScheme.primary,
                          skinToneIndicatorColor:
                              Theme.of(context).colorScheme.background,
                          enableSkinTones: true,
                          showRecentsTab: true,
                          recentsLimit: 28,
                          replaceEmojiOnLimitExceed: false,
                          noRecents: Text(
                            '没有更多了',
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            textAlign: TextAlign.center,
                          ),
                          loadingIndicator: const SizedBox.shrink(),
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL,
                          checkPlatformCompatibility: true,
                        ),
                      )),
                ),
              ],
      ),
    );
  }

  void addRefer(String type) async {
    bool isForTopic = type == "topic";
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
              defaultPadding, defaultPadding, defaultPadding, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: Row(
                  children: [
                    Text(
                      isForTopic ? "添加话题" : "添加建筑(附近400m)",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                        onPressed: () => isForTopic
                            ? _getTopics(searchkey)
                            : _getBuildings(),
                        icon: const Icon(Icons.refresh_rounded))
                  ],
                ),
              ),
              isForTopic
                  ? TextField(
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      decoration: InputDecoration(
                        labelText: "话题名称",
                        hintText: "输入你想添加的话题名称",
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                              Radius.circular(largeBorderRadius)),
                        ),
                      ),
                      onChanged: (value) async {
                        searchkey = value;
                        _getTopics(searchkey);
                      })
                  : const SizedBox(),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      loadMore();
                    }
                    return true;
                  },
                  child: isForTopic
                      ? Obx(
                          () => ListView.builder(
                            itemCount: topics.length,
                            itemBuilder: (context, index) {
                              Topic topic = topics[index];
                              if (topic.name == "flag_to_not_more") {
                                return Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(defaultPadding),
                                  child: Text("没有更多内容了",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium),
                                );
                              }
                              if (topic.name == "flag_to_add_topic") {
                                return ListTile(
                                  onTap: () => Get.toNamed("/topic/add"),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: defaultPadding / 2),
                                  title: const Text("没有该话题"),
                                  subtitle: Text("点击前往添加话题",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium),
                                  trailing: const Icon(
                                      Icons.arrow_forward_ios_rounded),
                                );
                              }
                              return Container(
                                margin:
                                    const EdgeInsets.only(top: defaultPadding),
                                decoration: BoxDecoration(
                                    // color: Theme.of(context)
                                    //     .colorScheme
                                    //     .primaryContainer,
                                    borderRadius: BorderRadius.circular(
                                        largeBorderRadius)),
                                child: ListTile(
                                  onTap: () => _addTopicInEditor(topic),
                                  title: Text(topic.name),
                                  subtitle: Text(
                                    "${topic.follows}人关注",
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  leading: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(
                                                  defaultBorderRadius)),
                                          image: DecorationImage(
                                              image: NetworkImage(topic.icon),
                                              fit: BoxFit.cover)),
                                    ),
                                  ),
                                  trailing: const Icon(
                                      Icons.arrow_forward_ios_rounded),
                                ),
                              );
                            },
                          ),
                        )
                      : ListView.builder(
                          itemCount: buildings.length + 2,
                          itemBuilder: (context, index) {
                            if (buildings.length + 1 == index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(defaultPadding),
                                child: Text("没有更多内容了",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium),
                              );
                            }
                            if (buildings.length == index) {
                              return ListTile(
                                onTap: () => Get.toNamed("/building/add"),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: defaultPadding / 2),
                                title: const Text("没有找到建筑?"),
                                subtitle: Text("点击前往添加建筑",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium),
                                trailing:
                                    const Icon(Icons.arrow_forward_ios_rounded),
                              );
                            }
                            Building building = buildings[index];
                            return Container(
                              margin:
                                  const EdgeInsets.only(top: defaultPadding),
                              decoration: BoxDecoration(
                                  // color: Theme.of(context)
                                  //     .colorScheme
                                  //     .primaryContainer,
                                  borderRadius:
                                      BorderRadius.circular(largeBorderRadius)),
                              child: ListTile(
                                onTap: () => _addBuildingInEditor(building),
                                title: Text(building.name),
                                subtitle: Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    margin: const EdgeInsets.only(right: 3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    child: Text(
                                      "距离:${building.distanceValue}m",
                                      style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .fontSize,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer),
                                    ),
                                  ),
                                  Text(
                                    "${building.follows}人关注",
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                ]),
                                leading: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(
                                                defaultBorderRadius)),
                                        image: DecorationImage(
                                            image: NetworkImage(building.icon),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                                trailing:
                                    const Icon(Icons.arrow_forward_ios_rounded),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _getTopics(searchKey) async {
    hasMore = true;
    page = 1;
    var topicResp = await _httpUtil.get(
        "$apiSearchTopic?key=$searchKey&lastId=$_lastId&sortType=1&size=$pageSize");
    List<Topic> topicList =
        ApiResponse.fromJson(topicResp.body, (json) => TopicList.fromJson(json))
            .data
            .topics;
    page++;

    if (topicList.length < pageSize && topicList.isNotEmpty) {
      hasMore = false;
      topicList.add(Topic(icon: "", name: "flag_to_not_more"));
    }
    if (topicList.isEmpty) {
      topicList.add(Topic(icon: "", name: "flag_to_add_topic"));
    }
    topics = topicList.obs;
  }

  String? _getLinkAttributeValue() {
    return _controller
        .getSelectionStyle()
        .attributes[Attribute.link.key]
        ?.value;
  }

  TextRange getLinkRange(Node node) {
    var start = node.documentOffset;
    var length = node.length;
    var prev = node.previous;
    final linkAttr = node.style.attributes[Attribute.link.key]!;
    while (prev != null) {
      if (prev.style.attributes[Attribute.link.key] == linkAttr) {
        start = prev.documentOffset;
        length += prev.length;
        prev = prev.previous;
      } else {
        break;
      }
    }

    var next = node.next;
    while (next != null) {
      if (next.style.attributes[Attribute.link.key] == linkAttr) {
        length += next.length;
        next = next.next;
      } else {
        break;
      }
    }
    return TextRange(start: start, end: start + length);
  }

  void _addTopicInEditor(Topic topic) {
    if (jsonEncode(_controller.document.toDelta().toJson())
            .split(r'"attributes":{"link":"/topic/')
            .length >=
        5) {
      NoticeSnackBar.showSnackBar("最多添加4个话题", type: NoticeType.WARN);
      Get.back();
      return;
    }
    final String text = " #${topic.name}# ";
    final String link = "/topic/${topic.id}";

    var index = _controller.selection.start;
    var length = _controller.selection.end - index;
    if (_getLinkAttributeValue() != null) {
      // text should be the link's corresponding text, not selection
      final leaf = _controller.document.querySegmentLeafNode(index).item2;
      if (leaf != null) {
        final range = getLinkRange(leaf);
        index = range.start;
        length = range.end - range.start;
      }
    }
    _controller.replaceText(index, length, text, null);
    _controller.formatText(index, text.length, LinkAttribute(link));
    // 提交时再生产topicId列表
    // blog.topicId += blog.topicId == '' ? topic.id.toString() : ",${topic.id}";
    Get.back();
  }

  void loadMore() async {
    if (!hasMore) return;
    if (isLoadingMore) return;
    isLoadingMore = true;
    var topicResp = await _httpUtil.get(
        "$apiSearchTopic?key=$searchkey&lastId=$_lastId&sortType=1&page=$page&size=$pageSize");
    List<Topic> topicList =
        ApiResponse.fromJson(topicResp.body, (json) => TopicList.fromJson(json))
            .data
            .topics;
    page++;
    if (topicList.length < pageSize) {
      hasMore = false;
      topicList.add(Topic(icon: "", name: "flag_to_not_more"));
    }
    isLoadingMore = false;
    topics.addAll(topicList);
  }

  void _getBuildings() async {
    var nowPos = _userStateUtil.nowPos;
    final resp = await _httpUtil.get(
        '$apiSearchBuildingByLocation?latitude=${nowPos.latitude}&longitude=${nowPos.longitude}&range=400');
    if (resp.body == null) {
      NoticeSnackBar.showSnackBar("接口请求错误", type: NoticeType.ERROR);
      return;
    }
    BuildingList buildingList =
        ApiResponse.fromJson(resp.body, (json) => BuildingList.fromJson(json))
            .data;
    setState(() {
      buildings = buildingList.buildings;
    });
  }

  _addBuildingInEditor(Building building) {
    if (jsonEncode(_controller.document.toDelta().toJson())
            .split(r'"attributes":{"link":"/building/')
            .length >=
        2) {
      NoticeSnackBar.showSnackBar("最多添加1个建筑", type: NoticeType.WARN);
      Get.back();
      return;
    }
    final String text = " 🏢${building.name} ";
    final String link = "/building/${building.id}";

    var index = _controller.selection.start;
    var length = _controller.selection.end - index;
    if (_getLinkAttributeValue() != null) {
      // text should be the link's corresponding text, not selection
      final leaf = _controller.document.querySegmentLeafNode(index).item2;
      if (leaf != null) {
        final range = getLinkRange(leaf);
        index = range.start;
        length = range.end - range.start;
      }
    }
    _controller.replaceText(index, length, text, null);
    _controller.formatText(index, text.length, LinkAttribute(link));
    Get.back();
  }

  void _sendBlog() async {
    setState(() {
      isSending = true;
    });
    if (!_isArticle && _titleController.text.removeAllWhitespace.length < 4) {
      setState(() {
        _errorText = '多写点吧';
        isSending = false;
      });
      return;
    }
    var content = jsonEncode(_controller.document.toDelta().toJson());
    final RegExp regexTopic = RegExp(r'"link":"/topic/(\d+)"');
    final List<String> topics =
        regexTopic.allMatches(content).map((match) => match.group(1)!).toList();
    final String topicIds = topics.join(',');
    final RegExp regexBuilding = RegExp(r'"link":"/building/(\d+)"');
    final List<String> buildings = regexBuilding
        .allMatches(content)
        .map((match) => match.group(1)!)
        .toList();
    final String buildingId = buildings.length == 1 ? buildings.first : '';
    if (buildingId != '') {
      blog.buildingId = int.parse(buildingId);
    }
    blog.content = content;
    blog.latitude = _userStateUtil.nowPos.latitude;
    blog.longitude = _userStateUtil.nowPos.longitude;
    blog.title = _titleController.text;
    blog.topicId = topicIds;
    // blog.images

    final images = _imagesController.images;
    if (images.isNotEmpty) {
      List<String> picUrls = await _getPicUrl(images);
      String pics = picUrls.join(',');
      blog.images = pics;
    }

    final resp = await _httpUtil.post(apiAddBlog, blog.toJson());
    if (resp.status.hasError) {
      NoticeSnackBar.showSnackBar('提交失败，未知错误', type: NoticeType.ERROR);
      setState(() {
        isSending = false;
      });
      return;
    }
    if (resp.body['success']) {
      NoticeSnackBar.showSnackBar('发布成功', type: NoticeType.SUCCESS);
    } else {
      NoticeSnackBar.showSnackBar(resp.body['errMsg'], type: NoticeType.ERROR);

      setState(() {
        isSending = false;
      });
      return;
    }
    Get.back();
  }

  Future<List<String>> _getPicUrl(Iterable<ImageFile> images) async {
    NoticeSnackBar.showSnackBar('正在提交...请勿关闭');
    Map<String, dynamic> data = {};
    int i = 0;
    for (final image in images) {
      MultipartFile file;
      if (image.hasPath) {
        List<int> imgBytes = await compressFile(File(image.path!)) as List<int>;
        file = MultipartFile(imgBytes, filename: image.name);
      } else {
        List<int> imgBytes = await comporessList(image.bytes!);
        file = MultipartFile(imgBytes, filename: image.name);
      }
      data.addAll({"file$i": file});
      i++;
    }
    final formData = FormData(data);
    final response = await _httpUtil.post(apiSendFile, formData);
    if (response.status.hasError) {
      // ignore: use_build_context_synchronously
      NoticeSnackBar.showSnackBar('提交失败，未知错误', type: NoticeType.ERROR);
      setState(() {
        isSending = false;
      });
      return [];
    }
    if (response.body['success']) {
      NoticeSnackBar.showSnackBar('图片上传成功', type: NoticeType.SUCCESS);
    } else {
      // ignore: use_build_context_synchronously
      NoticeSnackBar.showSnackBar('提交失败，图片上传失败', type: NoticeType.ERROR);

      setState(() {
        isSending = false;
      });
      return [];
    }
    ApiResponse<UpdateFileData> resp = ApiResponse.fromJson(
        response.body, (json) => UpdateFileData.fromJson(json));
    Map<String, String> pics = resp.data.succMap;
    var keys = pics.keys;
    List<String> picUrls = [];
    for (var element in keys) {
      picUrls.add(pics[element]!);
    }
    return picUrls;
  }
}
