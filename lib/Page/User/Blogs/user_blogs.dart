import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Model/api_response.dart';
import '../../../Model/blog.dart';
import '../../../constants.dart';
import '../../../util/http_util.dart';
import '../../../util/user_state_util.dart';
import '../../Blog/BlogList/components/blog_list_item.dart';

class UserHistoryBlogs extends StatefulWidget {
  const UserHistoryBlogs({super.key});

  @override
  State<UserHistoryBlogs> createState() => _UserHistoryBlogsState();
}

class _UserHistoryBlogsState extends State<UserHistoryBlogs> {
  final HttpUtil _httpUtil = Get.find();
  final UserStateUtil _userStateUtil = Get.find();
  int pages = 1;
  bool notMore = false;
  List<Blog> _blogs = [];
  List<Widget> listWidget = [];
  bool _firstLoading = true;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    Widget tipsWidget = const SizedBox();
    if (_firstLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_isLoading) {
      tipsWidget = const Center(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (notMore) {
      tipsWidget = Center(
          child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Text(
          "没有更多了",
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('历史动态')),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            getData();
          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            refreshData();
          },
          child: ListView(
            children: [
              const SizedBox(
                height: defaultPadding / 2,
              ),
              ...listWidget,
              tipsWidget
            ],
          ),
        ),
      ),
    );
  }

  refreshData() async {
    pages = 1;
    notMore = false;
    _isLoading = false;
    setState(() {
      _blogs.clear();
      listWidget.clear();
    });
    await getData();
    _firstLoading = false;
  }

  getData() async {
    if (_isLoading) {
      return;
    }
    if (notMore) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String api = apiMyBlog;
    api = '$api?page=$pages&size=$blogPageSize';

    Response response = await _httpUtil.get(api);
    pages++;
    List<Blog> blogs =
        ApiResponse.fromJson(response.body, ((json) => BlogList.fromJson(json)))
            .data
            .blogs;
    _blogs = blogs;
    setState(() {
      for (var i in _blogs) {
        listWidget.add(BlogListItem(i));
      }
      if (blogs.length < blogPageSize) {
        notMore = true;
      }
      _isLoading = false;
    });
  }
}
