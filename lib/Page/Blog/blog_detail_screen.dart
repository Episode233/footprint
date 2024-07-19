import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/comment.dart';
import 'package:vcommunity_flutter/components/responsive.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:vcommunity_flutter/util/user_state_util.dart';

import '../../Model/DataModel/update_file_response.dart';
import '../../Model/blog.dart';
import '../../components/image_card.dart';
import '../../components/notice_snackbar.dart';
import '../../components/sliver_header_delegate.dart';
import '../../util/http_util.dart';
import '../../util/image_util.dart';
import '../../util/string_util.dart';
import 'BlogList/components/comment_list_item.dart';
import 'components/blog_detail.dart';

class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({super.key});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final HttpUtil _httpUtil = Get.find();
  final UserStateUtil _userStateUtil = Get.find();
  final TextEditingController _keywordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _imagesController = MultiImagePickerController(
      maxImages: 9,
      allowedImageTypes: ['png', 'jpg', 'jpeg', 'gif'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );
  final TextEditingController _emojiController = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  Blog? _blog;
  int offset = 0;
  String dateInfo = '';
  String distInfo = '';
  String _blogId = "0";
  CommentData? _commentData;
  bool _isClickReturn = false;
  bool _isLoadingBlog = false;
  bool _isLoadingComment = false;
  bool _showImagePicker = false;
  bool _isEmojiSelected = false;
  bool _isSending = false;
  bool _notMore = false;
  bool _isLiking = false;
  String? _errText;
  Category _initCategory = Category.RECENT;
  CommentDetail? sendComment;

  @override
  void initState() {
    super.initState();
    String id = Get.parameters['blogId'] ?? '';
    if (id == '') {
      Get.back();
    }
    _blogId = id;
    _scrollController.addListener(() {
      _scrollListener();
    });
    _init();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // 滚动到底部
      if (_notMore) {
        return;
      }
      if (!_isLoadingComment) {
        setState(() {
          _isLoadingComment = true;
        });
        // 触发加载事件
        _getComments();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoadingBlog) {
      Blog blog = _blog!;
      bool isMale = blog.user?.gender ?? false;
      dateInfo = calculateTimeDifference(blog.createTime);
      distInfo = calculateLocationDifference(blog.distanceValue);
      List<Widget> posList = [];
      if (distInfo != '') {
        posList = [
          Icon(
            Icons.location_on_rounded,
            color: Theme.of(context).colorScheme.outline,
            size: Theme.of(context).textTheme.labelSmall!.fontSize,
          ),
          Text(
            distInfo,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              color: Theme.of(context).colorScheme.outline,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: defaultPadding / 2,
          ),
        ];
      }
      Widget handWritingBar = Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(largeBorderRadius)),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withAlpha(50),
                  offset: const Offset(0.4, -0.6),
                  blurRadius: 4,
                  spreadRadius: 0)
            ]),
        padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding / 2),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius:
                    const BorderRadius.all(Radius.circular(largeBorderRadius)),
                onTap: () {
                  sendComment = null;
                  showComment();
                },
                child: Container(
                  padding: const EdgeInsets.all(defaultPadding / 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withAlpha(150),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(largeBorderRadius)),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(Icons.drive_file_rename_outline_rounded,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        Text(
                          '写回复...',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: defaultPadding / 2,
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withAlpha(100),
                  textStyle: const TextStyle(fontSize: 15)),
              onPressed: null,
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                color: Theme.of(context).colorScheme.outline,
                size: 18,
              ),
              label: Text(blog.comments.toString(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline)),
            ),
            const SizedBox(
              width: defaultPadding / 2,
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                  backgroundColor: blog.isLike
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withAlpha(100),
                  textStyle: const TextStyle(fontSize: 15)),
              onPressed: _handlerThumbUp,
              icon: Icon(
                blog.isLike
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_up_alt_outlined,
                color: Theme.of(context).colorScheme.outline,
                size: 18,
              ),
              label: Text(blog.liked.toString(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline)),
            ),
          ],
        ),
      );
      Widget tipsWidget = const SizedBox();
      if (_isLoadingComment) {
        tipsWidget = const Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (_notMore) {
        tipsWidget = Center(
            child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "没有更多了",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ));
      }

      List<Widget> commentArea = [];
      if (_commentData != null) {
        commentArea = [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return CommentListItem(
                  _commentData!.commentItems[index], _tapComment);
            }, childCount: _commentData!.commentItems.length),
          ),
        ];
      }
      PreferredSizeWidget appBar = AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded)),
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(blog.user?.icon ?? defaultAvatar),
            ),
            const SizedBox(
              width: defaultPadding / 2,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        blog.user?.nickName ?? '已删除用户',
                        style: TextStyle(
                          height: 2,
                          fontSize:
                              Theme.of(context).textTheme.labelLarge!.fontSize,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isMale ? Icons.female_rounded : Icons.male_rounded,
                        color: isMale ? Colors.pinkAccent : Colors.blue,
                        size: 14,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ...posList,
                      Text(
                        dateInfo,
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelSmall!.fontSize,
                          color: Theme.of(context).colorScheme.outline,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        width: defaultPadding / 2,
                      ),
                      Icon(
                        Icons.credit_card_rounded,
                        color: Theme.of(context).colorScheme.outline,
                        size: Theme.of(context).textTheme.labelSmall!.fontSize,
                      ),
                      Text(
                        blog.user?.introduce ?? '已删除用户',
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelSmall!.fontSize,
                          color: Theme.of(context).colorScheme.outline,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            IconButton(
                onPressed: _popUpModelSheet,
                icon: const Icon(Icons.more_vert_rounded)),
          ],
        ),
      );
      Widget header = SliverPersistentHeader(
        pinned: true,
        delegate: SliverHeaderDelegate.fixedHeight(
          height: 50,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.onInverseSurface,
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding / 2),
                width: double.infinity,
                child: Center(
                  child: Text(
                    '共${blog.comments}回复',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      Widget mobile = Hero(
        tag: '/blog/${blog.id}',
        child: Scaffold(
          appBar: appBar,
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _init(type: 1);
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: BlogDetailWidget(_blog!),
                      ),
                      header,
                      ...commentArea,
                      SliverToBoxAdapter(child: tipsWidget)
                    ],
                  ),
                ),
              ),
              handWritingBar
            ],
          ),
        ),
      );
      Widget desktop = Hero(
        tag: '/blog/${blog.id}',
        child: Scaffold(
            body: SizedBox(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(defaultBorderRadius)),
                  child: ListView(children: [BlogDetailWidget(_blog!)]),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _init(type: 1);
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                                child: Column(
                              children: [
                                appBar,
                              ],
                            )),
                            header,
                            ...commentArea,
                            SliverToBoxAdapter(child: tipsWidget)
                          ],
                        ),
                      ),
                    ),
                    handWritingBar
                  ],
                ),
              ),
            ],
          ),
        )),
      );
      return Responsive(mobile: mobile, desktop: desktop);
    }
    return Hero(
        tag: '/blog/$_blogId',
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ));
  }

  void _init({int type = 0}) async {
    timestamp = DateTime.now().millisecondsSinceEpoch;
    offset = 0;
    _notMore = false;
    if (type == 0) {
      _initBlog();
    }

    setState(() {
      _commentData = null;
      _isLoadingComment = true;
    });
    _getComments();
  }

  void _initBlog() async {
    if (_isLoadingBlog) {
      return;
    }
    setState(() {
      _isLoadingBlog = true;
    });
    Response response = await _httpUtil.get('$apiGetBlogDetail$_blogId');
    if (response.body != null) {
      try {
        Blog blog =
            ApiResponse.fromJson(response.body, (json) => Blog.fromJson(json))
                .data;
        setState(() {
          _blog = blog;
          _isLoadingBlog = false;
        });
      } catch (err) {
        // Get.snackbar('错误', err.toString());
        Get.back();
      }
    } else {
      Get.snackbar('提示', '获取动态失败');
    }
  }

  void popCommentArea() {
    Widget emojiWidget = SizedBox(
      height: defaultEmojiHeight,
      child: EmojiPicker(
        textEditingController: _emojiController,
        onEmojiSelected: (Category? category, Emoji emoji) {
          String text = _keywordController.text;
          TextSelection textSelection = _keywordController.selection;
          final emojiStr = emoji.emoji;
          text = text.replaceRange(
              textSelection.start, textSelection.end, emojiStr);
          _initCategory = category ?? Category.RECENT;
          setState(() {
            _keywordController.text = text;
            _keywordController.selection = textSelection.copyWith(
              baseOffset: textSelection.start + emojiStr.length,
              extentOffset: textSelection.start + emojiStr.length,
            );
            _isEmojiSelected = false;
          });
        },
        config: Config(
          columns: 7,
          // Issue: https://github.com/flutter/flutter/issues/28894
          emojiSizeMax: 32 *
              (foundation.defaultTargetPlatform == TargetPlatform.iOS
                  ? 1.30
                  : 1.0),
          verticalSpacing: 0,
          horizontalSpacing: 0,
          gridPadding: const EdgeInsets.all(defaultPadding / 2),
          initCategory: _initCategory,
          bgColor: Theme.of(context).colorScheme.background,
          indicatorColor: Theme.of(context).colorScheme.primary,
          iconColor: Theme.of(context).colorScheme.secondary,
          iconColorSelected: Theme.of(context).colorScheme.primary,
          backspaceColor: Theme.of(context).colorScheme.primary,
          skinToneDialogBgColor: Theme.of(context).colorScheme.primary,
          skinToneIndicatorColor: Theme.of(context).colorScheme.background,
          enableSkinTones: true,
          showRecentsTab: true,
          recentsLimit: 28,
          replaceEmojiOnLimitExceed: false,
          noRecents: Text(
            '没有更多了',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onBackground),
            textAlign: TextAlign.center,
          ),
          loadingIndicator: const SizedBox.shrink(),
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
          checkPlatformCompatibility: true,
        ),
      ),
    );
    Widget imagePick = MultiImagePickerView(
      controller: _imagesController,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          childAspectRatio: 1,
          crossAxisSpacing: defaultPadding / 2,
          mainAxisSpacing: defaultPadding / 2),
      addMoreBuilder: (context, pickerCallback) {
        return SizedBox(
          child: Row(
            children: [
              SizedBox(
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
            ],
          ),
        );
      },
      initialContainerBuilder: (context, pickerCallback) {
        return Row(children: [
          SizedBox(
            height: 80,
            width: 80,
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
    );
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      // useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AnimatedPadding(
              padding:
                  MediaQuery.of(context).viewInsets, // 我们可以根据这个获取需要的padding
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: 250 +
                    (_showImagePicker ? 80 : 0) +
                    (_isEmojiSelected ? defaultEmojiHeight : 0),
                padding: const EdgeInsets.fromLTRB(
                    defaultPadding, 0, defaultPadding, defaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(largeBorderRadius)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('关闭')),
                        TextButton(
                            onPressed:
                                _isSending ? null : () => _submitComment(),
                            child: const Text('发送')),
                      ],
                    ),
                    Expanded(
                      child: TextField(
                        controller: _keywordController,
                        textInputAction: TextInputAction.done,
                        focusNode: _focusNode,
                        maxLines: 7,
                        minLines: 4,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        decoration: InputDecoration(
                          labelText:
                              "回复${sendComment?.answerUser?.nickName ?? _blog?.user?.nickName ?? '未知用户'}",
                          hintText: "输入你想回复的内容",
                          errorText: _errText,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: defaultPadding / 3,
                              horizontal: defaultPadding),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(150),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                                Radius.circular(defaultBorderRadius)),
                          ),
                        ),
                        onSubmitted: (value) => _submitComment(),
                      ),
                    ),
                    _showImagePicker ? imagePick : const SizedBox(),
                    Row(
                      children: [
                        IconButton(
                          isSelected: _isEmojiSelected,
                          onPressed: () {
                            setState(() {
                              _focusNode.unfocus();
                              _isEmojiSelected = !_isEmojiSelected;
                            });
                          },
                          icon: const Icon(Icons.tag_faces_rounded),
                        ),
                        IconButton(
                          isSelected: _showImagePicker,
                          onPressed: () {
                            if (!_showImagePicker) {
                              setState(() {
                                _showImagePicker = true;
                              });
                              _imagesController.pickImages();
                            } else {
                              setState(() {
                                _showImagePicker = false;
                              });
                            }
                          },
                          icon: const Icon(Icons.image_rounded),
                        ),
                        const Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () {
                            if (_focusNode.hasFocus) {
                              setState(() {
                                _focusNode.unfocus();
                              });
                            } else {
                              setState(() {
                                _isEmojiSelected = false;
                                _focusNode.requestFocus();
                              });
                            }
                          },
                          icon: _focusNode.hasFocus
                              ? const Icon(Icons.keyboard_hide_rounded)
                              : const Icon(Icons.keyboard_alt_rounded),
                        ),
                      ],
                    ),
                    _isEmojiSelected ? emojiWidget : const SizedBox(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _getComments() async {
    var apitimestamp = _commentData?.minTime ?? timestamp;
    var apioffset = _commentData?.offset ?? 0;
    Response response = await _httpUtil.get(
        '$apiGetFirstComments?blogId=$_blogId&lastId=$apitimestamp&offset=$apioffset');
    if (response.body != null) {
      CommentData commentData = ApiResponse.fromJson(
          response.body, (json) => CommentData.fromJson(json)).data;

      setState(() {
        if (_commentData == null) {
          _commentData = commentData;
        } else {
          _commentData!.commentItems.addAll(commentData.commentItems);
          _commentData!.offset = commentData.offset;
          _commentData!.minTime = commentData.minTime;
        }

        _isLoadingComment = false;
        if (commentData.commentItems.length < firstCommentsPageSize) {
          _notMore = true;
        }
      });
    } else {
      Get.snackbar('提示', '获取评论失败');
    }
  }

  void showComment() {
    popCommentArea();
  }

  void _handlerThumbUp() async {
    setState(() {
      _isLiking = true;
    });
    if (_blog!.isLike) {
      await _httpUtil.delete('$apiFollowBlog?id=${_blog!.id}');
    } else {
      await _httpUtil.post('$apiFollowBlog?id=${_blog!.id}', {});
    }
    setState(() {
      _blog!.isLike = !_blog!.isLike;
      _blog!.isLike ? _blog!.liked++ : _blog!.liked--;
      _isLiking = false;
    });
  }

  _submitComment() async {
    if (_isSending) {
      return;
    }
    setState(() {
      _isSending = true;
    });

    setState(() {
      if (_keywordController.text.removeAllWhitespace.isEmpty) {
        _errText = '多写点吧';
        _isSending = false;
      } else {
        _errText = null;
      }
    });
    if (_errText != null) {
      return;
    }
    String content = _keywordController.text;
    final images = _imagesController.images;
    String imgUrls = '';
    if (images.isNotEmpty) {
      List<String> picUrls = await _getPicUrl(images);
      String pics = picUrls.join(',');
      imgUrls = pics;
    }

    if (sendComment == null) {
      // 一级评论
      sendComment = CommentDetail(
          userId: _userStateUtil.user().id,
          blogId: _blog!.id,
          answerId: _blog!.userId,
          content: content,
          createTime: DateTime.now(),
          updateTime: DateTime.now(),
          user: _userStateUtil.user(),
          image: imgUrls);
    } else {
      // 二级评论
      sendComment!.content = content;
      sendComment!.image = imgUrls;
    }
    Response response =
        await _httpUtil.post(apiOperateComments, sendComment!.toJson());
    sendComment!.id = response.body['data'].toString();
    CommentData commentData = _commentData!;
    bool isFind1 = false;
    if (sendComment!.parentId == "0") {
      commentData.commentItems
          .insert(0, CommentItem(firstComment: sendComment!));
    } else {
      for (int index = 0; index < commentData.commentItems.length; index++) {
        if (isFind1) {
          break;
        }
        CommentItem i = commentData.commentItems[index];
        if (sendComment!.parentId == i.firstComment.id) {
          isFind1 = true;
          if (i.secondCommentData != null) {
            for (int index2 = 0;
                index2 < i.secondCommentData!.secondComments.length;
                index2++) {
              CommentDetail j = i.secondCommentData!.secondComments[index2];
              if (sendComment?.answerId.toString() == j.id) {
                i.secondCommentData!.secondComments
                    .insert(index2, sendComment!);
                break;
              }
            }
          } else {
            i.secondCommentData = SecondCommentData(
                minTime: DateTime.now().millisecondsSinceEpoch,
                offset: 0,
                secondComments: [sendComment!]);
          }
        }
      }
    }

    setState(() {
      _commentData = commentData;
      _keywordController.clear();
      _isSending = false;
      Get.back();
    });
  }

  _tapComment(CommentDetail commentDetail) {
    setState(() {
      sendComment = CommentDetail(
          userId: _userStateUtil.user().id,
          user: _userStateUtil.user(),
          blogId: _blog!.id,
          parentId: commentDetail.parentId == "0"
              ? commentDetail.id
              : commentDetail.parentId,
          answerId: commentDetail.user?.id ?? _blog!.userId,
          answerUser: commentDetail.user,
          content: '',
          createTime: DateTime.now(),
          updateTime: DateTime.now(),
          image: '');
    });

    showComment();
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
        _isSending = false;
      });
      return [];
    }
    if (response.body['success']) {
      NoticeSnackBar.showSnackBar('图片上传成功', type: NoticeType.SUCCESS);
    } else {
      // ignore: use_build_context_synchronously
      NoticeSnackBar.showSnackBar('提交失败，图片上传失败', type: NoticeType.ERROR);

      setState(() {
        _isSending = false;
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

  void _popUpModelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(defaultPadding),
          height: 130, //对话框高度就是此高度
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                  child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.primary),
              )),
              const SizedBox(
                height: defaultPadding,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _handlerDelete,
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer),
                      label: const Text("举报动态"),
                      icon: const Icon(Icons.alarm_off_rounded),
                    ),
                  ),
                  ...addOwnDelete()
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> addOwnDelete() {
    if (_blog!.userId == _userStateUtil.user().id) {
      return [
        const SizedBox(
          width: defaultPadding,
        ),
        Expanded(
          child: TextButton.icon(
            style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer),
            onPressed: _handlerDelete,
            label: const Text("删除动态"),
            icon: const Icon(Icons.delete_rounded),
          ),
        )
      ];
    } else {
      return const [SizedBox()];
    }
  }

  void _handlerDelete() {
    _httpUtil.delete('$apiAddBlog/${_blog!.id}');
  }
}
