import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter_map/flutter_map.dart'; // Suitable for most situations
import 'package:flutter_map/plugin_api.dart'; // Only import if required functionality is not exposed by default
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/building.dart';
import 'package:vcommunity_flutter/Page/Visual/components/blog_item_in_map.dart';
import 'package:vcommunity_flutter/components/card_title.dart';
import 'package:vcommunity_flutter/components/responsive.dart';
import 'dart:io';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';
import 'package:vcommunity_flutter/util/user_state_util.dart';

import '../../../Model/blog.dart';
import '../../../Model/buildingType.dart';
import '../../../Model/buildingType.dart';
import 'package:vcommunity_flutter/util/native_method_channel.dart';

class MapWidget extends StatefulWidget {
  MapWidget({this.useMap = true, super.key});
  bool useMap;
  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final HttpUtil _httpUtil = Get.find();
  final UserStateUtil _userStateUtil = Get.find();
  final mapController = MapController();

  /// 用户定位位置
  // LatLng pos = LatLng(28.746858, 115.863804);
  LatLng pos = LatLng(39.80818, 116.10586);

  /// 地图中心位置
  // LatLng _nowPos = LatLng(28.746858, 115.863804);
  LatLng _nowPos = LatLng(39.80818, 116.10586);
  // final location = Location();
  bool isForeground = false;
  bool _serviceEnabled = false;
  bool _isLoading = false;
  double _range = 600;
  bool isWeb = false;
  CircleMarker? _circleMark;
  List<MarkerLayer> _buildingLayers = [];
  Map<int, List<Marker>> _buildingMap = {};
  Map<int, bool> _buildingShow = {};
  List<BuildingType> typeList = [];
  List<Marker> _blogs = [];
  Widget _blogCluster = MarkerLayer();
  List<Marker> _userMarker = [];
  bool _showBuilding = true;
  bool _showBlogs = true;
  bool _showUser = true;
  bool _followLocation = false;
  bool _hasLoadData = false;
  int locationPtr = -1;
  late final String key;

  Future<void> requestPermission() async {
    _serviceEnabled;
    LocationPermission permission;
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  @override
  void initState() {
    isForeground = true;
    isWeb = GetPlatform.isWeb;
    if (GetPlatform.isWeb) {
      key = webKey; //web端key
    } else {
      key = appKey; //服务器端key
    }
    _addLocationListener();
    _initTypeList().then((value) {
      setState(() {
        typeList = value;
      });
    });
    super.initState();
  }

  _addLocationListener() async {
    if (GetPlatform.isDesktop) {
      return;
    }
    requestPermission().onError((error, stackTrace) => print(error));

    // 启用位置监听
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (isForeground) {
        _handleUserPos(LatLng(position!.latitude, position.longitude));
      }
    });
  }

  void _handleUserPos(value) {
    printInfo(
        info: "=====================handler user pos ========================");
    // 更新当前位置
    pos = value;
    _userStateUtil.nowPos = value;
    if (!widget.useMap) {
      return;
    }
    setState(() {
      Marker userPin = Marker(
        point: pos,
        width: 60,
        height: 60,
        builder: (context) {
          return Card(
            elevation: defaultMapCardElevate,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
            color: Theme.of(context).colorScheme.inversePrimary,
            child: Center(
              child: Icon(
                Icons.person_pin,
                size: 25,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      );
      _userMarker = [userPin];
    });
  }

  void _updateCircle({double value = -1}) {
    if (!widget.useMap) {
      return;
    }
    setState(() {
      if (value != -1) {
        _range = value;
      }
      _circleMark = CircleMarker(
          point: _nowPos,
          radius: _range,
          useRadiusInMeter: true,
          color: Theme.of(context).primaryColor.withAlpha(20),
          borderColor: Theme.of(context).primaryColor.withAlpha(20));
    });
  }

  void _handlerMove(MapPosition position) async {
    if (_isLoading) {
      return;
    }
    if (!_followLocation && _hasLoadData) {
      return;
    }
    _isLoading = true;
    Future.delayed(const Duration(seconds: 2), () {
      _isLoading = false;
    });
    var pos = position.center;
    _nowPos = pos!;
    _updateCircle();
    _getBuilding();
    _getBlogs();
    _hasLoadData = true;
  }

  void _getBlogs() async {
    String api =
        '$apiNearbyBlog?range=$_range&longitude=${_nowPos.longitude}&latitude=${_nowPos.latitude}';
    Response response = await _httpUtil.get(api);
    List<Blog> blogs =
        ApiResponse.fromJson(response.body, ((json) => BlogList.fromJson(json)))
            .data
            .blogs;
    NativeMethodChannel.blogList = jsonEncode(response.body['data']);
    List<Marker> blogList = [];
    int index = 0;
    for (var i in blogs) {
      blogList.add(
        Marker(
          point: LatLng(i.latitude, i.longitude),
          key: ValueKey(index),
          width: defaultMapCardWidth,
          height: defaultMapCardHeight,
          builder: (context) {
            return BlogItemInMap(i);
          },
        ),
      );
      index++;
    }
    Widget blogCluster = _blogCluster;
    if (blogs.isNotEmpty) {
      blogCluster = MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          size: const Size(defaultMapCardWidth, defaultMapCardHeight),
          maxClusterRadius: 60,
          spiderfyCircleRadius: defaultMapCardWidth.toInt() + 30,
          spiderfySpiralDistanceMultiplier: 4,
          animationsOptions:
              const AnimationsOptions(centerMarkerCurves: Curves.easeOutCubic),
          markers: blogList,
          showPolygon: false,
          disableClusteringAtZoom: 1000,
          builder: (context, markers) {
            int index = (markers.first.key as ValueKey).value as int;
            return Stack(
              children: <Widget>[
                SizedBox(
                  height: defaultMapCardHeight,
                  width: defaultMapCardWidth,
                  child: HeroMode(
                    enabled: false,
                    child: BlogItemInMap(blogs[index]),
                  ),
                ),
                Positioned(
                    bottom: defaultPadding / 2,
                    right: defaultPadding / 2,
                    child: Container(
                      padding: const EdgeInsets.all(defaultPadding / 3),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadius),
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(50),
                              offset: const Offset(4, 3.4),
                              blurRadius: 6,
                              spreadRadius: 1.5)
                        ],
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Text(
                        "展开其他${markers.length - 1}个",
                        style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    ))
              ],
            );
          },
        ),
      );
    }

    setState(() {
      if (blogList.isNotEmpty) {
        _blogCluster = blogCluster;
      }
    });
  }

  Future<List<BuildingType>> _initTypeList() async {
    Response resp = await _httpUtil.get(apiGetBuildingType);
    BuildingTypeList typeList = ApiResponse.fromJson(
        resp.body, (json) => BuildingTypeList.fromJson(json)).data;
    return typeList.buildingTypes;
  }

  void _getBuilding() async {
    final resp = await _httpUtil.get(
        '$apiSearchBuildingByLocation?latitude=${_nowPos.latitude}&longitude=${_nowPos.longitude}&range=$_range');
    if (resp.body == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('接口请求错误'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    BuildingList buildingList =
        ApiResponse.fromJson(resp.body, (json) => BuildingList.fromJson(json))
            .data;
    Map<int, List<Marker>> _buildingMap = {};
    for (Building item in buildingList.buildings) {
      Marker buildingMarker = Marker(
        point: LatLng(item.latitude, item.longitude),
        width: 60,
        height: 60,
        builder: (context) {
          return Hero(
            tag: "/building/${item.id}",
            child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              borderOnForeground: false,
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.toNamed("/building/${item.id}");
                },
                borderRadius: BorderRadius.circular(100),
                child: Card(
                  elevation: defaultMapCardElevate,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: Center(
                    child: item.icon == ""
                        ? Icon(
                            Icons.corporate_fare_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : CircleAvatar(
                            foregroundImage: NetworkImage(item.icon),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      if (_buildingMap.containsKey(item.typeId ?? -1)) {
        _buildingMap[item.typeId ?? -1]!.add(buildingMarker);
      } else {
        _buildingMap[item.typeId ?? -1] = [buildingMarker];
      }
    }
    this._buildingMap = _buildingMap;
    _updateBuildingView();
  }

  void _updateBuildingView({updateId, isAdd}) {
    if (isAdd != null) {
      if (isAdd) {
        setState(() {
          _buildingLayers.add(
            MarkerLayer(
              markers: _buildingMap[updateId]!,
            ),
          );
        });
      } else {
        setState(() {
          _buildingLayers.removeWhere((element) {
            if (element ==
                MarkerLayer(
                  markers: _buildingMap[updateId]!,
                )) {
              return true;
            }
            return false;
          });
        });
      }
    }
    List<MarkerLayer> layers = [];
    var keys = _buildingMap.keys.toList();
    for (var i in keys) {
      if (_buildingShow[i] ?? true) {
        List<Marker> markers = _buildingMap[i]!;
        layers.add(
          MarkerLayer(
            markers: markers,
          ),
        );
      }
    }
    setState(() {
      _buildingLayers = layers;
    });
  }

  void _getLocation() async {
    if (!_serviceEnabled) {
      await _addLocationListener();
    }
    Geolocator.getCurrentPosition().then((value) =>
        mapController.move(LatLng(value.latitude, value.longitude), 16));
    mapController.move(pos, 16);

    if (GetPlatform.isDesktop) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('使用的是桌面端，使用默认位置'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    isForeground = true;
    Size size = MediaQuery.of(context).size;

    List<Widget> showMarkers = [];
    if (_showBuilding) {
      showMarkers.addAll(_buildingLayers);
    }
    if (_showBlogs) {
      showMarkers.add(
        _blogCluster,
      );
    }
    if (_showUser) {
      showMarkers.add(
        MarkerLayer(
          markers: _userMarker,
        ),
      );
    }
    return Responsive(
      mobile: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
              bottom: Radius.zero, top: Radius.circular(largeBorderRadius)),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                center: pos,
                maxZoom: 18,
                zoom: 17,
                minZoom: 2,
                onPositionChanged: (MapPosition position, hasGesture) =>
                    _handlerMove(position),
              ),
              children: [
                TileLayer(
                  subdomains: const ['0', '1', '2', '3'],
                  // retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                  urlTemplate:
                      "https://t{s}.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key",
                ),
                TileLayer(
                  subdomains: const ['0', '1', '2', '3'],
                  // retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                  backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                  urlTemplate:
                      "https://t{s}.tianditu.gov.cn/cva_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key",
                ),
                CircleLayer(
                  circles: [
                    _circleMark ??
                        CircleMarker(
                            point: pos,
                            radius: _range,
                            useRadiusInMeter: true,
                            color: Theme.of(context).primaryColor.withAlpha(20),
                            borderColor:
                                Theme.of(context).primaryColor.withAlpha(20))
                  ],
                ),
                ...showMarkers
              ],
            ),
            Positioned(
                right: defaultPadding + 65,
                bottom: defaultPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: min(size.width - defaultPadding * 2 - 65, 500),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withAlpha(50),
                                offset: Offset(3, 5),
                                blurRadius: 6,
                                spreadRadius: 1)
                          ],
                          borderRadius:
                              BorderRadius.circular(middleBorderRadius),
                          color:
                              Theme.of(context).colorScheme.primaryContainer),
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding / 4,
                          horizontal: defaultPadding / 2),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              icon: _followLocation
                                  ? const Icon(Icons.radar)
                                  : const Icon(Icons.gps_off_rounded),
                              onPressed: () {
                                setState(() {
                                  _followLocation = !_followLocation;
                                });
                              },
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(Icons.filter_alt_rounded),
                              onPressed: () {
                                showBottomSheet();
                              },
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Slider(
                              label: ' 扫描范围:${_range}m ',
                              value: _range,
                              min: 200,
                              max: 2000,
                              divisions: 8,
                              onChanged: (value) => _updateCircle(value: value),
                            ),
                          ),
                          FilledButton(
                            onPressed: (() => _getLocation()),
                            child: const Icon(Icons.location_on_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
      desktop: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(largeBorderRadius)),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                center: pos,
                maxZoom: 18.2,
                zoom: 17,
                minZoom: 2,
                onPositionChanged: (MapPosition position, hasGesture) =>
                    _handlerMove(position),
              ),
              children: [
                TileLayer(
                  subdomains: const ['0', '1', '2', '3'],
                  // retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                  urlTemplate:
                      "https://t{s}.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key",
                ),
                TileLayer(
                  subdomains: const ['0', '1', '2', '3'],
                  // retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                  backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                  urlTemplate:
                      "https://t{s}.tianditu.gov.cn/cva_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key",
                ),
                CircleLayer(
                  circles: [
                    _circleMark ??
                        CircleMarker(
                            point: pos,
                            radius: _range,
                            useRadiusInMeter: true,
                            color: Theme.of(context).primaryColor.withAlpha(20),
                            borderColor:
                                Theme.of(context).primaryColor.withAlpha(20))
                  ],
                ),
                ...showMarkers
              ],
            ),
            Positioned(
                right: defaultPadding,
                bottom: defaultPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: min(size.width - defaultPadding * 2 - 65, 500),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withAlpha(50),
                                offset: Offset(3, 5),
                                blurRadius: 6,
                                spreadRadius: 1)
                          ],
                          borderRadius:
                              BorderRadius.circular(middleBorderRadius),
                          color:
                              Theme.of(context).colorScheme.primaryContainer),
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding / 4,
                          horizontal: defaultPadding / 2),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              icon: _followLocation
                                  ? const Icon(Icons.radar)
                                  : const Icon(Icons.gps_off_rounded),
                              onPressed: () {
                                setState(() {
                                  _followLocation = !_followLocation;
                                });
                              },
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              icon: const Icon(Icons.filter_alt_rounded),
                              onPressed: showBottomSheet,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Slider(
                              label: ' 扫描范围:${_range}m ',
                              value: _range,
                              min: 200,
                              max: 2000,
                              divisions: 8,
                              onChanged: (value) => _updateCircle(value: value),
                            ),
                          ),
                          FilledButton(
                            onPressed: (() => _getLocation()),
                            child: const Icon(Icons.location_on_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    isForeground = false;
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget filterPanel = Row(
              children: [
                FilterChip(
                  side: BorderSide.none,
                  label: const Text("动态"),
                  selected: _showBlogs,
                  onSelected: (value) {
                    setState(() {
                      _showBlogs = value;
                    });
                    this.setState(() {
                      _showBlogs = value;
                    });
                  },
                ),
                const SizedBox(
                  width: defaultPadding / 2,
                ),
                FilterChip(
                  side: BorderSide.none,
                  label: const Text("建筑"),
                  selected: _showBuilding,
                  onSelected: (value) {
                    setState(() {
                      _showBuilding = value;
                    });
                    this.setState(() {
                      _showBuilding = value;
                    });
                  },
                ),
                const SizedBox(
                  width: defaultPadding / 2,
                ),
                FilterChip(
                  side: BorderSide.none,
                  label: const Text("用户"),
                  selected: _showUser,
                  onSelected: (value) {
                    setState(() {
                      _showUser = value;
                    });
                    this.setState(() {
                      _showUser = value;
                    });
                  },
                ),
              ],
            );
            List<Widget> typeButtons = [];
            for (var i in typeList) {
              typeButtons.add(
                FilterChip(
                    side: BorderSide.none,
                    avatar: const Icon(Icons.school_rounded),
                    label: Text(i.name),
                    showCheckmark: false,
                    selected: _buildingShow[i.id] ?? true,
                    onSelected: _showBuilding
                        ? (value) {
                            setState(() {
                              _buildingShow[i.id] = value;
                            });
                            this.setState(() {
                              _buildingShow[i.id] = value;
                            });
                            _updateBuildingView(updateId: i.id, isAdd: value);
                          }
                        : null),
              );
            }
            return Container(
              padding: const EdgeInsets.all(defaultPadding),
              height: 300, //对话框高度就是此高度
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                        child: Container(
                      width: 30,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).colorScheme.primary),
                    )),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    filterPanel,
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Expanded(
                        child: ListView(
                      children: [
                        const CardTitle(
                          "建筑筛选",
                          watchMore: false,
                        ),
                        Wrap(
                          spacing: defaultPadding / 2, // 主轴(水平)方向间距
                          runSpacing: defaultPadding / 2, // 纵轴（垂直）方向间距
                          children: typeButtons,
                        ),
                      ],
                    )),
                  ]),
            );
          },
        );
      },
    );
  }
}
