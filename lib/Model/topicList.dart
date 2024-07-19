import 'package:vcommunity_flutter/Model/topic.dart';

class TopicList {
  List<Topic> topics = [];
  TopicList(this.topics);
  factory TopicList.fromJson(dynamic json) {
    List<Map<String, dynamic>> data;
    try {
      data = List.from(json);
    } catch (err) {
      data = [];
    }
    List<Topic> topics = [];
    for (Map<String, dynamic> item in data) {
      topics.add(Topic.fromJson(item));
    }
    return TopicList(topics);
  }
}
