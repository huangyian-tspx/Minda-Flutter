import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;

import '../../core/config/app_configs.dart';
import '../../core/utils/app_logger.dart';
import '../models/ai_response_model.dart';
import '../models/api_error.dart';
import '../models/api_response.dart';
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
        "max_tokens": 1800, // Reduced from 2200 to 1800 for quota compliance
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
        String userMessage = "⚡ Hệ thống đã tối ưu xuống 1800 tokens để tiết kiệm credits.";
        
        if (errorData is Map<String, dynamic>) {
          final errorInfo = errorData['error'];
          if (errorInfo is Map<String, dynamic>) {
            final message = errorInfo['message']?.toString();
            if (message != null && message.contains('credits')) {
              userMessage = "💰 Credits không đủ. Đã tối ưu tối đa để tiết kiệm. Vui lòng nâng cấp tài khoản để trải nghiệm đầy đủ.";
            } else if (message != null && message.contains('max_tokens')) {
              userMessage = "📝 Request quá lớn. Hệ thống đã giảm xuống 1800 tokens.";
            }
          }
        }
        
        return Failure(ApiError.server(
          message: userMessage,
          statusCode: 402,
          technicalDetails: "OpenRouter 402 error after token optimization: ${e.response?.data}",
          requestId: e.response?.headers.value('cf-ray'),
        ));
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

  /// Extract JSON từ AI response (remove markdown, extra text)
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
        return null;
      }

      final jsonString = cleanedResponse.substring(startIndex, lastIndex + 1);
      AppLogger.d(
        "Extracted JSON string: ${jsonString.length > 500 ? jsonString.substring(0, 500) + '...' : jsonString}",
      );

      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.e("Error parsing JSON from AI response: $e");
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
            technicalDetails: "UserDataCollectionService not registered in GetX",
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
        "max_tokens": 1200, // Reduced from 1500 to 1200 for quota compliance
        "temperature": 0.7,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
      };

      AppLogger.d("Sending project detail request to OpenRouter...");

      // Make API call
      final response = await _dio.post('/chat/completions', data: requestBody);

      AppLogger.d("OpenRouter project detail response status: ${response.statusCode}");

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
      AppLogger.e("DioException in OpenRouter project detail API: ${e.message}");
      
      // Handle specific error cases
      if (e.response?.statusCode == 402) {
        final errorData = e.response?.data;
        String userMessage = "⚡ Hệ thống đã tối ưu xuống 1200 tokens để tiết kiệm credits.";
        
        if (errorData is Map<String, dynamic>) {
          final errorInfo = errorData['error'];
          if (errorInfo is Map<String, dynamic>) {
            final message = errorInfo['message']?.toString();
            if (message != null && message.contains('credits')) {
              userMessage = "💰 Credits không đủ. Đã tối ưu tối đa để tiết kiệm. Vui lòng nâng cấp tài khoản để trải nghiệm đầy đủ.";
            } else if (message != null && message.contains('max_tokens')) {
              userMessage = "📝 Request quá lớn. Hệ thống đã giảm xuống 1200 tokens.";
            }
          }
        }
        
        return Failure(ApiError.server(
          message: userMessage,
          statusCode: 402,
          technicalDetails: "OpenRouter 402 error after token optimization: ${e.response?.data}",
          requestId: e.response?.headers.value('cf-ray'),
        ));
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
  /// 
  /// Call OpenRouter API để tạo nội dung tài liệu BA-style cho dự án
  /// 
  /// [project] Thông tin dự án dạng Map
  Future<ApiResponse<Map<String, dynamic>>> generateProjectDocumentation(
    Map<String, dynamic> project,
  ) async {
    try {
      AppLogger.d("Generating project documentation for: ${project['name']}");

      // Generate prompt
      final prompt = AIPromptService.instance.generateProjectDocumentationPrompt(project);
      AppLogger.d("Generated documentation prompt length: ${prompt.length}");

      // Prepare request body
      final requestBody = {
        "model": AppConfigs.openRouterModel,
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 1000, // Reduced from 1500 to 1000 for quota compliance
        "temperature": 0.7,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
      };

      AppLogger.d("Sending documentation request to OpenRouter...");

      // Make API call
      final response = await _dio.post('/chat/completions', data: requestBody);

      AppLogger.d("OpenRouter documentation response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = response.data;
        final aiContent = responseData['choices'][0]['message']['content'];

        AppLogger.d("AI documentation content length: ${aiContent.length}");
        AppLogger.d(
          "AI documentation preview: ${aiContent.length > 200 ? aiContent.substring(0, 200) + '...' : aiContent}",
        );

        // Parse JSON from AI response
        final documentData = _extractJsonFromAIResponse(aiContent);
        if (documentData == null) {
          AppLogger.e("Failed to extract JSON from AI documentation response");
          return Failure(
            ApiError.parsing(
              message: "AI response không đúng định dạng JSON",
              technicalDetails: "Failed to extract valid JSON from AI documentation response",
            ),
          );
        }

        AppLogger.d("Successfully parsed AI documentation");
        
        return Success(documentData);
      } else {
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
      AppLogger.e("DioException in OpenRouter documentation API: ${e.message}");
      
      // Handle specific error cases
      if (e.response?.statusCode == 402) {
        final errorData = e.response?.data;
        String userMessage = "📄 Đã tối ưa documentation xuống 1000 tokens để tiết kiệm credits.";
        
        if (errorData is Map<String, dynamic>) {
          final errorInfo = errorData['error'];
          if (errorInfo is Map<String, dynamic>) {
            final message = errorInfo['message']?.toString();
            if (message != null && message.contains('credits')) {
              userMessage = "💰 Credits không đủ cho documentation. Đã tối ưu tối đa. Vui lòng nâng cấp tài khoản.";
            } else if (message != null && message.contains('max_tokens')) {
              userMessage = "📝 Document quá lớn. Hệ thống đã giảm xuống 1000 tokens.";
            }
          }
        }
        
        return Failure(ApiError.server(
          message: userMessage,
          statusCode: 402,
          technicalDetails: "OpenRouter 402 error for documentation: ${e.response?.data}",
          requestId: e.response?.headers.value('cf-ray'),
        ));
      }
      
      return Failure(ApiError.fromDioException(e));
    } catch (e) {
      AppLogger.e("Unexpected error in OpenRouter documentation API: $e");
      return Failure(
        ApiError.server(
          message: "Lỗi không xác định trong quá trình tạo documentation",
          statusCode: 500,
          technicalDetails: e.toString(),
        ),
      );
    }
  }
}
