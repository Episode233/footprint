import '../constants.dart';

class User {
  final int id;
  final String email;
  String nickName;
  String icon;
  DateTime? createTime;
  String introduce;
  int fans;
  int follows;
  int blogs;
  bool gender;
  DateTime? birthday;
  int exp;
  int level;
  int typeId;

  User({
    this.id = 0,
    required this.email,
    required this.nickName,
    required this.icon,
    this.createTime,
    required this.introduce,
    this.fans = 0,
    this.follows = 0,
    this.blogs = 0,
    this.gender = false,
    this.birthday,
    this.exp = 0,
    this.level = 0,
    this.typeId = 0,
  });
  factory User.empty() {
    return User(
        email: "",
        nickName: '未登录用户',
        icon:
            "https://episode.649w.cc/avatar.png",
        introduce: '未登录用户');
  }
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? -1,
      email: json['email'] ?? "",
      nickName: json['nickName'] ?? "未知用户",
      icon: json['icon'] ??
          "https://episode.649w.cc/avatar.png",
      createTime:
          DateTime.parse(json['createTime'] ?? DateTime.now().toString()),
      introduce: json['introduce'] ?? "",
      fans: json['fans'] ?? 0,
      follows: json['follows'] ?? 0,
      blogs: json['blogs'] ?? 0,
      gender: json['gender'] ?? false,
      birthday: DateTime.parse(json['birthday'] ?? DateTime.now().toString()),
      exp: json['exp'] ?? 0,
      level: json['level'] ?? 0,
      typeId: json['typeId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['nickName'] = nickName;
    data['icon'] = icon;
    data['createTime'] = createTime?.toIso8601String();
    data['introduce'] = introduce;
    data['fans'] = fans;
    data['follows'] = follows;
    data['blogs'] = blogs;
    data['gender'] = gender;
    data['birthday'] = birthday?.toIso8601String();
    data['exp'] = exp;
    data['level'] = level;
    data['typeId'] = typeId;
    return data;
  }
}

class UserList {
  final List<User> users;

  UserList({required this.users});

  factory UserList.fromJson(dynamic json) {
    final dataList = json as List;
    final users = dataList.map((data) => User.fromJson(data)).toList();
    return UserList(users: users);
  }
}
