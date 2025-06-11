import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

/// Enum định nghĩa các loại lỗi có thể xảy ra
enum ApiErrorType {
  // Network related errors
  @JsonValue('network')
  network,

  @JsonValue('timeout')
  timeout,

  @JsonValue('connection')
  connection,

  // Server errors
  @JsonValue('server')
  server,

  @JsonValue('unauthorized')
  unauthorized,

  @JsonValue('forbidden')
  forbidden,

  @JsonValue('not_found')
  notFound,

  @JsonValue('rate_limit')
  rateLimit,

  // Client/Validation errors
  @JsonValue('validation')
  validation,

  @JsonValue('invalid_input')
  invalidInput,

  @JsonValue('incomplete_data')
  incompleteData,

  // Business logic errors
  @JsonValue('business_logic')
  businessLogic,

  @JsonValue('ai_processing')
  aiProcessing,

  @JsonValue('parsing')
  parsing,

  // Generic
  @JsonValue('unknown')
  unknown,
}

/// Comprehensive API Error class with clean code principles
@JsonSerializable()
class ApiError implements Exception {
  /// Main error message for users
  final String message;

  /// HTTP status code (if applicable)
  final int? statusCode;

  /// Error type categorization
  final ApiErrorType type;

  /// Technical error details for debugging
  final String? technicalDetails;

  /// Error code for specific error identification
  final String? errorCode;

  /// Additional context data
  final Map<String, dynamic>? metadata;

  /// Timestamp when error occurred
  final DateTime timestamp;

  /// Request ID for tracing (if available)
  final String? requestId;

  ApiError({
    required this.message,
    this.statusCode,
    this.type = ApiErrorType.unknown,
    this.technicalDetails,
    this.errorCode,
    this.metadata,
    DateTime? timestamp,
    this.requestId,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory constructor for network errors
  factory ApiError.network({
    required String message,
    int? statusCode,
    String? technicalDetails,
    String? requestId,
  }) {
    return ApiError(
      message: message,
      statusCode: statusCode,
      type: ApiErrorType.network,
      technicalDetails: technicalDetails,
      requestId: requestId,
    );
  }

  /// Factory constructor for validation errors
  factory ApiError.validation({
    required String message,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiError(
      message: message,
      statusCode: 400,
      type: ApiErrorType.validation,
      errorCode: errorCode,
      metadata: metadata,
    );
  }

  /// Factory constructor for server errors
  factory ApiError.server({
    required String message,
    required int statusCode,
    String? technicalDetails,
    String? requestId,
  }) {
    return ApiError(
      message: message,
      statusCode: statusCode,
      type: ApiErrorType.server,
      technicalDetails: technicalDetails,
      requestId: requestId,
    );
  }

  /// Factory constructor for AI processing errors
  factory ApiError.aiProcessing({
    required String message,
    String? technicalDetails,
    String? errorCode,
  }) {
    return ApiError(
      message: message,
      statusCode: 500,
      type: ApiErrorType.aiProcessing,
      technicalDetails: technicalDetails,
      errorCode: errorCode,
    );
  }

  /// Factory constructor for parsing errors
  factory ApiError.parsing({
    required String message,
    String? technicalDetails,
  }) {
    return ApiError(
      message: message,
      statusCode: 500,
      type: ApiErrorType.parsing,
      technicalDetails: technicalDetails,
      errorCode: 'JSON_PARSE_ERROR',
    );
  }

  /// Factory constructor for incomplete data errors
  factory ApiError.incompleteData({
    required String message,
    List<String>? missingFields,
  }) {
    return ApiError(
      message: message,
      statusCode: 400,
      type: ApiErrorType.incompleteData,
      errorCode: 'INCOMPLETE_DATA',
      metadata: missingFields != null ? {'missingFields': missingFields} : null,
    );
  }

  /// Factory constructor từ DioException
  factory ApiError.fromDioException(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;

    String message;
    ApiErrorType type;
    String? technicalDetails;
    String? errorCode;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Kết nối quá thời gian. Vui lòng thử lại.';
        type = ApiErrorType.timeout;
        break;

      case DioExceptionType.connectionError:
        message = 'Không thể kết nối đến server. Kiểm tra kết nối internet.';
        type = ApiErrorType.connection;
        break;

      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          message = 'Xác thực thất bại. Vui lòng đăng nhập lại.';
          type = ApiErrorType.unauthorized;
        } else if (statusCode == 403) {
          message = 'Bạn không có quyền truy cập tài nguyên này.';
          type = ApiErrorType.forbidden;
        } else if (statusCode == 404) {
          message = 'Không tìm thấy tài nguyên được yêu cầu.';
          type = ApiErrorType.notFound;
        } else if (statusCode == 429) {
          message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
          type = ApiErrorType.rateLimit;
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Lỗi server. Vui lòng thử lại sau.';
          type = ApiErrorType.server;
        } else {
          message = 'Có lỗi xảy ra. Vui lòng thử lại.';
          type = ApiErrorType.unknown;
        }
        break;

      default:
        message = 'Lỗi không xác định. Vui lòng thử lại.';
        type = ApiErrorType.unknown;
    }

    // Extract technical details
    technicalDetails = dioException.message;

    // Extract error code from response if available
    if (data is Map<String, dynamic>) {
      errorCode =
          data['error_code']?.toString() ??
          data['code']?.toString() ??
          data['type']?.toString();
    }

    return ApiError(
      message: message,
      statusCode: statusCode,
      type: type,
      technicalDetails: technicalDetails,
      errorCode: errorCode,
      requestId: dioException.requestOptions.headers['x-request-id']
          ?.toString(),
    );
  }

  /// Kiểm tra xem có phải lỗi network không
  bool get isNetworkError =>
      type == ApiErrorType.network ||
      type == ApiErrorType.timeout ||
      type == ApiErrorType.connection;

  /// Kiểm tra xem có phải lỗi server không
  bool get isServerError =>
      type == ApiErrorType.server || (statusCode != null && statusCode! >= 500);

  /// Kiểm tra xem có phải lỗi client không
  bool get isClientError =>
      type == ApiErrorType.validation ||
      type == ApiErrorType.invalidInput ||
      type == ApiErrorType.incompleteData ||
      (statusCode != null && statusCode! >= 400 && statusCode! < 500);

  /// Kiểm tra xem có thể retry không
  bool get canRetry =>
      isNetworkError || type == ApiErrorType.rateLimit || isServerError;

  /// User-friendly message cho UI
  String get userMessage => message;

  /// Developer message cho logging
  String get developerMessage => technicalDetails ?? message;

  /// Full error description cho debugging
  String get fullDescription {
    final buffer = StringBuffer();
    buffer.writeln('ApiError: $message');

    if (statusCode != null) {
      buffer.writeln('Status Code: $statusCode');
    }

    buffer.writeln('Type: ${type.name}');

    if (errorCode != null) {
      buffer.writeln('Error Code: $errorCode');
    }

    if (technicalDetails != null) {
      buffer.writeln('Technical Details: $technicalDetails');
    }

    if (requestId != null) {
      buffer.writeln('Request ID: $requestId');
    }

    buffer.writeln('Timestamp: ${timestamp.toIso8601String()}');

    if (metadata != null && metadata!.isNotEmpty) {
      buffer.writeln('Metadata: $metadata');
    }

    return buffer.toString();
  }

  /// JSON serialization
  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  /// Copy with method for immutable updates
  ApiError copyWith({
    String? message,
    int? statusCode,
    ApiErrorType? type,
    String? technicalDetails,
    String? errorCode,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? requestId,
  }) {
    return ApiError(
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      type: type ?? this.type,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      errorCode: errorCode ?? this.errorCode,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      requestId: requestId ?? this.requestId,
    );
  }

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApiError &&
        other.message == message &&
        other.statusCode == statusCode &&
        other.type == type &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => Object.hash(message, statusCode, type, errorCode);
}
