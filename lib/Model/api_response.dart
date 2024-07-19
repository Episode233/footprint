import 'dart:convert';

class ApiResponse<T> {
  final bool success;
  final String errorMsg;
  final int total;
  final T data;

  ApiResponse({
    required this.success,
    required this.errorMsg,
    required this.total,
    required this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] ?? "",
      errorMsg: json['errorMsg'] ?? "",
      total: json['total'] ?? -1,
      data: fromJson(json['data'] ?? <String, dynamic>{}),
    );
  }
}
