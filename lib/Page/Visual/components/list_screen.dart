import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/blog.dart';
import 'package:vcommunity_flutter/util/http_util.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';

import '../../../constants.dart';
import '../../Blog/BlogList/components/blog_list_item.dart';

class ListBlogScreen extends StatefulWidget {
  String url;
  bool notLastId = false;
  ListBlogScreen(this.url, {super.key, this.notLastId = false});

  @override
  State<ListBlogScreen> createState() => _ListBlogScreenState();
}

class _ListBlogScreenState extends State<ListBlogScreen>
    with AutomaticKeepAliveClientMixin {
  final HttpUtil _httpUtil = Get.find();
  final UserStateUtil _userStateUtil = Get.find();
  int timeStamp = DateTime.now().millisecondsSinceEpoch;
  int pages = 1;
  bool notMore = false;
  List<Blog> _blogs = [];
  List<Widget> listWidget = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    Widget tipsWidget = const SizedBox();
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
    return NotificationListener<ScrollNotification>(
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
    );
  }

  refreshData() async {
    timeStamp = DateTime.now().millisecondsSinceEpoch;
    pages = 1;
    notMore = false;
    _isLoading = false;
    setState(() {
      _blogs.clear();
      listWidget.clear();
    });
    getData();
  }

  void getData() async {
    if (_isLoading) {
      return;
    }
    if (notMore) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String api = widget.url;
    if (!widget.notLastId) {
      api = '$api$timeStamp&page=$pages&size=$blogPageSize';
    } else {
      api =
          '$api&longitude=${_userStateUtil.nowPos.longitude}&latitude=${_userStateUtil.nowPos.latitude}';
    }
    Response response = await _httpUtil.get(api);
    pages++;
    List<Blog> blogs =
        ApiResponse.fromJson(response.body, ((json) => BlogList.fromJson(json)))
            .data
            .blogs;
    _blogs = blogs;
    for (var i in _blogs) {
      listWidget.add(BlogListItem(i));
    }
    setState(() {
      if (blogs.length < blogPageSize) {
        notMore = true;
      }
      _isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
