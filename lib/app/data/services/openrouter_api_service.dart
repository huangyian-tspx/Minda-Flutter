import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;

import '../../core/config/app_configs.dart';
import '../../core/utils/app_logger.dart';
import '../models/ai_response_model.dart';
import '../models/api_error.dart';
import '../models/api_response.dart';
import '../models/project_dashboard_model.dart';
import '../models/topic_suggestion_model.dart';
import '../models/user_input_data.dart';
import 'ai_prompt_service.dart';
import 'user_data_collection_service.dart';

/// Service chuyên xử lý API calls đến OpenRouter
class OpenRouterAPIService {
  static OpenRouterAPIService? _instance;
  late Dio _dio;

  static OpenRouterAPIService get instance {
    _instance ??= OpenRouterAPIService._();
    return _instance!;
  }

  OpenRouterAPIService._() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfigs.openRouterBaseUrl,
        connectTimeout: AppConfigs.connectTimeout,
        receiveTimeout: AppConfigs.receiveTimeout,
        headers: {
          'Authorization': 'Bearer ${AppConfigs.openRouterApiKey}',
          'HTTP-Referer': AppConfigs.appUrl,
          'X-Title': AppConfigs.appName,
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => AppLogger.d(object.toString()),
      ),
    );
  }

  /// Generate project suggestions từ user data
  Future<ApiResponse<TopicSuggestionModel>> generateProjectSuggestions() async {
    try {
      AppLogger.d("Starting OpenRouter API call for project suggestions");

      // Lấy user data từ service
      final userDataService = getx.Get.isRegistered<UserDataCollectionService>()
          ? getx.Get.find<UserDataCollectionService>()
          : null;

      if (userDataService == null) {
        AppLogger.e("UserDataCollectionService not found");
        return Failure(
          ApiError.server(
            message: "Dịch vụ thu thập dữ liệu người dùng không khả dụng",
            statusCode: 500,
            technicalDetails:
                "UserDataCollectionService not registered in GetX",
          ),
        );
      }

      final userData = userDataService.getCurrentData();

      AppLogger.d("User data for AI: ${userData.toString()}");

      // Validate user data
      if (!userData.isComplete()) {
        AppLogger.e("User data is incomplete");
        return Failure(
          ApiError.incompleteData(
            message:
                "Dữ liệu người dùng chưa đầy đủ. Vui lòng hoàn thành các bước trước.",
            missingFields: _getMissingFields(userData),
          ),
        );
      }

      // Generate prompt
      final prompt = AIPromptService.instance.generateProjectSuggestionPrompt(
        userData,
      );
      AppLogger.d("Generated prompt length: ${prompt.length}");

      // Prepare request body
      final requestBody = {
        "model": AppConfigs.openRouterModel,
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens":
            3500, // UPGRADED: Increased from 1800 to 3500 for paid API
        "temperature": 0.7,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
      };

      AppLogger.d("Sending request to OpenRouter...");

      // Make API call
      final response = await _dio.post('/chat/completions', data: requestBody);

      AppLogger.d("OpenRouter response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse OpenRouter response
        final openRouterResponse = OpenRouterResponse.fromJson(response.data);
        final aiContent = openRouterResponse.content.trim();

        AppLogger.d("AI response content length: ${aiContent.length}");
        AppLogger.d(
          "AI response preview: ${aiContent.length > 200 ? aiContent.substring(0, 200) + '...' : aiContent}",
        );

        // Parse JSON from AI response
        final aiJsonData = _extractJsonFromAIResponse(aiContent);
        if (aiJsonData == null) {
          AppLogger.e("Failed to extract JSON from AI response");
          return Failure(
            ApiError.parsing(
              message: "AI response không đúng định dạng JSON",
              technicalDetails:
                  "Failed to extract valid JSON from AI response: ${aiContent.length > 200 ? aiContent.substring(0, 200) + '...' : aiContent}",
            ),
          );
        }

        // Convert to AIProjectResponse
        final aiProjectResponse = AIProjectResponse.fromJson(aiJsonData);
        AppLogger.d(
          "Successfully parsed AI response: ${aiProjectResponse.safeProjects.length} safe + ${aiProjectResponse.challengingProjects.length} challenging projects",
        );

        // Convert to TopicSuggestionModel
        final topicSuggestionModel = aiProjectResponse.toTopicSuggestionModel();

        AppLogger.d(
          "Generated ${topicSuggestionModel.topics.length} project suggestions successfully",
        );

        return Success(topicSuggestionModel);
      } else {
        AppLogger.e(
          "OpenRouter API error: ${response.statusCode} - ${response.data}",
        );
        return Failure(
          ApiError.server(
            message: "Lỗi từ OpenRouter API: ${response.statusMessage}",
            statusCode: response.statusCode ?? 500,
            technicalDetails: "Response data: ${response.data}",
          ),
        );
      }
    } on DioException catch (e) {
      AppLogger.e("DioException in OpenRouter API: ${e.message}");

      // Handle specific error cases
      if (e.response?.statusCode == 402) {
        final errorData = e.response?.data;
        String userMessage =
            "💳 Tài khoản đã được nâng cấp nhưng vẫn gặp lỗi thanh toán. Hệ thống sẽ fallback với 1800 tokens.";

        if (errorData is Map<String, dynamic>) {
          final errorInfo = errorData['error'];
          if (errorInfo is Map<String, dynamic>) {
            final message = errorInfo['message']?.toString();
            if (message != null && message.contains('credits')) {
              userMessage =
                  "💰 Credits đã hết. Vui lòng nạp thêm credits để sử dụng full 3500 tokens.";
            } else if (message != null && message.contains('max_tokens')) {
              userMessage =
                  "📝 Request 3500 tokens quá lớn. Hệ thống sẽ retry với tokens thấp hơn.";
            }
          }
        }

        // Automatic fallback với token thấp hơn
        AppLogger.d("Attempting fallback with reduced tokens...");
        return await _fallbackWithReducedTokens();
      }

      return Failure(ApiError.fromDioException(e));
    } catch (e) {
      AppLogger.e("Unexpected error in OpenRouter API: $e");
      return Failure(
        ApiError.server(
          message: "Lỗi không xác định trong quá trình xử lý AI",
          statusCode: 500,
          technicalDetails: e.toString(),
        ),
      );
    }
  }

  /// Get missing fields từ user data để tạo detailed error message
  List<String> _getMissingFields(UserInputData userData) {
    final missingFields = <String>[];

    if (userData.level == null) missingFields.add('level');
    if (userData.interests.isEmpty) missingFields.add('interests');
    if (userData.mainGoal == null) missingFields.add('mainGoal');
    if (userData.technologies.isEmpty) missingFields.add('technologies');
    if (userData.productTypes.isEmpty) missingFields.add('productTypes');

    return missingFields;
  }

  /// Fallback method với reduced tokens khi gặp lỗi 402
  Future<ApiResponse<TopicSuggestionModel>> _fallbackWithReducedTokens() async {
    try {
      AppLogger.d("Executing fallback with reduced tokens (1500)");

      // Lấy user data từ service
      final userDataService = getx.Get.isRegistered<UserDataCollectionService>()
          ? getx.Get.find<UserDataCollectionService>()
          : null;

      if (userDataService == null) {
        AppLogger.e("UserDataCollectionService not found in fallback");
        return Failure(
          ApiError.server(
            message: "Dịch vụ thu thập dữ liệu người dùng không khả dụng",
            statusCode: 500,
            technicalDetails:
                "UserDataCollectionService not registered in GetX",
          ),
        );
      }

      final userData = userDataService.getCurrentData();

      // Generate fallback prompt (more compact)
      final prompt = AIPromptService.instance.generateProjectSuggestionPrompt(
        userData,
      );

      // Prepare request body với reduced tokens
      final requestBody = {
        "model": AppConfigs.openRouterModel,
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 1500, // Fallback token limit
        "temperature": 0.7,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
      };

      AppLogger.d("Sending fallback request with 1500 tokens...");

      // Make fallback API call
      final response = await _dio.post('/chat/completions', data: requestBody);

      if (response.statusCode == 200) {
        final openRouterResponse = OpenRouterResponse.fromJson(response.data);
        final aiContent = openRouterResponse.content.trim();

        AppLogger.d("Fallback AI response content length: ${aiContent.length}");

        final aiJsonData = _extractJsonFromAIResponse(aiContent);
        if (aiJsonData == null) {
          return Failure(
            ApiError.parsing(
              message: "AI response trong fallback không đúng định dạng JSON",
              technicalDetails: "Failed to extract JSON from fallback response",
            ),
          );
        }

        final aiProjectResponse = AIProjectResponse.fromJson(aiJsonData);
        final topicSuggestionModel = aiProjectResponse.toTopicSuggestionModel();

        AppLogger.d(
          "Fallback successful: Generated ${topicSuggestionModel.topics.length} projects",
        );

        return Success(topicSuggestionModel);
      } else {
        AppLogger.e("Fallback request failed: ${response.statusCode}");
        return Failure(
          ApiError.server(
            message: "Cả request chính và fallback đều thất bại",
            statusCode: response.statusCode ?? 500,
            technicalDetails: "Fallback response: ${response.data}",
          ),
        );
      }
    } catch (e) {
      AppLogger.e("Error in fallback method: $e");
      return Failure(
        ApiError.server(
          message: "Fallback request cũng gặp lỗi. Vui lòng thử lại sau.",
          statusCode: 500,
          technicalDetails: e.toString(),
        ),
      );
    }
  }

  /// Extract JSON from AI response with better error handling
  Map<String, dynamic>? _extractJsonFromAIResponse(String aiResponse) {
    try {
      // Remove markdown code blocks if present
      String cleanedResponse = aiResponse;

      // Remove ```json and ``` if present
      cleanedResponse = cleanedResponse.replaceAll(RegExp(r'```json\s*'), '');
      cleanedResponse = cleanedResponse.replaceAll(RegExp(r'```\s*$'), '');

      // Find JSON object start and end
      final startIndex = cleanedResponse.indexOf('{');
      final lastIndex = cleanedResponse.lastIndexOf('}');

      if (startIndex == -1 || lastIndex == -1 || startIndex >= lastIndex) {
        AppLogger.e("Cannot find valid JSON structure in AI response");
        AppLogger.e(
          "Response preview: ${aiResponse.substring(0, aiResponse.length > 300 ? 300 : aiResponse.length)}",
        );
        return null;
      }

      final jsonString = cleanedResponse.substring(startIndex, lastIndex + 1);

      // Try to parse JSON
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        // If parsing fails, try to fix common JSON issues
        AppLogger.e("Initial JSON parsing failed: $e");
        AppLogger.e("Attempting to fix JSON...");

        // Try to fix missing closing braces
        String fixedJson = jsonString;
        int openBraces = '{'.allMatches(jsonString).length;
        int closeBraces = '}'.allMatches(jsonString).length;

        if (openBraces > closeBraces) {
          fixedJson = jsonString + '}' * (openBraces - closeBraces);
          AppLogger.d(
            "Added ${openBraces - closeBraces} missing closing braces",
          );
        }

        // Try to fix missing quotes around keys
        fixedJson = fixedJson.replaceAllMapped(
          RegExp(r'([{,])\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:'),
          (match) => '${match.group(1)}"${match.group(2)}":',
        );

        try {
          return json.decode(fixedJson) as Map<String, dynamic>;
        } catch (e2) {
          AppLogger.e("Failed to fix JSON: $e2");
          AppLogger.e("Original JSON string: $jsonString");
          AppLogger.e("Fixed JSON string: $fixedJson");
          return null;
        }
      }
    } catch (e) {
      AppLogger.e("Error parsing JSON from AI response: $e");
      AppLogger.e(
        "Response preview: ${aiResponse.substring(0, aiResponse.length > 300 ? 300 : aiResponse.length)}",
      );
      return null;
    }
  }

  /// Get detailed project information by ID
  ///
  /// Gọi OpenRouter API để lấy thông tin chi tiết hơn về 1 dự án cụ thể
  /// dựa trên ID và user context để có thông tin personalized
  ///
  /// [projectId] ID của dự án cần lấy chi tiết
  /// [basicTopic] Thông tin cơ bản của topic để context
  Future<ApiResponse<ProjectTopic>> getProjectDetail(
    String projectId,
    Topic basicTopic,
  ) async {
    try {
      AppLogger.d("Getting project detail for ID: $projectId");

      // Lấy user data để personalize response
      final userDataService = getx.Get.isRegistered<UserDataCollectionService>()
          ? getx.Get.find<UserDataCollectionService>()
          : null;

      if (userDataService == null) {
        AppLogger.e("UserDataCollectionService not found for project detail");
        return Failure(
          ApiError.server(
            message: "Dịch vụ thu thập dữ liệu người dùng không khả dụng",
            statusCode: 500,
            technicalDetails:
                "UserDataCollectionService not registered in GetX",
          ),
        );
      }

      final userData = userDataService.getCurrentData();
      AppLogger.d("User data for project detail: ${userData.toString()}");

      // Generate prompt for detailed project info
      final prompt = AIPromptService.instance.generateProjectDetailPrompt(
        userData,
        basicTopic,
      );
      AppLogger.d("Generated project detail prompt length: ${prompt.length}");

      // Prepare request body
      final requestBody = {
        "model": AppConfigs.openRouterModel,
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens":
            2500, // UPGRADED: Increased from 1200 to 2500 for paid API
        "temperature": 0.7,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
      };

      AppLogger.d("Sending project detail request to OpenRouter...");

      // Make API call
      final response = await _dio.post('/chat/completions', data: requestBody);

      AppLogger.d(
        "OpenRouter project detail response status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final aiContent = responseData['choices'][0]['message']['content'];

        AppLogger.d("AI project detail content length: ${aiContent.length}");
        AppLogger.d(
          "AI project detail preview: ${aiContent.length > 200 ? aiContent.substring(0, 200) + '...' : aiContent}",
        );

        // Parse JSON from AI response
        final aiJsonData = _extractJsonFromAIResponse(aiContent);
        if (aiJsonData == null) {
          AppLogger.e("Failed to extract JSON from AI project detail response");
          return Failure(
            ApiError.parsing(
              message: "AI response không đúng định dạng JSON",
              technicalDetails:
                  "Failed to extract valid JSON from AI project detail response: ${aiContent.length > 200 ? aiContent.substring(0, 200) + '...' : aiContent}",
            ),
          );
        }

        // Convert to ProjectTopic
        final projectTopic = ProjectTopic.fromJson(aiJsonData, basicTopic);
        AppLogger.d(
          "Successfully parsed AI project detail for: ${projectTopic.title}",
        );

        return Success(projectTopic);
      } else {
        AppLogger.e(
          "OpenRouter project detail API error: ${response.statusCode} - ${response.data}",
        );
        return Failure(
          ApiError.server(
            message: "Lỗi từ OpenRouter API: ${response.statusMessage}",
            statusCode: response.statusCode ?? 500,
            technicalDetails: "Response data: ${response.data}",
          ),
        );
      }
    } on DioException catch (e) {
      AppLogger.e(
        "DioException in OpenRouter project detail API: ${e.message}",
      );

      // Handle specific error cases
      if (e.response?.statusCode == 402) {
        final errorData = e.response?.data;
        String userMessage =
            "⚡ Hệ thống đã tối ưu xuống 1200 tokens để tiết kiệm credits.";

        if (errorData is Map<String, dynamic>) {
          final errorInfo = errorData['error'];
          if (errorInfo is Map<String, dynamic>) {
            final message = errorInfo['message']?.toString();
            if (message != null && message.contains('credits')) {
              userMessage =
                  "💰 Credits không đủ. Đã tối ưu tối đa để tiết kiệm. Vui lòng nâng cấp tài khoản để trải nghiệm đầy đủ.";
            } else if (message != null && message.contains('max_tokens')) {
              userMessage =
                  "📝 Request quá lớn. Hệ thống đã giảm xuống 1200 tokens.";
            }
          }
        }

        return Failure(
          ApiError.server(
            message: userMessage,
            statusCode: 402,
            technicalDetails:
                "OpenRouter 402 error after token optimization: ${e.response?.data}",
            requestId: e.response?.headers.value('cf-ray'),
          ),
        );
      }

      return Failure(ApiError.fromDioException(e));
    } catch (e) {
      AppLogger.e("Unexpected error in OpenRouter project detail API: $e");
      return Failure(
        ApiError.server(
          message: "Lỗi không xác định trong quá trình xử lý AI",
          statusCode: 500,
          technicalDetails: e.toString(),
        ),
      );
    }
  }

  /// Generate comprehensive project documentation cho Notion
  ///generateProjectDocumentation
  /// Call OpenRouter API để tạo nội dung tài liệu BA-style cho dự án
  ///
  /// [project] Thông tin dự án dạng Map
  Future<ApiResponse<Map<String, dynamic>>> generateProjectDocumentation(
    Map<String, dynamic> project,
  ) async {
    try {
      AppLogger.d(
        "Generating PROFESSIONAL project documentation for: ${project['name']}",
      );

      // 1. Advanced Prompt Engineering
      // We are crafting a highly detailed prompt to get the best possible output.
      // This is the core of the improvement.
      final String detailedPrompt =
          """
      As a Senior Solutions Architect and Product Manager, create a comprehensive and professional project documentation in JSON format.
      The project details provided by the user are:
      - Name: ${project['name']}
      - Description: ${project['description']}
      - Core Features: ${project['features']?.join(', ')}
      - Tech Stack: ${project['techStack']?.join(', ')}

      The output JSON MUST strictly follow this detailed schema:
      {
        "title": "Tên dự án",
        "projectOverview": {
          "problemStatement": "Phân tích chi tiết vấn đề mà dự án này giải quyết.",
          "targetAudience": "Mô tả chi tiết đối tượng người dùng mục tiêu (demographics, needs, pain points).",
          "solution": "Trình bày giải pháp đề xuất một cách toàn diện, nó giải quyết vấn đề như thế nào."
        },
        "userPersonas": [
          { "name": "Tên persona (ví dụ: Sinh viên IT năm cuối)", "demographics": "Thông tin nhân khẩu học", "goals": ["Mục tiêu chính khi dùng app"], "frustrations": ["Những khó khăn, rào cản họ gặp phải"] }
        ],
        "functionalRequirements": [
          { "id": "FEAT-01", "name": "Tên tính năng", "userStory": "As a [user type], I want to [action] so that [benefit].", "acceptanceCriteria": ["Điều kiện chấp nhận 1", "Điều kiện chấp nhận 2"] }
        ],
        "nonFunctionalRequirements": [
          { "category": "Performance", "requirement": "API response time for core actions should be under 200ms." },
          { "category": "Security", "requirement": "All user data must be encrypted at rest and in transit. Use JWT for authentication." },
          { "category": "Scalability", "requirement": "The system must be designed to handle 10,000 concurrent users." }
        ],
        "systemArchitecture": {
          "overview": "Mô tả kiến trúc hệ thống được đề xuất (ví dụ: Microservices, Layered Architecture) và lý do lựa chọn.",
          "diagramDescription": "Mô tả bằng lời về sơ đồ kiến trúc, bao gồm các thành phần chính (Mobile App, Backend, Database, 3rd-party services) và luồng dữ liệu chính.",
          "components": [
            { "name": "Mobile App (Flutter)", "description": "Vai trò, trách nhiệm và các thư viện chính." },
            { "name": "Backend API (e.g., Node.js/Express)", "description": "Vai trò, trách nhiệm và logic xử lý chính." },
            { "name": "Database (e.g., PostgreSQL/Firestore)", "description": "Lựa chọn cơ sở dữ liệu và lý do." }
          ]
        },
        "databaseSchema": [
          { 
            "tableName": "users", 
            "columns": [ 
              { "name": "id", "type": "UUID", "isPrimary": true, "description": "Primary key for user" }, 
              { "name": "email", "type": "VARCHAR(255)", "isUnique": true, "description": "User's email, used for login" },
              { "name": "password_hash", "type": "VARCHAR(255)", "description": "Hashed user password" }
            ],
            "relations": "One-to-many with 'projects' table."
          }
        ],
        "apiEndpoints": [
          { 
            "method": "POST", 
            "path": "/api/v1/auth/register", 
            "description": "Endpoint to register a new user.", 
            "requestBody": { "example": { "email": "user@example.com", "password": "password123" } }, 
            "responseSuccess": { "statusCode": 201, "example": { "userId": "uuid-goes-here", "token": "jwt-token-goes-here" } } 
          }
        ],
        "projectRoadmap": [
          { "phase": "Phase 1 - MVP (1-2 months)", "goals": ["Validate core idea", "Gather initial user feedback"], "keyFeatures": ["User registration", "Core feature A", "Core feature B"] },
          { "phase": "Phase 2 - Public Beta (3-4 months)", "goals": ["Grow user base", "Improve performance"], "keyFeatures": ["New feature C", "Integration with X", "Admin dashboard"] }
        ]
      }
      """;

      // 2. Prepare Request Body with a powerful model
      final requestBody = {
        "model": "anthropic/claude-3.5-sonnet-20240620",
        "messages": [
          {"role": "user", "content": detailedPrompt},
        ],
        "max_tokens": 4096,
        "temperature":
            0.5, // Lower temperature for more factual, professional output
        "top_p": 1,
        "response_format": {"type": "json_object"},
        "frequency_penalty": 0,
        "presence_penalty": 0,
      };

      AppLogger.d("Sending ADVANCED documentation request to OpenRouter...");

      // 3. Make API Call
      final response = await _dio.post('/chat/completions', data: requestBody);

      AppLogger.d(
        "OpenRouter documentation response status: ${response.statusCode}",
      );

      // 4. Handle Successful Response
      if (response.statusCode == 200) {
        final responseData = response.data;
        final String aiContent =
            responseData['choices'][0]['message']['content'];

        AppLogger.d("AI documentation content length: ${aiContent.length}");

        // 5. Parse JSON directly, with robust error handling
        try {
          final documentData = json.decode(aiContent) as Map<String, dynamic>;
          AppLogger.d("Successfully parsed AI documentation JSON");
          return Success(documentData);
        } on FormatException catch (e) {
          AppLogger.e("AI returned invalid JSON despite JSON_MODE: $e");
          AppLogger.e("Raw content from AI: $aiContent");
          return Failure(
            ApiError.parsing(
              message: "AI đã trả về dữ liệu không đúng định dạng JSON.",
              technicalDetails:
                  "FormatException: ${e.message}\nRaw Content: $aiContent",
            ),
          );
        }
      } else {
        // Handle server-side errors
        AppLogger.e(
          "OpenRouter documentation API error: ${response.statusCode} - ${response.data}",
        );
        return Failure(
          ApiError.server(
            message: "Lỗi từ OpenRouter API: ${response.statusMessage}",
            statusCode: response.statusCode ?? 500,
            technicalDetails: "Response data: ${response.data}",
          ),
        );
      }
    } on DioException catch (e) {
      // 6. Handle Network and Specific HTTP Errors
      AppLogger.e("DioException in OpenRouter documentation API: ${e.message}");
      if (e.response?.statusCode == 402) {
        return Failure(
          ApiError.server(
            message:
                "💰 Credits không đủ. Vui lòng nâng cấp tài khoản để sử dụng tính năng này.",
            statusCode: 402,
            technicalDetails: "OpenRouter 402 error: ${e.response?.data}",
          ),
        );
      }
      return Failure(ApiError.fromDioException(e));
    } catch (e) {
      // 7. Handle Any Other Unexpected Errors
      AppLogger.e("Unexpected error in OpenRouter documentation API: $e");
      return Failure(
        ApiError.server(
          message: "Lỗi không xác định trong quá trình tạo tài liệu",
          statusCode: 500,
          technicalDetails: e.toString(),
        ),
      );
    }
  }

  /// Call OpenRouter API to create a project dashboard from prompt
  Future<ApiResponse<ProjectDashboardModel>> createProjectDashboard(String prompt) async {
    try {
      final response = await _dio.post(
        '/v1/dashboard',
        data: jsonEncode({'prompt': prompt}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        final dashboard = ProjectDashboardModel.fromJson(data);
        return Success(dashboard);
      } else {
        return Failure(ApiError(message: 'Lỗi API: ${response.statusCode}'));
      }
    } catch (e) {
      return Failure(ApiError(message: e.toString()));
    }
  }
}
