import 'package:get/get.dart';
import 'package:vcommunity_flutter/MiddleWare/user_login_middleware.dart';
import 'package:vcommunity_flutter/Page/Blog/Editor/blog_edit_screen.dart';
import 'package:vcommunity_flutter/Page/Blog/blog_detail_screen.dart';
import 'package:vcommunity_flutter/Page/Explore/Building/BuildingAdd/building_add_screen.dart';
import 'package:vcommunity_flutter/Page/Explore/Building/building_detail_screen.dart';
import 'package:vcommunity_flutter/Page/Explore/Topic/TopicAdd/topic_add_screen.dart';
import 'package:vcommunity_flutter/Page/Explore/Topic/topic_detail_screen.dart';
import 'package:vcommunity_flutter/Page/Search/search_screen.dart';
import 'package:vcommunity_flutter/Page/Tool/ScheduleTool/pages/scheduleToolHomePage.dart';
import 'package:vcommunity_flutter/Page/Tool/tool_screen.dart';
import 'package:vcommunity_flutter/Page/User/Info/info_edit.dart';
import 'package:vcommunity_flutter/Page/User/Welcome/welcome_screen.dart';
import 'package:vcommunity_flutter/components/image_display.dart';
import 'Page/Tool/LibraryTool/pages/LibraryHomePage.dart';
import 'Page/Tool/LibraryTool/pages/ScanPage.dart';
import 'Page/Tool/LibraryTool/pages/SignSeatPage.dart';
import 'Page/Tool/LibraryTool/pages/UpdateInfoPage.dart';
import 'Page/Tool/LibraryTool/pages/WebviewPage.dart';
import 'Page/User/Blogs/user_blogs.dart';
import 'Page/User/Login/login_screen.dart';
import 'Page/User/Signup/signup_screen.dart';
import 'Page/home_page.dart';

List<GetPage> routes = [
  GetPage(
    name: '/',
    page: () => const HomePage(),
  ),
  GetPage(
    name: '/imageView',
    page: () => const ImageDisplayScreen(),
  ),
  GetPage(
    name: '/welcome',
    page: () => const WelcomeScreen(),
  ),
  GetPage(
    name: '/login',
    page: () => const LoginScreen(),
  ),
  GetPage(
    name: '/signup',
    page: () => const SignUpScreen(),
  ),
  GetPage(
    name: '/search',
    page: () => const SearchScreen(),
  ),
  GetPage(
    name: '/user/blogs',
    page: () => const UserHistoryBlogs(),
    middlewares: [UserMiddleWare()],
  ),
  GetPage(
    name: '/user/:userId',
    page: () => UserEditScreen(),
    middlewares: [UserMiddleWare()],
  ),
  GetPage(
    name: '/topic/add',
    page: () => const TopicAddScreen(),
    middlewares: [UserMiddleWare()],
  ),
  GetPage(
    name: '/topic/:topicId',
    page: () => const TopicDetailScreen(),
  ),
  GetPage(
    name: '/topic/edit/:topicId',
    page: () => const TopicAddScreen(),
    middlewares: [UserMiddleWare()],
  ),
  GetPage(
    name: '/building/add',
    page: () => const BuildingAddScreen(),
    middlewares: [UserMiddleWare()],
  ),
  GetPage(
    name: '/building/edit/:buildingId',
    page: () => const BuildingAddScreen(),
    middlewares: [UserMiddleWare()],
  ),
  GetPage(
    name: '/building/:buildingId',
    page: () => const BuildingDetailScreen(),
  ),
  GetPage(
      name: '/blog/add',
      page: () => const BlogEditScreen(),
      middlewares: [UserMiddleWare()]),
  GetPage(
    name: '/blog/:blogId',
    page: () => const BlogDetailScreen(),
  ),
  GetPage(
    name: '/tool',
    page: () => const ToolScreenPage(),
  ),
  GetPage(
    name: '/tool/library_tool',
    page: () => const LibraryHomePage(),
  ),
  GetPage(
    name: '/tool/library_tool/webview',
    page: () => const LibraryWebviewPage(),
  ),
  GetPage(
    name: '/tool/library_tool/scan',
    page: () => LibraryScanPage(),
  ),
  GetPage(
    name: '/tool/library_tool/signSeat',
    page: () => const LibrarySignSeatPage(),
  ),
  GetPage(
    name: '/tool/library_tool/updateInfo',
    page: () => LibraryUpdateInfoPage(),
  ),
  GetPage(
    name: '/tool/schedule_tool',
    page: () => const ScheduleToolHomePage(),
  ),
];
