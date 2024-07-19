import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/blog.dart';
import 'package:vcommunity_flutter/Model/comment.dart';
import 'package:vcommunity_flutter/Model/user.dart';
import 'package:vcommunity_flutter/components/image_card_with_show.dart';
import 'package:vcommunity_flutter/components/quill_config.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

import '../../../../util/string_util.dart';

class CommentListItem extends StatefulWidget {
  CommentItem commentItem;
  Function onTapComment;
  CommentListItem(this.commentItem, this.onTapComment, {super.key});

  @override
  State<CommentListItem> createState() => _CommentListItemState();
}

class _CommentListItemState extends State<CommentListItem> {
  HttpUtil _httpUtil = Get.find();
  late CommentItem commentItem;
  String dateInfo = '';
  String distInfo = '';
  bool isLoading = false;
  bool notMore = false;
  late Function onTapComment;

  @override
  void initState() {
    super.initState();
    commentItem = widget.commentItem;
    onTapComment = widget.onTapComment;
  }

  @override
  Widget build(BuildContext context) {
    User firstCommentUser = commentItem.firstComment.user ?? User.empty();
    bool isMale = firstCommentUser.gender;
    List<Widget> imageList = [];
    int picLen = commentItem.firstComment.image.split(',').length;
    bool noPic = false;
    dateInfo = calculateTimeDifference(commentItem.firstComment.createTime);

    for (var i in commentItem.firstComment.image.split(',')) {
      if (i == '') {
        noPic = true;
        break;
      }
      imageList.add(ImageCardWithShow(
        BorderRadius.circular(3),
        150,
        url: i,
      ));
    }

    List<Widget> userTitle = [
      Row(
        children: [
          Text(
            firstCommentUser.nickName,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
              color: Theme.of(context).colorScheme.primary,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            isMale ? Icons.female_rounded : Icons.male_rounded,
            color: isMale ? Colors.pinkAccent : Colors.blue,
            size: 15,
          ),
        ],
      ),
      Row(
        children: [
          Icon(
            Icons.credit_card_rounded,
            color: Theme.of(context).colorScheme.outline,
            size: Theme.of(context).textTheme.labelSmall!.fontSize,
          ),
          Text(
            firstCommentUser.introduce,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              color: Theme.of(context).colorScheme.outline,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      )
    ];
    List<Widget> secondCommentWidget = [];
    for (CommentDetail i
        in commentItem.secondCommentData?.secondComments ?? []) {
      if (((i.user?.id) ?? -1) == -1) {
        secondCommentWidget.add(InkWell(
          onTap: () => onTapComment(i),
          child: Wrap(
            children: [
              Text(
                '${i.user!.nickName}:',
                style: TextStyle(
                    height: 1.6, color: Theme.of(context).colorScheme.primary),
              ),
              Text(
                i.content,
                softWrap: true,
                style: TextStyle(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                    decorationStyle: TextDecorationStyle.solid,
                    decorationColor: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ));
      } else {
        secondCommentWidget.add(
          InkWell(
            onTap: () => onTapComment(i),
            child: Wrap(
              children: [
                Text(
                  i.user!.nickName,
                  style: TextStyle(
                      height: 1.6,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  '回复:',
                  style: TextStyle(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${i.answerUser!.nickName}:',
                  style: TextStyle(
                      height: 1.6,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  i.content,
                  softWrap: true,
                  style: TextStyle(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      secondCommentWidget.add(const SizedBox(
        height: defaultPadding / 2,
      ));
    }
    if (isLoading) {
      secondCommentWidget.add(const Center(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: CircularProgressIndicator(),
        ),
      ));
    }
    if (((commentItem.secondCommentData?.secondComments.length ?? 0) >=
            secondCommentsPageSize) &&
        (!notMore)) {
      secondCommentWidget.add(
        InkWell(
          onTap: () {
            if (!isLoading) {
              setState(() {
                isLoading = true;
              });
              getData();
            }
          },
          child: Text(
            '展开更多',
            style: TextStyle(
                height: 1.6, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
    }
    Widget commentWidget = const SizedBox();
    if (commentItem.secondCommentData != null) {
      commentWidget = Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            color: Theme.of(context).colorScheme.surfaceVariant),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...secondCommentWidget,
          ],
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(
          defaultPadding, 0, defaultPadding, defaultPadding),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            defaultPadding / 2, defaultPadding / 2, defaultPadding / 2, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(firstCommentUser.icon),
                ),
                const SizedBox(
                  width: defaultPadding / 2,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...userTitle,
                      const SizedBox(
                        height: defaultPadding / 2,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  onTapComment(commentItem.firstComment),
                              child: Text(
                                commentItem.firstComment.content,
                                style: TextStyle(
                                    height: 1.7,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .fontSize),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: defaultPadding / 2,
                      ),
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadius)),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: defaultPadding / 6,
                          runSpacing: defaultPadding / 6,
                          children: imageList,
                        ),
                      ),
                      const SizedBox(
                        height: defaultPadding / 2,
                      ),
                      Text(
                        dateInfo,
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.labelMedium!.fontSize,
                          color: Theme.of(context).colorScheme.outline,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        height: defaultPadding,
                      ),
                      commentWidget,
                    ],
                  ),
                ),
                const SizedBox(
                  width: defaultPadding,
                ),
              ],
            ),
            const SizedBox(
              height: defaultPadding / 2,
            ),
          ],
        ),
      ),
    );
  }

  void getData() async {
    var secondCommentData = commentItem.secondCommentData;
    if (secondCommentData == null) {
      return;
    }
    var apitimestamp = secondCommentData.minTime;

    var apioffset = secondCommentData.offset;
    Response response = await _httpUtil.get(
        '$apiGetSecondComments?blogId=${secondCommentData.secondComments.first.blogId}&commentId=${commentItem.firstComment.id}&lastId=$apitimestamp&offset=$apioffset');
    if (response.body != null) {
      SecondCommentData secondCommentData = ApiResponse.fromJson(
          response.body, (json) => SecondCommentData.fromJson(json)).data;
      setState(() {
        if (secondCommentData.secondComments.length < secondCommentsPageSize) {
          notMore = true;
        }
        commentItem.secondCommentData!.minTime = secondCommentData.minTime;
        commentItem.secondCommentData!.offset = secondCommentData.offset;
        commentItem.secondCommentData!.secondComments
            .addAll(secondCommentData.secondComments);
        isLoading = false;
      });
    }
  }
}
