import 'package:dio/dio.dart';

// Sử dụng sealed class cho Dart 3+
sealed class ApiResponse<T> {
  const ApiResponse();
}

class Success<T> extends ApiResponse<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ApiResponse<T> {
  final DioException error;
  const Failure(this.error);

  String get errorMessage {
    // Có thể custom message lỗi ở đây
    return error.message ?? "An unknown error occurred";
  }
  
  int? get statusCode => error.response?.statusCode;
} 