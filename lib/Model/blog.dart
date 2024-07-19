import 'package:vcommunity_flutter/Model/user.dart';

import '../constants.dart';
import 'topic.dart';
import 'topicList.dart';

class Blog {
  String id = "0";
  int buildingId = 0;
  int userId = 0;
  User? user;
  String topicId = '';
  String title;
  String images;
  String content;
  double longitude;
  double latitude;
  int liked = 0;
  int comments = 0;
  int views = 0;
  DateTime createTime = DateTime.now();
  DateTime updateTime = DateTime.now();
  bool deleted = false;
  bool isLike = false;
  List<Topic> topics = [];
  double distanceValue;
  String distanceMetric;

  Blog(
    this.title,
    this.images,
    this.content,
    this.latitude,
    this.longitude, {
    this.id = "0",
    this.distanceValue = 0,
    this.distanceMetric = "",
  });
  Blog.fromJson(Map<String, dynamic> json)
      : id = json['data']?['id'] ?? json['id'],
        buildingId = json['data']?['buildingId'] ?? json['buildingId'] ?? -1,
        userId = json['data']?['userId'] ?? json['userId'],
        topicId = json['data']?['topicId'] ?? json['topicId'],
        user = (json['data']?['user'] ?? json['user']) == "{}"
            ? null
            : User.fromJson(json['data']?['user'] ?? json['user']),
        title = json['data']?['title'] ?? json['title'],
        images = json['data']?['images'] ?? json['images'],
        content = json['data']?['content'] ?? json['content'],
        longitude = json['data']?['longitude'] ?? json['longitude'],
        latitude = json['data']?['latitude'] ?? json['latitude'],
        liked = json['data']?['liked'] ?? json['liked'],
        comments = json['data']?['comments'] ?? json['comments'],
        views = json['data']?['views'] ?? json['views'],
        createTime =
            DateTime.parse(json['data']?['createTime'] ?? json['createTime']),
        updateTime =
            DateTime.parse(json['data']?['updateTime'] ?? json['updateTime']),
        deleted = json['data']?['deleted'] ?? json['deleted'],
        isLike = json['data']?['isLike'] ?? json['isLike'] ?? false,
        topics = TopicList.fromJson(json['data']?['topics'] ?? json['topics'])
            .topics,
        distanceValue = json['distance']?['value'] ?? -1,
        distanceMetric = json['distance']?['metric'] ?? "";

  Map<String, dynamic> toJson() => {
        'id': id,
        'buildingId': buildingId,
        'userId': userId,
        'topicId': topicId,
        'title': title,
        'images': images,
        'content': content,
        'longitude': longitude,
        'latitude': latitude,
        'liked': liked,
        'comments': comments,
        'views': views,
        'createTime': createTime.toIso8601String(),
        'updateTime': updateTime.toIso8601String(),
        'deleted': deleted,
        'isLike': isLike,
      };
}

class BlogList {
  List<Blog> blogs = [];
  BlogList(this.blogs);
  factory BlogList.fromJson(dynamic json) {
    List<Map<String, dynamic>> data = List.from(json);
    List<Blog> blogs = [];
    for (Map<String, dynamic> item in data) {
      blogs.add(Blog.fromJson(item));
    }
    return BlogList(blogs);
  }
}
