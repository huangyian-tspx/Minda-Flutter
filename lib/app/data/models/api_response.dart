import 'package:dio/dio.dart';
import 'api_error.dart';

/// Sealed class cho API Response pattern với type safety
/// Sử dụng pattern matching trong Dart 3+
sealed class ApiResponse<T> {
  const ApiResponse();
}

/// Success response với data
final class Success<T> extends ApiResponse<T> {
  final T data;
  
  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// Failure response với ApiError
final class Failure<T> extends ApiResponse<T> {
  final ApiError error;
  
  const Failure(this.error);

  /// Convenience constructor từ DioException
  factory Failure.fromDioException(DioException dioException) {
    return Failure(ApiError.fromDioException(dioException));
  }

  /// Convenience getters cho backward compatibility
  String get errorMessage => error.message;
  int? get statusCode => error.statusCode;
  ApiErrorType get errorType => error.type;
  
  /// Check if error can be retried
  bool get canRetry => error.canRetry;
  
  /// Check if it's a network error
  bool get isNetworkError => error.isNetworkError;
  
  /// Check if it's a server error
  bool get isServerError => error.isServerError;
  
  /// Check if it's a client error
  bool get isClientError => error.isClientError;

  @override
  String toString() => 'Failure(error: ${error.message})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}

/// Extension methods cho ApiResponse để làm code cleaner
extension ApiResponseExtensions<T> on ApiResponse<T> {
  /// Get data nếu success, null nếu failure
  T? get dataOrNull {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => null,
    };
  }
  
  /// Get error nếu failure, null nếu success
  ApiError? get errorOrNull {
    return switch (this) {
      Success() => null,
      Failure(error: final error) => error,
    };
  }
  
  /// Check if response is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if response is failure
  bool get isFailure => this is Failure<T>;
  
  /// Transform success data
  ApiResponse<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => Success(transform(data)),
      Failure(error: final error) => Failure(error),
    };
  }
  
  /// Transform failure error
  ApiResponse<T> mapError(ApiError Function(ApiError error) transform) {
    return switch (this) {
      Success(data: final data) => Success(data),
      Failure(error: final error) => Failure(transform(error)),
    };
  }
  
  /// Fold pattern: handle both success and failure
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiError error) onFailure,
  }) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Failure(error: final error) => onFailure(error),
    };
  }
} 