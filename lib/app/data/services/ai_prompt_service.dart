import '../../core/utils/app_logger.dart';
import '../models/user_input_data.dart';
import '../models/topic_suggestion_model.dart';

/// Service chuyên tạo prompt tối ưu cho AI từ dữ liệu người dùng
class AIPromptService {
  static AIPromptService? _instance;
  
  static AIPromptService get instance {
    _instance ??= AIPromptService._();
    return _instance!;
  }
  
  AIPromptService._();

  /// Tạo prompt siêu tối ưu từ dữ liệu người dùng
  String generateProjectSuggestionPrompt(UserInputData userData) {
    AppLogger.d("Generating AI prompt from user data: ${userData.toString()}");
    
    final prompt = """
AI tạo 4 dự án cho sinh viên VN (2 safe + 2 challenge):

**DATA:** ${userData.level}, ${userData.interests.take(2).join(',')}, ${userData.technologies.take(2).join(',')}, ${userData.projectDurationInMonths}m

**JSON:**
{
  "safeProjects": [
    {"id": "safe_1", "title": "Tên", "description": "Mô tả", "technologies": [{"name": "Tech", "description": "Info"}], "matchScore": 85, "duration": 3, "difficulty": "An toàn", "feasibilityAssessment": "Dễ"},
    {"id": "safe_2", "title": "Tên", "description": "Mô tả", "technologies": [{"name": "Tech", "description": "Info"}], "matchScore": 88, "duration": 3, "difficulty": "An toàn", "feasibilityAssessment": "Dễ"}
  ],
  "challengingProjects": [
    {"id": "challenge_1", "title": "Tên", "description": "Mô tả", "technologies": [{"name": "Tech", "description": "Info"}], "matchScore": 75, "duration": 4, "difficulty": "Thử thách", "feasibilityAssessment": "Khó"},
    {"id": "challenge_2", "title": "Tên", "description": "Mô tả", "technologies": [{"name": "Tech", "description": "Info"}], "matchScore": 78, "duration": 4, "difficulty": "Thử thách", "feasibilityAssessment": "Khó"}
  ]
}

**RULES:** title≤40chars, description≤80chars, 1-2 techs, match level, JSON only.""";
    
    AppLogger.d("Generated ultra-compact prompt length: ${prompt.length}");
    return prompt;
  }

  /// Tạo prompt để lấy thông tin chi tiết của 1 dự án cụ thể
  /// 
  /// [userData] Dữ liệu người dùng để personalize
  /// [basicTopic] Thông tin cơ bản của topic cần detail
  String generateProjectDetailPrompt(UserInputData userData, Topic basicTopic) {
    AppLogger.d("Generating project detail prompt for: ${basicTopic.title}");
    
    final prompt = """
Detail for: ${basicTopic.title}
Level: ${userData.level}, Tech: ${userData.technologies.take(2).join(',')}, ${userData.projectDurationInMonths}m

JSON:
{
  "problemStatement": "Vấn đề (50 từ)",
  "proposedSolution": "Giải pháp (60 từ)",
  "coreFeatures": [{"title": "Feature1", "content": "Mô tả"}, {"title": "Feature2", "content": "Mô tả"}],
  "advancedFeatures": [{"title": "Advanced1", "content": "Mô tả"}],
  "foundationalKnowledge": ["Skill1", "Skill2", "Skill3"],
  "specificKnowledge": [{"title": "Tech1", "difficulty": "easy"}, {"title": "Tech2", "difficulty": "medium"}],
  "implementationSteps": ["Setup", "Code", "Test"],
  "codeExamples": [{"title": "Basic", "description": "Khởi tạo", "code": "class App extends StatelessWidget { Widget build(context) => MaterialApp(home: Text('Hello')); }", "language": "dart", "explanation": "Widget chính"}]
}

Compact, ${userData.level} level, JSON only.""";
    
    AppLogger.d("Generated compact project detail prompt length: ${prompt.length}");
    return prompt;
  }

  /// Tạo prompt để generate comprehensive project documentation cho Notion
  /// 
  /// [projectTopic] Thông tin chi tiết dự án đã có
  /// [userData] User data để personalize
  String generateProjectDocumentationPrompt(Map<String, dynamic> project) {
    return '''
Compact doc for: ${project['name']}
Features: ${project['features']}
Tech: ${project['techStack']}

JSON:
{
  "title": "${project['name']}",
  "overview": "Brief overview (2 lines)",
  "keyMetrics": "Timeline, Budget (1 line)",
  "functionalRequirements": [{"title": "Feature", "description": "Desc"}],
  "nonFunctionalRequirements": ["Security", "Performance"],
  "architecture": "System design (2 lines)",
  "frontendTech": [{"name": "Tech", "reason": "Why"}],
  "backendTech": [{"name": "Tech", "reason": "Why"}],
  "coreFeatures": [{"name": "Feature", "description": "Desc", "userStory": "As user...", "acceptanceCriteria": ["Criteria"]}],
  "database": {"tables": [{"name": "Table", "fields": [{"name": "Field", "type": "Type", "description": "Desc"}]}]},
  "apiEndpoints": [{"method": "GET", "path": "/api/path", "description": "Desc", "parameters": [{"name": "param", "type": "string", "description": "Desc"}]}],
  "milestones": [{"phase": "Phase1", "duration": "2w", "deliverables": ["Items"]}]
}

Concise JSON only.''';
  }
} 