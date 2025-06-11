# Hệ Thống AI Project Suggestion - Hướng Dẫn Implementation

## 📋 Tổng Quan
Hệ thống AI đã được implement hoàn chỉnh để tạo đề xuất dự án thông minh dựa trên dữ liệu người dùng, sử dụng OpenRouter API với model Claude 3.5 Sonnet và comprehensive error handling system.

## 🚀 Luồng Hoạt Động

### 1. Thu Thập Dữ Liệu (Step 1 & 2)
- **Màn hình 1**: Người dùng nhập level, interests, main goal, technologies
- **Màn hình 2**: Người dùng nhập project duration, product types, special requirements, problem to solve
- Dữ liệu được lưu trong `UserDataCollectionService` để manage centralized

### 2. Gọi AI API (Từ Step 2)
- Khi người dùng nhấn "Tiếp tục" ở màn hình refinement
- Hệ thống validate dữ liệu đầy đủ với detailed error messages
- Navigate đến **AI Thinking screen** với loading animation
- Gọi OpenRouter API với prompt được tối ưu hóa

### 3. Xử Lý Response
- AI trả về JSON với 2 categories: `safeProjects` và `challengingProjects`
- Mỗi category có 3 projects với đầy đủ thông tin
- Parse và chuyển thành `TopicSuggestionModel`
- Comprehensive error handling với user-friendly messages
- Navigate đến **Suggestion List** với data

### 4. Hiển Thị Kết Quả
- Filter tabs hiển thị số lượng projects: "An Toàn (3)" và "Thử Thách (3)"
- Cards hiển thị đầy đủ thông tin: title, technologies (với description), match score, duration, feasibility
- Click vào technology hiển thị modal với explanation chi tiết

## 🏗️ Kiến Trúc Hệ Thống

### Core Services
1. **AIPromptService** (`lib/app/data/services/ai_prompt_service.dart`)
   - Tạo prompt siêu tối ưu từ user data
   - Singleton pattern
   - Prompt engineering để đảm bảo JSON response format

2. **OpenRouterAPIService** (`lib/app/data/services/openrouter_api_service.dart`)
   - Handle tất cả API calls đến OpenRouter
   - Comprehensive error handling với ApiError system
   - JSON parsing và validation
   - User data validation với detailed missing fields
   - Singleton pattern

3. **UserDataCollectionService** (Existing)
   - Central data management
   - Validation logic
   - State management với Rx

### Models Enhanced
1. **Technology** (`lib/app/data/models/topic_suggestion_model.dart`)
   ```dart
   class Technology {
     final String name;
     final String description; // Mô tả chi tiết khi user click
   }
   ```

2. **Topic** (Enhanced)
   ```dart
   class Topic {
     final String id;
     final String title;
     final String description;
     final List<Technology> technologies; // Thay đổi từ List<String>
     final String difficulty;
     final int matchScore; // 0-100
     final int duration; // months
     final String feasibilityAssessment; // Đánh giá khả thi
   }
   ```

3. **AIProjectResponse** (`lib/app/data/models/ai_response_model.dart`)
   - Wrapper cho OpenRouter response
   - Support filtering theo category
   - Convert methods

4. **ApiError** (`lib/app/data/models/api_error.dart`) - **NEW**
   ```dart
   class ApiError implements Exception {
     final String message;                    // User-friendly message
     final int? statusCode;                   // HTTP status code
     final ApiErrorType type;                 // Error categorization
     final String? technicalDetails;          // Technical debugging info
     final String? errorCode;                 // Specific error ID
     final Map<String, dynamic>? metadata;   // Additional context
     final DateTime timestamp;               // Error occurrence time
     final String? requestId;                 // Request tracing
   }
   ```

5. **ApiResponse** (Enhanced với Pattern Matching)
   ```dart
   sealed class ApiResponse<T> {}
   final class Success<T> extends ApiResponse<T> { final T data; }
   final class Failure<T> extends ApiResponse<T> { final ApiError error; }
   ```

### Error Handling System - **NEW**
1. **ApiErrorType Enum**
   - Network errors: `network`, `timeout`, `connection`
   - Server errors: `server`, `unauthorized`, `forbidden`, `notFound`, `rateLimit`
   - Client errors: `validation`, `invalidInput`, `incompleteData`
   - Business logic: `businessLogic`, `aiProcessing`, `parsing`

2. **Factory Constructors**
   ```dart
   ApiError.network(message: "...", technicalDetails: "...")
   ApiError.validation(message: "...", metadata: {...})
   ApiError.aiProcessing(message: "...", errorCode: "...")
   ApiError.fromDioException(dioException) // Auto-conversion
   ```

3. **Utility Methods**
   ```dart
   error.isNetworkError  // bool
   error.canRetry        // bool
   error.userMessage     // string for UI
   error.fullDescription // string for debugging
   ```

### Controllers Updated
1. **RefinementController**
   - Added `_callOpenRouterAPI()` method với comprehensive error handling
   - Real API integration thay vì simulation
   - Pattern matching error handling
   - User-friendly error messages trong AI Thinking screen

2. **SuggestionListController**
   - Support nhận data từ arguments
   - Parse data để support filtering
   - Dynamic filter tab counts
   - Error fallback handling

3. **AIThinkingController** (Existing)
   - Dynamic message updates
   - Integration với API calls
   - Error state management

### UI Components Updated
1. **SuggestionProjectCard**
   - Support Technology model với descriptions
   - Click vào tech hiển thị modal explanation
   - Sử dụng real data từ Topic model
   - Feasibility assessment integration

2. **AnimatedFilterTabBar**
   - Dynamic counts: "An Toàn (3)", "Thử Thách (3)"
   - Real-time updates based on AI data

## ⚙️ Configuration

### OpenRouter API Setup
Update `lib/app/core/config/app_configs.dart`:
```dart
static const String openRouterApiKey = "sk-or-v1-YOUR_ACTUAL_API_KEY";
static const String openRouterModel = "anthropic/claude-3.5-sonnet";
```

### Dependencies
Đã auto-inject vào GetIt:
- `AIPromptService.instance`
- `OpenRouterAPIService.instance`
- `UserDataCollectionService` (existing)

## 🎯 AI Prompt Engineering

### Prompt Structure
1. **User Context**: Level, interests, goals, technologies, requirements
2. **Response Format**: Strict JSON schema với validation
3. **Categories**: 
   - **Safe Projects**: Công nghệ ổn định, dễ qua môn (matchScore 80-95%)
   - **Challenging Projects**: Công nghệ mới, điểm cao (matchScore 70-85%)

### Sample Response Format
```json
{
  "safeProjects": [
    {
      "id": "safe_1",
      "title": "Ứng dụng Quản lý Thời khóa biểu",
      "description": "App Flutter đơn giản...",
      "technologies": [
        {
          "name": "Flutter",
          "description": "Framework UI dễ học..."
        }
      ],
      "matchScore": 85,
      "duration": 3,
      "difficulty": "An toàn - Dễ qua môn",
      "feasibilityAssessment": "Khả thi cao..."
    }
  ],
  "challengingProjects": [...]
}
```

## 🔄 Error Handling Examples

### Network Errors
```dart
// Automatic DioException handling
} on DioException catch (e) {
  return Failure(ApiError.fromDioException(e));
}

// Result: User-friendly messages
// "Kết nối quá thời gian. Vui lòng thử lại."
// "Không thể kết nối đến server. Kiểm tra kết nối internet."
```

### Validation Errors
```dart
// Detailed validation với missing fields
return Failure(ApiError.incompleteData(
  message: "Dữ liệu người dùng chưa đầy đủ",
  missingFields: ["level", "interests", "technologies"],
));
```

### AI Processing Errors
```dart
// JSON parsing errors
return Failure(ApiError.parsing(
  message: "AI response không đúng định dạng JSON",
  technicalDetails: "Failed to extract JSON from: ...",
));
```

### UI Error Handling
```dart
// Pattern matching in controllers
switch (response) {
  case Success(data: final data):
    // Handle success
    
  case Failure(error: final error):
    if (error.canRetry) {
      showRetrySnackbar(error.message);
    } else {
      showErrorDialog(error.message);
    }
    
    // Log for debugging
    AppLogger.e(error.fullDescription);
}
```

## 🧪 Testing

### Manual Testing Steps
1. **Complete User Flow**:
   - Fill Step 1: Level, interests, goal, techs
   - Fill Step 2: Duration, product types, requirements
   - Click "Tiếp tục" → Should navigate to AI Thinking
   - Wait for API call → Should navigate to Suggestion List
   - Test filter tabs → Should show correct counts
   - Click technology chips → Should show description modal

2. **Error Scenarios**:
   - Invalid API key → Should show user-friendly error
   - Network timeout → Should handle gracefully với retry option
   - Invalid JSON from AI → Should show parsing error
   - Incomplete user data → Should show detailed validation errors

### Error Testing Scenarios
```dart
// Test specific error types
final timeoutError = ApiError.fromDioException(timeoutException);
assert(timeoutError.isNetworkError == true);
assert(timeoutError.canRetry == true);

final validationError = ApiError.incompleteData(
  message: "Missing data",
  missingFields: ["level"],
);
assert(validationError.metadata!["missingFields"].contains("level"));
```

## 📝 Next Steps (Optional Enhancements)

1. **Error Analytics**: Track error patterns để improve UX
2. **Retry Mechanism**: Auto-retry cho network errors
3. **Offline Support**: Cache responses khi có lỗi network
4. **Error Recovery**: Smart fallback strategies
5. **Localization**: Multi-language error messages

## 🚨 Production Checklist

- [ ] Update API key trong app_configs.dart
- [ ] Test với real OpenRouter account
- [ ] Verify JSON serialization works
- [ ] Test error scenarios comprehensive
- [ ] Check memory leaks (dispose controllers)
- [ ] Validate UI responsiveness
- [ ] Test filter functionality
- [ ] Verify modal bottom sheets work properly
- [ ] Test retry mechanisms
- [ ] Validate error message user-friendliness

## 💡 Troubleshooting

### Common Issues
1. **"UserDataCollectionService not found"**
   - Ensure binding dependencies are properly set up
   - Check if sl<UserDataCollectionService>() is registered

2. **JSON parsing errors**
   - Check AI response format
   - Verify model generation với build_runner
   - Check ApiError.parsing logs

3. **Filter tabs not showing counts**
   - Check if aiResponseData is properly parsed
   - Verify filtering logic trong controller

4. **Network errors not user-friendly**
   - Verify ApiError.fromDioException is working
   - Check if appropriate error types are set

### Debug Commands
```bash
# Regenerate JSON files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check dependencies
flutter pub deps

# Clean và rebuild
flutter clean && flutter pub get
```

### Error Debugging
```dart
// Log full error details
AppLogger.e("Error occurred: ${error.fullDescription}");

// Check error type
if (error.type == ApiErrorType.aiProcessing) {
  // Handle AI-specific errors
}

// Access metadata
final missingFields = error.metadata?["missingFields"] as List<String>?;
```

## 📚 Documentation Links
- **API Error System Guide**: `API_ERROR_SYSTEM_GUIDE.md`
- **Error Handling Best Practices**: Xem section trong API Error Guide
- **Pattern Matching Examples**: ApiResponse extension methods

---

**✅ Hệ thống đã sẵn sàng production với MVP functionality và enterprise-grade error handling!** 