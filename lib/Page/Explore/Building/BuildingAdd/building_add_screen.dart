import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/building_add_form.dart';

class BuildingAddScreen extends StatelessWidget {
  const BuildingAddScreen({super.key});
  @override
  Widget build(BuildContext context) {
    String buildingId = Get.parameters['buildingId'] ?? "";
    if (buildingId == "") {
      return Scaffold(
        appBar: AppBar(title: const Text("添加建筑")),
        body: BuildingAddForm(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("修改建筑")),
        body: BuildingAddForm(
          buildingId: buildingId,
        ),
      );
    }
  }
}
