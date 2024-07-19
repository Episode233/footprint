import 'package:get/get.dart';

import '../constants.dart';

class Topic {
  int? id;
  String name;
  String? introduce;
  String icon;
  int state;
  int createUser;
  int follows;
  bool isLike;

  Topic(
      {this.id,
      required this.name,
      this.introduce,
      required this.icon,
      this.state = 0,
      this.createUser = 0,
      this.follows = 0,
      this.isLike = false});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
        id: json['id'],
        name: json['name'],
        introduce: json['introduce'],
        icon: (json['icon'] ?? '') == '' ? defaultAvatar : json['icon'],
        state: json['state'] ?? 0,
        createUser: json['createUser'] ?? 0,
        follows: json['follows'] ?? 0,
        isLike: json['isLike'] ?? false);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) {
      data['id'] = id;
    }
    data['name'] = name;
    data['icon'] = icon;
    data['introduce'] = introduce ?? '';
    data['state'] = state;
    data['createUser'] = createUser;
    data['follows'] = follows;
    return data;
  }
}
