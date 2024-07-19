import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/_http/_stub/_file_decoder_stub.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:vcommunity_flutter/Model/DataModel/update_file_response.dart';
import 'package:vcommunity_flutter/Model/api_response.dart';
import 'package:vcommunity_flutter/Model/building.dart';
import 'package:vcommunity_flutter/Model/buildingType.dart';
import 'package:vcommunity_flutter/Model/topic.dart';
import 'package:vcommunity_flutter/components/card_title.dart';
import 'package:vcommunity_flutter/components/image_card.dart';
import 'package:vcommunity_flutter/components/notice_snackbar.dart';
import 'package:vcommunity_flutter/constants.dart';
import 'package:vcommunity_flutter/util/http_util.dart';

class BuildingAddForm extends StatefulWidget {
  String? buildingId;
  BuildingAddForm({Key? key, this.buildingId}) : super(key: key);

  @override
  State<BuildingAddForm> createState() => _BuildingAddForm();
}

class _BuildingAddForm extends State<BuildingAddForm> {
  final HttpUtil _httpUtil = Get.find();
  final mapController = MapController();
  // LatLng pos = LatLng(28.746858, 115.863804);
  LatLng pos = LatLng(39.80818, 116.10586);
  List<Marker> _buildings = [];
  late final String key;
  bool _isEdit = false;
  bool _isLoadingBuilding = false;
  Building? _building;
  final _nameController = TextEditingController();
  final _introduceController = TextEditingController();
  final _buildingTypeController = TextEditingController();
  final List<DropdownMenuEntry<BuildingType>> _typeEntries =
      <DropdownMenuEntry<BuildingType>>[];
  BuildingType _select = BuildingType(name: "无");
  final _controller = MultiImagePickerController(
      maxImages: 1,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );
  final _imagesController = MultiImagePickerController(
      maxImages: 9,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );

  bool isSending = false;

  @override
  initState() {
    if (widget.buildingId != null) {
      _isEdit = true;
      _isLoadingBuilding = true;
    }
    if (GetPlatform.isWeb) {
      key = webKey;
    } else {
      key = appKey;
    }
    if (_isEdit) {
      _loadBuilding();
    } else {
      _initTypeList();
    }

    super.initState();
  }

  Future<List<BuildingType>> _initTypeList() async {
    Response resp = await _httpUtil.get(apiGetBuildingType);
    BuildingTypeList typeList = ApiResponse.fromJson(
        resp.body, (json) => BuildingTypeList.fromJson(json)).data;
    for (BuildingType type in typeList.buildingTypes) {
      _typeEntries
          .add(DropdownMenuEntry<BuildingType>(label: type.name, value: type));
    }
    setState(() {
      _select = typeList.buildingTypes[0];
    });
    return typeList.buildingTypes;
  }

  Future<List<String>> _getPicUrl(Iterable<ImageFile> images) async {
    NoticeSnackBar.showSnackBar('正在提交...请勿关闭');
    Map<String, dynamic> data = {};
    int i = 0;
    for (final image in images) {
      MultipartFile file;
      if (image.hasPath) {
        file = MultipartFile(File(image.path!), filename: image.name);
      } else {
        // File file = File.fromRawPath(image.bytes!);
        // files.add(MultipartFile(file, filename: image.name));
        List<int> imgBytes = image.bytes as List<int>;
        file = MultipartFile(imgBytes, filename: image.name);
      }
      data.addAll({"file$i": file});
      i++;
    }
    final formData = FormData(data);
    final response = await _httpUtil.post(apiSendFile, formData);
    if (response.status.hasError) {
      // ignore: use_build_context_synchronously
      NoticeSnackBar.showSnackBar('提交失败，未知错误', type: NoticeType.ERROR);
      setState(() {
        isSending = false;
      });
      return [];
    }
    if (response.body['success']) {
      NoticeSnackBar.showSnackBar('图片上传成功');
    } else {
      // ignore: use_build_context_synchronously
      NoticeSnackBar.showSnackBar('提交失败，图片上传失败', type: NoticeType.ERROR);

      setState(() {
        isSending = false;
      });
      return [];
    }
    ApiResponse<UpdateFileData> resp = ApiResponse.fromJson(
        response.body, (json) => UpdateFileData.fromJson(json));
    Map<String, String> pics = resp.data.succMap;
    var keys = pics.keys;
    List<String> picUrls = [];
    for (var element in keys) {
      picUrls.add(pics[element]!);
    }
    return picUrls;
  }

  Future<void> _sendBuilding(BuildContext context) async {
    final icons = _controller.images;
    final images = _imagesController.images;
    var name = _nameController.text;
    var introduce = _introduceController.text;
    var iconSize = icons.length;
    var imageSize = images.length;
    var warnMess = "";
    if (name.isEmpty) {
      warnMess += "建筑名称不能为空\n";
    }
    if (iconSize == 0) {
      warnMess += "尚未选择建筑ICON";
    }
    if (_select.name == "无") {
      warnMess += "尚未选择建筑类别";
    }
    if (warnMess.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(warnMess),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() {
      isSending = true;
    });
    List<String> iconUrls = await _getPicUrl(icons);
    List<String> picUrls = await _getPicUrl(images);
    String pics = picUrls.join(',');
    _building = Building(
        id: _building?.id ?? -1,
        name: name,
        icon: iconUrls[0],
        images: pics,
        longitude: pos.longitude,
        latitude: pos.latitude,
        introduce: introduce,
        typeId: _select.id);
    Response addResp;
    if (_isEdit) {
      addResp = await _httpUtil.put(apiAddBuilding, _building!.toJson());
    } else {
      addResp = await _httpUtil.post(apiAddBuilding, _building!.toJson());
    }
    if (addResp.status.hasError) {
      setState(() {
        isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('服务器错误，添加建筑失败'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (addResp.body['success']) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('添加成功，等待审核'),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        behavior: SnackBarBehavior.floating,
      ));
    }
    Get.back();
  }

  void _handlerTap(tapPosition, LatLng point) {
    pos = point;
    setState(() {
      _buildings = [
        Marker(
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
                  Icons.domain_add_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _buildings = [
      Marker(
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
                Icons.domain_add_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    ];
    if (_isLoadingBuilding) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return ListView(children: [
      Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(children: [
          const CardTitle(
            "点击地图选择建筑位置",
            watchMore: false,
          ),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          Container(
            height: 200,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultBorderRadius)),
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: pos,
                zoom: 17,
                maxZoom: 18.2,
                minZoom: 2,
                onTap: (tapPosition, point) => _handlerTap(tapPosition, point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://t0.tianditu.gov.cn/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key",
                ),
                TileLayer(
                  backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                  urlTemplate:
                      "https://t0.tianditu.gov.cn/cva_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}&tk=$key",
                ),
                MarkerLayer(
                  markers: _buildings,
                )
              ],
            ),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          TextField(
            controller: _nameController,
            maxLength: 20,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            decoration: InputDecoration(
              labelText: "建筑名称",
              hintText: "输入你想添加的建筑名称",
              filled: true,
              fillColor: Theme.of(context).colorScheme.background,
              prefixIcon: const Icon(Icons.corporate_fare_rounded),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadius)),
              ),
            ),
          ),
          DropdownMenu<BuildingType>(
            width: size.width - defaultPadding * 2,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Theme.of(context).colorScheme.background,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadius)),
              ),
            ),
            initialSelection: _select,
            controller: _buildingTypeController,
            label: const Text("建筑类型"),
            dropdownMenuEntries: _typeEntries,
            onSelected: (value) {
              setState(() {
                _select = value!;
              });
            },
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          const CardTitle(
            "建筑ICON",
            watchMore: false,
          ),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          MultiImagePickerView(
            controller: _controller,
            initialContainerBuilder: (context, pickerCallback) {
              return Row(children: [
                SizedBox(
                  height: 130,
                  width: 130,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadius))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.add), Text('添加')]),
                    onPressed: () {
                      pickerCallback();
                    },
                  ),
                ),
              ]);
            },
            itemBuilder: (context, file, deleteCallback) {
              return ImageCard(file: file, deleteCallback: deleteCallback);
            },
          ),
          const SizedBox(
            height: defaultPadding * 2,
          ),
          const CardTitle(
            "建筑图片",
            watchMore: false,
          ),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          MultiImagePickerView(
            controller: _imagesController,
            initialContainerBuilder: (context, pickerCallback) {
              return Row(children: [
                SizedBox(
                  height: 130,
                  width: 130,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadius))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.add), Text('添加')]),
                    onPressed: () {
                      pickerCallback();
                    },
                  ),
                ),
              ]);
            },
            itemBuilder: (context, file, deleteCallback) {
              return ImageCard(file: file, deleteCallback: deleteCallback);
            },
          ),
          const SizedBox(
            height: defaultPadding * 2,
          ),
          TextField(
            controller: _introduceController,
            minLines: 5,
            maxLines: 10,
            maxLength: 200,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            decoration: InputDecoration(
              labelText: "建筑介绍(选填)",
              hintText: "输入你想添加的建筑的简介",
              filled: true,
              fillColor: Theme.of(context).colorScheme.background,
              prefixIcon: const Icon(Icons.bookmark),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadius)),
              ),
            ),
          ),
          const SizedBox(
            height: defaultPadding,
          ),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: isSending ? null : () => _sendBuilding(context),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultButtonPadding),
                    child: Text(_isEdit ? "修改" : "提交"),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          _isEdit
              ? Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary),
                        onPressed: () {
                          _httpUtil.request(apiAddBuilding, "delete",
                              body: _building!.toJson());
                          Get.back();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(defaultButtonPadding),
                          child: Text("删除"),
                        ),
                      ),
                    )
                  ],
                )
              : const SizedBox(),
        ]),
      ),
    ]);
  }

  void _loadBuilding() async {
    final resp = await _httpUtil.get(apiGetBuildingDetail + widget.buildingId!);
    final loadBuilding =
        ApiResponse.fromJson(resp.body, (json) => Building.fromJson(json)).data;
    _building = loadBuilding;
    _nameController.text = loadBuilding.name;
    _introduceController.text = loadBuilding.introduce;
    List<BuildingType> typeList = await _initTypeList();
    for (var type in typeList) {
      if (type.id == loadBuilding.typeId!) {
        _select = type;
        break;
      }
    }
    if (loadBuilding.icon != "") {
      var iconData = (await NetworkAssetBundle(Uri.parse(loadBuilding.icon))
              .load(loadBuilding.icon))
          .buffer
          .asUint8List();
      ImageFile iconFile = ImageFile(_building!.icon,
          extension: 'png', name: _building!.icon, bytes: iconData);
      setState(
        () {
          _controller.addImage(iconFile);
        },
      );
    }
    if (loadBuilding.images != '') {
      for (String url in loadBuilding.images.split(',')) {
        if (url != "") {
          var imageData = (await NetworkAssetBundle(Uri.parse(url)).load(url))
              .buffer
              .asUint8List();
          ImageFile imageFile =
              ImageFile(url, extension: 'png', name: url, bytes: imageData);
          setState(
            () {
              _imagesController.addImage(imageFile);
            },
          );
        }
      }
    }

    setState(() {
      pos = LatLng(_building!.latitude, _building!.longitude);
      _isLoadingBuilding = false;
    });
  }
}
