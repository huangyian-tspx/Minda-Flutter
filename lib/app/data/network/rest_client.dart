import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/config/app_configs.dart';
import '../models/project_detail_model.dart';
import '../models/topic_suggestion_model.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: AppConfigs.baseUrl)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // API endpoint để generate topics
  @POST('/generate-topics')
  Future<TopicSuggestionModel> generateTopics(
    @Body() Map<String, dynamic> body,
  );

  @GET('/projects/{id}')
  Future<ProjectDetailModel> getProjectDetail(@Path('id') String projectId);

  // API endpoint để search topics
  @GET('/topics/search')
  Future<TopicSuggestionModel> searchTopics(
    @Queries() Map<String, dynamic> queries,
  );
}
