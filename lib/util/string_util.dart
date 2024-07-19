String calculateTimeDifference(DateTime datetime) {
    DateTime now = DateTime.now();
    Duration diff = now.difference(datetime);

    if (diff.inSeconds < 60) {
      return "不足一分钟前";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} 分钟前";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} 小时前";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} 天前";
    } else {
      return "${datetime.year} 年 ${datetime.month} 月 ${datetime.day} 日";
    }
  }

  String calculateLocationDifference(double distance) {
    if (distance == -1) {
      return '';
    }
    if (distance < 60) {
      return "不足60m";
    } else if (distance < 100) {
      return "不足100m";
    } else if (distance < 500) {
      return "不足500m";
    } else if (distance < 1000) {
      return "不足1km";
    } else {
      return "${distance ~/ 1000}km";
    }
  }