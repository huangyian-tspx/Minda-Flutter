import 'package:get/get.dart';

import '../models/api_response.dart';
import '../services/openrouter_api_service.dart';

class AIService extends GetxService {
  final _openRouterService = Get.find<OpenRouterAPIService>();

  /// Generate project documentation using AI
  Future<Map<String, dynamic>?> generateProjectDocumentation(
    Map<String, dynamic> project,
  ) async {
    try {
      final response = await _openRouterService.generateProjectDocumentation(
        project,
      );

      if (response is Success<Map<String, dynamic>>) {
        return response.data;
      } else if (response is Failure<Map<String, dynamic>>) {
        throw Exception(response.error.message);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
