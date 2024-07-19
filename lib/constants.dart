import 'package:flutter/material.dart';

// 样式控制
const Color seed = Colors.blueAccent;
const double defaultPadding = 16.0;
const double defaultButtonPadding = 10.0;
const double defaultBorderRadius = 11;
const double middleBorderRadius = 18;
const double largeBorderRadius = 24;
const double defaultMapCardElevate = 3;
const double defaultMapCardHeight = 70;
const double defaultMapCardWidth = 135;
const double defaultEmojiHeight = 250;
const double largeScreenWidth = 650;

// api
const api = 'http://103.116.247.116:9080/';

// 分页配置
const pageSize = 5;
const blogPageSize = 5;
const firstCommentsPageSize = 5;
const secondCommentsPageSize = 5;
const defaultAvatar =
    'https://episode.649w.cc/avatar.png';

const scheduleAndroidWidgetName = 'ScheduleWidgetProvider';
const scheduleIOSWidgetName = 'ScheduleWidget';

// 天地图api
const webKey = "7fb379c6bc37473df9e15a84ea1bcdf2"; //web端key
const appKey = "5641bf409679ab79d87093aa164f7100"; //服务器端key
// 文件上传
const String apiSendFile = "file/multifile";

// 用户api
const String apiSendCode = "user/code/email?email=";
const String apiRegister = "user/regist/email";
const String apiLogin = "user/login";
const String apiMyInfo = "user/me";
const String apiUserInfo = "user/";

// 话题api
const String apiAddTopic = "topic";
const String apiSearchTopic = "topic/search";
const String apiGetTopicDetail = "topic/detail/";
const String apiFollowTopic = "topicFollow";
const String apiFollowTopicList = "topicFollow/list";

// 建筑api
const String apiSearchBuilding = "building/search";
const String apiGetBuildingType = "buildingType/list";
const String apiSearchBuildingByLocation = "building/list";
const String apiAddBuilding = "building";
const String apiGetBuildingDetail = "building/detail/";
const String apiFollowBuilding = "buildingFollow";
const String apiFollowBuildingList = "buildingFollow/list";

// 动态api
const String apiAddBlog = "blog";
const String apiGetBlogDetail = "blog/detail/";
const String apiNearbyBlog = "blog/list/location";
const String apiSearchBlog = "blog/search";
const String apiMyBlog = "blog/me";
const String apiGetFirstComments = 'blogComments/list/first';
const String apiGetSecondComments = 'blogComments/list/second';
const String apiOperateComments = 'blogComments';
const String apiFollowBlog = "blogLike";

const String userTokenPath = "user:token";
const String keywordPath = "keyword";
const String userLoginPath = "user:login";
