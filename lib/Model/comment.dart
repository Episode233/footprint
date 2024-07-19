import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:vcommunity_flutter/Model/user.dart';

class CommentData {
  int minTime;
  int offset;
  List<CommentItem> commentItems;

  CommentData(
      {required this.minTime,
      required this.offset,
      required this.commentItems});

  factory CommentData.fromJson(Map<String, dynamic> json) {
    List<CommentItem> commentItems = [];
    List data = json['data'] ?? [];
    for (var i in data) {
      CommentDetail firstComment = CommentDetail.fromJson(i['firstComments']);
      SecondCommentData secondCommentData;
      if (i['secondComments'] != null) {
        secondCommentData = SecondCommentData.fromJson(i['secondComments']);
        commentItems.add(CommentItem(
            firstComment: firstComment, secondCommentData: secondCommentData));
      } else {
        commentItems.add(CommentItem(firstComment: firstComment));
      }
    }
    return CommentData(
      minTime: json['minTime'] ?? DateTime.now().millisecondsSinceEpoch,
      offset: json['offset'] ?? 0,
      commentItems: commentItems,
    );
  }
}

class CommentItem {
  final CommentDetail firstComment;
  SecondCommentData? secondCommentData;

  CommentItem({required this.firstComment, this.secondCommentData});
}

class CommentDetail {
  String id;
  final int userId;
  final String blogId;
  final String parentId;
  final int answerId;
  User? answerUser;
  String content;
  final int liked;
  final int status;
  final DateTime createTime;
  final DateTime updateTime;
  String image;
  final bool deleted;
  final bool isLike;
  final User? user;

  CommentDetail(
      {this.id = "0",
      required this.userId,
      required this.blogId,
      this.parentId = "0",
      this.answerId = 0,
      required this.content,
      this.liked = 0,
      this.status = 0,
      required this.createTime,
      required this.updateTime,
      required this.image,
      this.deleted = false,
      this.isLike = false,
      this.answerUser,
      this.user});

  factory CommentDetail.fromJson(Map<String, dynamic> json) {
    if (json['user'] == null) {
      return CommentDetail(
        id: json['id'],
        userId: json['userId'],
        blogId: json['blogId'],
        parentId: json['parentId'],
        answerId: json['answerId'],
        content: json['content'],
        liked: json['liked'],
        status: json['status'],
        createTime: DateTime.parse(json['createTime'] ?? ""),
        updateTime: DateTime.parse(json['updateTime'] ?? ""),
        image: json['image'],
        deleted: json['deleted'],
        isLike: json['isLike'] ?? false,
      );
    }
    return CommentDetail(
      id: json['id'],
      userId: json['userId'],
      blogId: json['blogId'],
      parentId: json['parentId'],
      answerId: json['answerId'],
      content: json['content'],
      liked: json['liked'],
      status: json['status'],
      createTime: DateTime.parse(json['createTime'] ?? ""),
      updateTime: DateTime.parse(json['updateTime'] ?? ""),
      image: json['image'],
      deleted: json['deleted'],
      isLike: json['isLike'] ?? false,
      user: json['user'] == '' ? User.empty() : User.fromJson(json['user']),
      answerUser: json['answerUser'] == ''
          ? User.empty()
          : User.fromJson(json['answerUser']),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['blogId'] = blogId;
    data['parentId'] = parentId;
    data['answerId'] = answerId;
    data['content'] = content;
    data['liked'] = liked;
    data['status'] = status;
    data['createTime'] = createTime.toIso8601String();
    data['updateTime'] = updateTime.toIso8601String();
    data['image'] = image;
    data['deleted'] = deleted;
    data['isLike'] = isLike;
    return data;
  }
}

class SecondCommentData {
  int minTime;
  int offset;
  List<CommentDetail> secondComments;

  SecondCommentData(
      {required this.minTime,
      required this.offset,
      required this.secondComments});

  factory SecondCommentData.fromJson(Map<String, dynamic> json) {
    List<CommentDetail> secondComments = [];
    List<dynamic> data;
    try {
      data = json['data'] ?? json;
    } catch (err) {
      data = [];
    }
    for (int i = 0; i < data.length; i++) {
      final CommentDetail secondComment = CommentDetail.fromJson(data[i]);
      secondComments.add(secondComment);
    }
    return SecondCommentData(
        secondComments: secondComments,
        minTime: json['minTime'] ?? 0,
        offset: json['offset'] ?? 0);
  }
}
