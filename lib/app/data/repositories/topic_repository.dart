import 'package:mind_ai_app/app/data/models/api_error.dart';
import 'package:mind_ai_app/app/data/models/project_detail_model.dart';

import '../../di.dart';
import '../models/api_response.dart';
import '../models/topic_suggestion_model.dart';
import '../network/rest_client.dart';

class TopicRepository {
  final RestClient _restClient = sl<RestClient>();

  Future<ApiResponse<TopicSuggestionModel>> getTopicSuggestions(
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await _restClient.generateTopics(params);
      return Success(response);
    } on ApiError catch (e) {
      return Failure(e);
    }
  }

  Future<ApiResponse<TopicSuggestionModel>> searchTopics(
    Map<String, dynamic> queries,
  ) async {
    try {
      final response = await _restClient.searchTopics(queries);
      return Success(response);
    } on ApiError catch (e) {
      return Failure(e);
    }
  }

  Future<ApiResponse<ProjectDetailModel>> getProjectDetail(
    String projectId,
  ) async {
    try {
      final response = await _restClient.getProjectDetail(projectId);
      return Success(response);
    } on ApiError catch (e) {
      return Failure(e);
    }
  }
}
