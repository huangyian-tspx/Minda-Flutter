# API Error System - Comprehensive Guide

## 📋 Tổng Quan
Hệ thống error handling được thiết kế theo **Clean Code principles** với comprehensive error categorization, user-friendly messages, và robust debugging capabilities.

## 🏗️ Kiến Trúc

### 1. ApiError Class
```dart
// Comprehensive error với tất cả thông tin cần thiết
class ApiError implements Exception {
  final String message;                    // User-friendly message
  final int? statusCode;                   // HTTP status code
  final ApiErrorType type;                 // Error categorization
  final String? technicalDetails;          // Technical info cho developers
  final String? errorCode;                 // Specific error identification
  final Map<String, dynamic>? metadata;   // Additional context
  final DateTime timestamp;               // Khi error xảy ra
  final String? requestId;                 // Request tracing
}
```

### 2. ApiErrorType Enum
```dart
enum ApiErrorType {
  // Network Errors
  network, timeout, connection,
  
  // Server Errors  
  server, unauthorized, forbidden, notFound, rateLimit,
  
  // Client/Validation Errors
  validation, invalidInput, incompleteData,
  
  // Business Logic Errors
  businessLogic, aiProcessing, parsing,
  
  // Generic
  unknown
}
```

### 3. ApiResponse Sealed Class
```dart
sealed class ApiResponse<T> {
  // Pattern matching với type safety
}

final class Success<T> extends ApiResponse<T> {
  final T data;
}

final class Failure<T> extends ApiResponse<T> {
  final ApiError error;
}
```

## 🎯 Factory Constructors

### Network Errors
```dart
ApiError.network(
  message: "Không thể kết nối đến server",
  statusCode: 0,
  technicalDetails: "Connection refused",
  requestId: "req_123"
)
```

### Validation Errors
```dart
ApiError.validation(
  message: "Dữ liệu không hợp lệ",
  errorCode: "VALIDATION_FAILED",
  metadata: {"field": "email", "reason": "invalid_format"}
)
```

### Server Errors
```dart
ApiError.server(
  message: "Lỗi server nội bộ",
  statusCode: 500,
  technicalDetails: "Database connection failed",
  requestId: "req_456"
)
```

### AI Processing Errors
```dart
ApiError.aiProcessing(
  message: "AI không thể xử lý yêu cầu",
  technicalDetails: "Model timeout after 60s",
  errorCode: "AI_TIMEOUT"
)
```

### Parsing Errors
```dart
ApiError.parsing(
  message: "Không thể parse dữ liệu JSON",
  technicalDetails: "Invalid JSON structure at line 5"
)
```

### Incomplete Data Errors
```dart
ApiError.incompleteData(
  message: "Thiếu thông tin bắt buộc",
  missingFields: ["level", "interests", "technologies"]
)
```

### From DioException
```dart
ApiError.fromDioException(dioException)
// Automatically categorizes và tạo user-friendly messages
```

## 🔍 Utility Methods

### Error Classification
```dart
final error = ApiError.network(...);

// Check error type
if (error.isNetworkError) { /* Handle network issues */ }
if (error.isServerError) { /* Handle server issues */ }
if (error.isClientError) { /* Handle validation issues */ }

// Check if retryable
if (error.canRetry) { /* Show retry button */ }
```

### Message Access
```dart
// For UI display
String userMsg = error.userMessage;

// For logging
String devMsg = error.developerMessage;

// For comprehensive debugging
String fullDesc = error.fullDescription;
```

### Pattern Matching Usage
```dart
final response = await apiCall();

switch (response) {
  case Success(data: final data):
    // Handle success
    handleSuccess(data);
    
  case Failure(error: final error):
    // Handle specific error types
    switch (error.type) {
      case ApiErrorType.timeout:
        showRetryDialog();
      case ApiErrorType.unauthorized:
        redirectToLogin();
      case ApiErrorType.validation:
        showValidationErrors(error.metadata);
      default:
        showGenericError(error.message);
    }
}
```

## 🚀 Extension Methods

### Convenience Getters
```dart
final response = await apiCall();

// Quick access
final data = response.dataOrNull;        // T? or null
final error = response.errorOrNull;      // ApiError? or null
final isSuccess = response.isSuccess;    // bool
final isFailure = response.isFailure;    // bool
```

### Functional Transformations
```dart
// Transform success data
final transformed = response.map((data) => data.toDisplayModel());

// Transform error
final customError = response.mapError((error) => 
  error.copyWith(message: "Custom message")
);

// Fold pattern
final result = response.fold(
  onSuccess: (data) => "Success: ${data.length} items",
  onFailure: (error) => "Error: ${error.message}",
);
```

## 📝 Real-World Examples

### 1. OpenRouter API Integration
```dart
// Before (Old way)
return Failure(ApiError(
  error: "Manual error message",
  statusCode: 400,
));

// After (New way)  
return Failure(ApiError.incompleteData(
  message: "Dữ liệu người dùng chưa đầy đủ",
  missingFields: ["level", "interests"],
));
```

### 2. Network Error Handling
```dart
// Automatic DioException conversion
try {
  final response = await dio.post('/api/chat');
  return Success(response.data);
} on DioException catch (e) {
  return Failure(ApiError.fromDioException(e));
}
```

### 3. UI Error Display
```dart
// Controller
case Failure(error: final error):
  if (error.canRetry) {
    showRetrySnackbar(error.message);
  } else {
    showErrorDialog(error.message);
  }
  
  // Log detailed info for debugging
  AppLogger.e(error.fullDescription);
```

### 4. Error Metadata Usage
```dart
final validationError = ApiError.validation(
  message: "Form validation failed",
  metadata: {
    "invalidFields": ["email", "phone"],
    "requirements": {
      "email": "Must be valid email format",
      "phone": "Must be 10 digits"
    }
  }
);

// In UI
final invalidFields = error.metadata?["invalidFields"] as List<String>?;
invalidFields?.forEach((field) => highlightField(field));
```

## 🧪 Testing Patterns

### Unit Tests
```dart
test('ApiError.fromDioException handles timeout correctly', () {
  final dioError = DioException(
    type: DioExceptionType.receiveTimeout,
    requestOptions: RequestOptions(path: '/test'),
  );
  
  final apiError = ApiError.fromDioException(dioError);
  
  expect(apiError.type, ApiErrorType.timeout);
  expect(apiError.isNetworkError, true);
  expect(apiError.canRetry, true);
  expect(apiError.message, contains('thời gian'));
});
```

### Widget Tests
```dart
testWidgets('Error handling displays correct message', (tester) async {
  final error = ApiError.validation(
    message: "Test validation error",
    errorCode: "TEST_ERROR",
  );
  
  await tester.pumpWidget(ErrorWidget(error: error));
  
  expect(find.text("Test validation error"), findsOneWidget);
  expect(find.byIcon(Icons.error), findsOneWidget);
});
```

## 🔧 Configuration & Customization

### Custom Error Types
```dart
// Extend enum nếu cần
enum CustomErrorType {
  businessRule,
  dataCorruption,
  externalService,
}

// Custom factory constructor
factory ApiError.businessRule({
  required String message,
  required String ruleViolated,
}) {
  return ApiError(
    message: message,
    type: ApiErrorType.businessLogic,
    errorCode: 'BUSINESS_RULE_VIOLATION',
    metadata: {'rule': ruleViolated},
  );
}
```

### Localization Support
```dart
// Trong error mapping
String get localizedMessage {
  switch (type) {
    case ApiErrorType.timeout:
      return AppLocalizations.of(context).timeoutError;
    case ApiErrorType.unauthorized:
      return AppLocalizations.of(context).authError;
    default:
      return message;
  }
}
```

## 📊 Best Practices

### 1. **Error Categorization**
- Luôn sử dụng appropriate `ApiErrorType`
- Provide meaningful error codes cho specific errors
- Include technical details cho debugging

### 2. **User Experience**
- User-friendly messages cho UI
- Technical details chỉ cho developers
- Consistent error handling across app

### 3. **Logging & Monitoring**
- Log full error description với `fullDescription`
- Include request IDs cho tracing
- Track error patterns để improve UX

### 4. **Recovery Strategies**
- Check `canRetry` để enable retry functionality
- Provide fallback options cho network errors
- Cache data để minimize error impact

### 5. **Testing**
- Test tất cả error scenarios
- Verify error messages xuất hiện correctly trong UI
- Test error recovery mechanisms

## 🚨 Migration Guide

### From Old ApiResponse
```dart
// Old way
switch (response) {
  case Success(data: final data):
    // handle success
  case Failure(error: final dioException):
    final message = dioException.errorMessage;
    final statusCode = dioException.statusCode;
}

// New way
switch (response) {
  case Success(data: final data):
    // handle success  
  case Failure(error: final apiError):
    final message = apiError.message;
    final statusCode = apiError.statusCode;
    final canRetry = apiError.canRetry;
    final isNetwork = apiError.isNetworkError;
}
```

### Performance Considerations
- `ApiError` objects are immutable → safe to pass around
- `copyWith` method cho efficient updates
- JSON serialization support cho persistence
- Minimal memory footprint với optional fields

---

**✅ Hệ thống ApiError đã sẵn sàng production với comprehensive error handling!** 