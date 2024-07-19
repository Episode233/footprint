import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vcommunity_flutter/Page/Blog/BlogList/components/blog_list_item.dart';
import 'package:vcommunity_flutter/util/http_util.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';

import '../../Model/api_response.dart';
import '../../Model/blog.dart';
import '../../constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final HttpUtil _httpUtil = Get.find();
  final TextEditingController _keywordController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> historyKeyword = [];
  List<Widget> historyButton = [];
  String? id;
  late String keyword;
  int timeStamp = DateTime.now().millisecondsSinceEpoch;
  List<int> pages = [1, 1];
  List<bool> notMore = [false, false];
  List<List<Blog>> _blogs = [[], []];
  List<List<Widget>> listWidget = [[], []];
  bool _isLoading = false;

  /// 动态排序类型:
  ///   0按阅读数排序
  ///   1按发布时间排序
  int _blogType = 1;

  ///0-无筛选,1-建筑,2-话题
  int type = 0;

  bool _showHistory = true;
  @override
  void initState() {
    super.initState();
    getHistoryKeyword();
    id = Get.parameters['buildingId'] ?? Get.parameters['topicId'] ?? '';
    type = (Get.parameters['buildingId'] != null) ? 1 : 0;
    type = (Get.parameters['topicId'] != null) ? 2 : 0;
    keyword = Get.parameters['keyword'] ?? '';
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
    if (notMore[_blogType]) {
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        title: Hero(
          tag: 'search',
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: Colors.transparent,
            child: TextField(
              controller: _keywordController,
              textInputAction: TextInputAction.done,
              focusNode: _focusNode,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              decoration: InputDecoration(
                labelText: "搜索",
                hintText: "输入你想搜索的内容",
                contentPadding: const EdgeInsets.symmetric(
                    vertical: defaultPadding / 3, horizontal: defaultPadding),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primaryContainer,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () async {
                    setState(() {
                      _showHistory = false;
                    });
                    keyword = _keywordController.text;
                    setKeyword();
                    refreshData();
                  },
                ),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Get.back(),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius:
                      BorderRadius.all(Radius.circular(largeBorderRadius)),
                ),
              ),
              onTap: () {
                setState(() {
                  _showHistory = true;
                });
              },
              onSubmitted: (value) async {
                setState(() {
                  _showHistory = false;
                });
                keyword = value;
                setKeyword();
                refreshData();
              },
            ),
          ),
        ),
      ),
      body: Stack(children: [
        Offstage(
          offstage: !_showHistory,
          child: Container(
            padding: const EdgeInsets.all(defaultPadding),
            child: ListView(
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      "历史记录",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize),
                    ),
                  ),
                  IconButton(
                      onPressed: () => removeHistory(),
                      icon: const Icon(Icons.restart_alt_rounded))
                ]),
                const SizedBox(
                  height: defaultPadding,
                ),
                Wrap(
                  spacing: defaultPadding / 2, //水平间距
                  runSpacing: defaultPadding / 2, //垂直间距
                  // direction: Axis.vertical,
                  alignment: WrapAlignment.start,
                  // crossAxisAlignment: WrapCrossAlignment.start,
                  children: historyButton,
                ),
              ],
            ),
          ),
        ),
        Offstage(
          offstage: _showHistory,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
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
                  Row(
                    children: [
                      const SizedBox(
                        width: defaultPadding,
                      ),
                      FilterChip(
                        side: BorderSide.none,
                        label: const Text("阅读数"),
                        selected: _blogType == 0,
                        onSelected: (value) {
                          _changeType();
                        },
                      ),
                      const SizedBox(
                        width: defaultPadding,
                      ),
                      FilterChip(
                        side: BorderSide.none,
                        label: const Text("发布时间"),
                        selected: _blogType == 1,
                        onSelected: (value) {
                          _changeType();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: defaultPadding / 2,
                  ),
                  ...(listWidget[_blogType]),
                  tipsWidget
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void getHistoryKeyword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> hisKeyword = prefs.getStringList(keywordPath) ?? [];
    List<Widget> widgets = [];
    for (var i in hisKeyword) {
      widgets.add(getHistoryButton(i));
    }
    setState(() {
      historyKeyword = hisKeyword;
      historyButton = widgets;
    });
  }

  void setKeyword() async {
    if (keyword.removeAllWhitespace == '') {
      return;
    }
    historyKeyword.add(keyword);
    setState(() {
      historyButton.insert(0, getHistoryButton(keyword));
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keywordPath, historyKeyword);
  }

  void getData() async {
    if (_isLoading) {
      return;
    }
    if (notMore[_blogType]) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String api =
        '$apiSearchBlog?key=$keyword&lastId=$timeStamp&page=${pages[_blogType]}&size=$blogPageSize&sortType=$_blogType';
    if (type == 1) {
      api += '&buildingId=$id';
    } else if (type == 2) {
      api += '&topicId=$id';
    }
    Response response = await _httpUtil.get(api);
    pages[_blogType]++;
    List<Blog> blogs =
        ApiResponse.fromJson(response.body, ((json) => BlogList.fromJson(json)))
            .data
            .blogs;
    _blogs[_blogType].addAll(blogs);
    setState(() {
      for (var i in _blogs[_blogType]) {
        listWidget[_blogType].add(BlogListItem(i));
      }
      if (blogs.length < blogPageSize) {
        notMore[_blogType] = true;
      }
      _isLoading = false;
    });
  }

  refreshData() async {
    timeStamp = DateTime.now().millisecondsSinceEpoch;
    pages = [1, 1];
    notMore = [false, false];
    setState(() {
      _blogs = [[], []];
      listWidget = [[], []];
    });
    getData();
  }

  Widget getHistoryButton(String i) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              vertical: 0, horizontal: defaultPadding / 2)),
      onPressed: () {
        _keywordController.text = i;
        _focusNode.requestFocus();
      },
      icon: const Icon(
        Icons.arrow_upward_rounded,
        size: 12,
      ),
      label: Text(
        i,
        style: TextStyle(
            fontSize: 12, color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }

  removeHistory() async {
    historyKeyword.clear();
    setState(() {
      historyButton.clear();
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keywordPath, []);
  }

  void _changeType() {
    setState(() {
      _blogType = _blogType ^ 1;
    });
    getData();
  }
}
