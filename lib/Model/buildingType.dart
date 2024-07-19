class BuildingType {
  final int id;
  final String name;
  final String iconName;
  final int sort;
  final DateTime? createTime;
  final DateTime? updateTime;

  BuildingType({
    this.id = 0,
    required this.name,
    this.iconName = "",
    this.sort = 0,
    this.createTime,
    this.updateTime,
  });

  factory BuildingType.fromJson(Map<String, dynamic> json) {
    return BuildingType(
      id: json['id'] ?? -1,
      name: json['name'] ?? "",
      iconName: json['iconName'] ?? "",
      sort: json['sort'] ?? 0,
      createTime: DateTime.parse(json['createTime'] ?? ""),
      updateTime: DateTime.parse(json['updateTime'] ?? ""),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['iconName'] = iconName;
    data['sort'] = sort;
    data['createTime'] = createTime?.toIso8601String();
    data['updateTime'] = updateTime?.toIso8601String();
    return data;
  }
}

class BuildingTypeList {
  final List<BuildingType> buildingTypes;

  BuildingTypeList({required this.buildingTypes});

  factory BuildingTypeList.fromJson(dynamic json) {
    final dataList = json as List;
    final buildingTypes =
        dataList.map((data) => BuildingType.fromJson(data)).toList();
    return BuildingTypeList(buildingTypes: buildingTypes);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['buildingTypes'] = buildingTypes.map((type) => type.toJson()).toList();
    return data;
  }
}
