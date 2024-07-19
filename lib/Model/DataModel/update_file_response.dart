class UpdateFileData {
  final List<String> errFiles;
  final Map<String, String> succMap;

  UpdateFileData({required this.errFiles, required this.succMap});

  factory UpdateFileData.fromJson(Map<String, dynamic> json) {
    return UpdateFileData(
      errFiles: List<String>.from(json['errFiles']),
      succMap: Map<String, String>.from(json['succMap']),
    );
  }
}
