import 'package:vcommunity_flutter/constants.dart';

class Building {
  final int id;
  int? typeId;
  final String name;
  final String icon;
  final String images;
  final double longitude;
  final double latitude;
  final String introduce;
  int liked;
  DateTime? createTime;
  DateTime? updateTime;
  final int state;
  final int createUser;
  int follows;
  final int manageUser;
  bool isLike;
  double distanceValue;
  String distanceMetric;

  Building(
      {this.id = 0,
      this.typeId,
      required this.name,
      required this.icon,
      required this.images,
      required this.longitude,
      required this.latitude,
      required this.introduce,
      this.liked = 0,
      this.createTime,
      this.updateTime,
      this.state = -1,
      this.createUser = 0,
      this.follows = 0,
      this.manageUser = 0,
      this.distanceValue = 0,
      this.distanceMetric = "",
      this.isLike = false});

  factory Building.fromJson(Map<String, dynamic> json) {
    double dist = 0;
    String metric = "METRIC";
    if (json['data'] == null) {
      json['data'] = json;
    } else {
      dist = json['distance']['value'] ?? 0.0;
      metric = json['distance']['metric'] ?? "";
      dist = dist.toInt().toDouble();
    }
    if (json['data'] != null) {
      List images = (json['data']['images'] as String).split(',');
      json['data']['images'] = images.join(',');
    }
    return Building(
      id: json['data']['id'] ?? -1,
      typeId: json['data']['typeId'] ?? -1,
      name: json['data']['name'] ?? "",
      icon: json['data']['icon'] == null || json['data']['icon'] == ""
          ? ""
          : json['data']['icon'],
      images: json['data']['images'] ?? "",
      longitude: json['data']['longitude'] ?? 0.0,
      latitude: json['data']['latitude'] ?? 0.0,
      introduce: json['data']['introduce'] ?? "",
      liked: json['data']['liked'] ?? 0,
      createTime: DateTime.parse(json['data']['createTime'] ?? ""),
      updateTime: DateTime.parse(json['data']['updateTime'] ?? ""),
      state: json['data']['state'] ?? -1,
      createUser: json['data']['createUser'] ?? -1,
      follows: json['data']['follows'] ?? -1,
      manageUser: json['data']['manageUser'] ?? -1,
      isLike: json['data']['isLike'] ?? false,
      distanceValue: dist,
      distanceMetric: metric,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['typeId'] = typeId;
    data['name'] = name;
    data['icon'] = icon;
    data['images'] = images;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['introduce'] = introduce;
    data['liked'] = liked;
    data['createTime'] = createTime?.toIso8601String();
    data['updateTime'] = updateTime?.toIso8601String();
    data['state'] = state;
    data['createUser'] = createUser;
    data['follows'] = follows;
    data['manageUser'] = manageUser;
    return data;
  }
}

class BuildingList {
  final List<Building> buildings;

  BuildingList(this.buildings);

  factory BuildingList.fromJson(dynamic json) {
    List dataList;
    try {
      dataList = (json ?? []) as List;
    } catch (err) {
      dataList = [];
    }
    final buildings = dataList.map((data) => Building.fromJson(data)).toList();
    return BuildingList(buildings);
  }
}
