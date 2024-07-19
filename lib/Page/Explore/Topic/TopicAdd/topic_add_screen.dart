import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Page/Explore/Topic/TopicAdd/components/topic_add_form.dart';

class TopicAddScreen extends StatelessWidget {
  const TopicAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String topicId = Get.parameters['topicId'] ?? "";
    if (topicId == "") {
      return Scaffold(
        appBar: AppBar(title: const Text("添加话题")),
        body: TopicAddForm(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("修改话题")),
        body: TopicAddForm(topicId: topicId),
      );
    }
  }
}
