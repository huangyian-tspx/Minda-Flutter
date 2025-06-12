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
    AppLogger.d(
      "Generating enhanced AI prompt from user data: ${userData.toString()}",
    );

    // Build team context based on team size
    String teamContext = _buildTeamContext(userData.teamSize);

    // Build detailed user profile
    String userProfile = _buildUserProfile(userData);

    // Build enhanced constraints
    String constraints = _buildConstraints(userData);

    final prompt =
        '''
Bạn là chuyên gia tư vấn dự án công nghệ cho sinh viên Việt Nam. Tạo 4 dự án chi tiết (2 an toàn + 2 thử thách) phù hợp với profile sau:

**PROFILE NGƯỜI DÙNG:**
$userProfile

**BỐI CẢNH NHÓM:**
$teamContext

**YÂU CẦU KỸ THUẬT:**
$constraints

**ĐIỀU KIỆN ĐÁNH GIÁ:**
- Độ phù hợp với level và tech stack
- Tính khả thi trong thời gian ${userData.projectDurationInMonths.toInt()} tháng  
- Phù hợp với ${userData.teamSize} thành viên
- Giải quyết vấn đề thực tế
- Có tiềm năng portfolio/học tập

**OUTPUT FORMAT (JSON):**
{
  "safeProjects": [
    {
      "id": "safe_1", 
      "title": "Tên dự án cụ thể (≤50 chars)",
      "description": "Mô tả ngắn gọn giá trị cốt lõi (≤100 chars)", 
      "technologies": [
        {"name": "Tech1", "description": "Lý do chọn và ứng dụng cụ thể"},
        {"name": "Tech2", "description": "Vai trò trong dự án"}
      ],
      "matchScore": 88, 
      "duration": ${userData.projectDurationInMonths.toInt()}, 
      "difficulty": "An toàn",
      "feasibilityAssessment": "Đánh giá khả thi chi tiết với team ${userData.teamSize} người"
    },
    // safe_2 tương tự
  ],
  "challengingProjects": [
    {
      "id": "challenge_1",
      "title": "Tên dự án đầy thách thức (≤50 chars)", 
      "description": "Mô tả vấn đề phức tạp sẽ giải quyết (≤100 chars)",
      "technologies": [
        {"name": "Tech1", "description": "Công nghệ nâng cao và thách thức kỹ thuật"},
        {"name": "Tech2", "description": "Kỹ năng mới cần học"}
      ],
      "matchScore": 75,
      "duration": ${(userData.projectDurationInMonths + 1).toInt()}, 
      "difficulty": "Thử thách",
      "feasibilityAssessment": "Thách thức và cơ hội học hỏi cho team ${userData.teamSize} người"
    },
    // challenge_2 tương tự  
  ]
}

**YÊU CẦU CHẤT LƯỢNG:**
- Dự án PHẢI liên quan đến sở thích: ${userData.interests.take(3).join(', ')}
- Sử dụng tech stack: ${userData.technologies.take(3).join(', ')}
- Phù hợp với team size ${userData.teamSize} và duration ${userData.projectDurationInMonths.toInt()}m
- Title phải unique và catchy
- Description phải nêu rõ value proposition
- Technologies phải practical và có lý do cụ thể
- MatchScore realistic dựa trên độ phù hợp thực tế

CHỈ TRẢ VỀ JSON OBJECT, KHÔNG THÊM TEXT NÀO KHÁC.''';

    AppLogger.d(
      "Generated enhanced prompt length: ${prompt.length} characters",
    );
    return prompt;
  }

  /// Build team context based on team size
  String _buildTeamContext(int teamSize) {
    if (teamSize == 1) {
      return '''
• Dự án solo - cần tối ưu hóa thời gian và effort
• Tập trung vào MVP và core features  
• Ưu tiên tools/frameworks giảm thiểu boilerplate
• Có thể outsource một số thành phần phức tạp''';
    } else if (teamSize <= 4) {
      return '''
• Team nhỏ ${teamSize} người - cần phân chia role rõ ràng
• Có thể tackle các feature phức tạp hơn
• Cần setup collaboration workflow (Git, project management)
• Khuyến khích micro-services hoặc modular architecture
• Có thể thử nghiệm technologies mới''';
    } else {
      return '''
• Team lớn ${teamSize} người - cần project management chặt chẽ  
• Có thể develop full-scale applications
• Cần architecture có thể scale và multiple developers
• Áp dụng best practices: CI/CD, testing, documentation
• Có thể include DevOps và advanced deployment''';
    }
  }

  /// Build detailed user profile
  String _buildUserProfile(UserInputData userData) {
    return '''
• Level: ${userData.level}
• Sở thích: ${userData.interests.join(', ')}
• Mục tiêu: ${userData.mainGoal}
• Tech stack muốn dùng: ${userData.technologies.join(', ')}
• Loại sản phẩm: ${userData.productTypes.join(', ')}
• Thời gian: ${userData.projectDurationInMonths.toInt()} tháng
• Team size: ${userData.teamSize} thành viên''';
  }

  /// Build technical constraints
  String _buildConstraints(UserInputData userData) {
    String constraints =
        '''
• Phải sử dụng ít nhất 2-3 tech từ: ${userData.technologies.take(4).join(', ')}
• Phù hợp với loại sản phẩm: ${userData.productTypes.take(3).join(', ')}
• Timeline thực tế: ${userData.projectDurationInMonths.toInt()} tháng''';

    if (userData.specialRequirements != null &&
        userData.specialRequirements!.isNotEmpty) {
      constraints += '\n• Yêu cầu đặc biệt: ${userData.specialRequirements}';
    }

    if (userData.problemToSolve != null &&
        userData.problemToSolve!.isNotEmpty) {
      constraints += '\n• Vấn đề cần giải quyết: ${userData.problemToSolve}';
    }

    return constraints;
  }

  /// Tạo prompt để lấy thông tin chi tiết của 1 dự án cụ thể
  ///
  /// [userData] Dữ liệu người dùng để personalize
  /// [basicTopic] Thông tin cơ bản của topic cần detail
  String generateProjectDetailPrompt(UserInputData userData, Topic basicTopic) {
    AppLogger.d(
      "Generating enhanced project detail prompt for: ${basicTopic.title}",
    );

    // Build team-specific guidance
    String teamGuidance = _buildTeamSpecificGuidance(userData.teamSize);

    // Build skill level context
    String skillContext = _buildSkillLevelContext(userData.level);

    final prompt =
        '''
Bạn là senior software architect. Tạo hướng dẫn CHI TIẾT cho dự án "${basicTopic.title}" phù hợp với:

**BỐI CẢNH DỰ ÁN:**
• Title: ${basicTopic.title}
• Description: ${basicTopic.description}  
• Team size: ${userData.teamSize} thành viên
• Level: ${userData.level}
• Duration: ${userData.projectDurationInMonths.toInt()} tháng
• Tech stack: ${userData.technologies.take(3).join(', ')}

**HƯỚNG DẪN THEO TEAM:**
$teamGuidance

**ĐIỀU CHỈNH THEO SKILL:**
$skillContext

**YÊU CẦU OUTPUT (JSON):**
{
  "problemStatement": "Phân tích vấn đề cụ thể và tại sao cần giải quyết (100-150 từ)",
  "proposedSolution": "Giải pháp kỹ thuật chi tiết và approach (100-150 từ)",
  "coreFeatures": [
    {"title": "Feature chính 1", "content": "Mô tả chi tiết implementation và business value"},
    {"title": "Feature chính 2", "content": "Chi tiết kỹ thuật và user experience"},
    {"title": "Feature chính 3", "content": "Functionality và technical considerations"}
  ],
  "advancedFeatures": [
    {"title": "Advanced feature 1", "content": "Tính năng nâng cao với challenge kỹ thuật"},
    {"title": "Advanced feature 2", "content": "Optimization và scalability features"}
  ],
  "foundationalKnowledge": [
    "Kiến thức nền tảng 1 cần có",
    "Kiến thức nền tảng 2", 
    "Kiến thức nền tảng 3",
    "Kiến thức nền tảng 4"
  ],
  "specificKnowledge": [
    {"title": "Công nghệ cụ thể 1", "difficulty": "easy"},
    {"title": "Framework/Library cần học", "difficulty": "medium"}, 
    {"title": "Advanced concept", "difficulty": "hard"}
  ],
  "implementationSteps": [
    "Phase 1: Setup và architecture design (tuần 1-2)",
    "Phase 2: Core features development (tuần 3-6)", 
    "Phase 3: Advanced features và integration (tuần 7-10)",
    "Phase 4: Testing, optimization và deployment (tuần 11-12)",
    "Phase 5: Documentation và presentation prep"
  ],
  "codeExamples": [
    {
      "title": "Project Setup & Architecture",
      "description": "Cấu trúc dự án và setup ban đầu",
      "code": "// Code setup cơ bản với imports và structure\\n// Bao gồm dependency injection, routing, state management\\nclass AppModule {\\n  static void configureApp() {\\n    // Setup code here\\n  }\\n}",
      "language": "dart",
      "explanation": "Explanation về architecture pattern và lý do chọn approach này cho team ${userData.teamSize} người"
    },
    {
      "title": "Core Feature Implementation", 
      "description": "Implementation của tính năng chính",
      "code": "// Implementation chi tiết của core feature\\n// Bao gồm business logic, error handling, validation\\nclass CoreFeatureService {\\n  Future<Result> processData(Input data) async {\\n    // Core logic implementation\\n    return Result.success(processedData);\\n  }\\n}",
      "language": "dart", 
      "explanation": "Chi tiết về business logic và best practices cho level ${userData.level}"
    },
    {
      "title": "Advanced Integration Example",
      "description": "Tích hợp với external services hoặc advanced features", 
      "code": "// Advanced implementation với external APIs\\n// Error handling, caching, optimization\\nclass AdvancedIntegration {\\n  static const String API_KEY = 'your_api_key';\\n  \\n  Future<ApiResponse> callExternalService() async {\\n    // Implementation with proper error handling\\n  }\\n}",
      "language": "dart",
      "explanation": "Hướng dẫn integrate với external services và handle edge cases"
    }
  ]
}

**YÊU CẦU CHẤT LƯỢNG:**
- Problem statement phải cụ thể và actionable
- Solution approach phải technical và detailed  
- Features phải có business value rõ ràng
- Code examples phải runnable và có comment chi tiết
- Implementation steps phải realistic cho ${userData.projectDurationInMonths.toInt()} tháng
- Knowledge requirements phải phù hợp với level ${userData.level}
- Tất cả phải customized cho team ${userData.teamSize} người

CHỈ TRẢ VỀ JSON, KHÔNG COMMENT THÊM.''';

    AppLogger.d(
      "Generated enhanced project detail prompt length: ${prompt.length} characters",
    );
    return prompt;
  }

  /// Build team-specific guidance
  String _buildTeamSpecificGuidance(int teamSize) {
    if (teamSize == 1) {
      return '''
• Focus vào MVP với core features essential
• Prioritize frameworks giảm boilerplate code
• Suggest tools automation để save time
• Include pre-built solutions cho complex parts''';
    } else if (teamSize <= 4) {
      return '''
• Chia features theo skillset của từng member
• Include collaboration workflow setup
• Suggest micro-services hoặc modular design
• Add integration points giữa các modules
• Include code review và testing practices''';
    } else {
      return '''
• Architecture cho multiple developers
• Include project management practices
• Suggest advanced deployment và CI/CD
• Add monitoring và logging requirements
• Include documentation standards''';
    }
  }

  /// Build skill level context
  String _buildSkillLevelContext(String? level) {
    switch (level?.toLowerCase()) {
      case 'năm 1-2':
        return '''
• Explanation chi tiết về concepts cơ bản
• Step-by-step instructions rất rõ ràng
• Include learning resources cho each step
• Avoid quá nhiều advanced patterns''';
      case 'năm 3':
        return '''
• Balance giữa guidance và independent thinking
• Include some advanced concepts để học
• Explain design patterns một cách practical
• Encourage best practices''';
      case 'năm cuối':
      case 'fresher':
        return '''
• Focus vào industry best practices
• Include advanced architecture patterns
• Emphasize code quality và maintainability
• Add performance considerations''';
      default:
        return '''
• Detailed explanations với practical examples
• Include learning opportunities
• Balance challenge với achievability''';
    }
  }

  /// Tạo prompt để generate comprehensive project documentation cho Notion
  ///
  /// [projectTopic] Thông tin chi tiết dự án đã có
  /// [userData] User data để personalize
  String generateProjectDocumentationPrompt(Map<String, dynamic> project) {
    return '''
Bạn là Technical Writer chuyên nghiệp. Tạo tài liệu dự án TOÀN DIỆN cho "${project['name']}" theo chuẩn enterprise.

**QUAN TRỌNG: CHỈ TRẢ VỀ JSON HỢP LỆ, KHÔNG THÊM TEXT, KHÔNG GIẢI THÍCH, KHÔNG COMMENT.**

**THÔNG TIN DỰ ÁN:**
• Name: ${project['name']}
• Features: ${project['features']}
• Tech Stack: ${project['techStack']}
• Code Examples: ${project['codeExamples']?.length ?? 0} examples

**YÊU CẦU DOCUMENTATION (JSON FORMAT):**
{
  "title": "${project['name']} - Technical Documentation",
  "projectOverview": {
    "description": "Mô tả chi tiết dự án, mục tiêu và value proposition (200-300 từ)",
    "problemStatement": "Vấn đề cụ thể mà dự án giải quyết",
    "targetAudience": "Đối tượng người dùng chính",
    "businessValue": "Giá trị kinh doanh và impact measurement"
  },
  "technicalSpecification": {
    "architecture": {
      "overview": "Kiến trúc tổng quan của hệ thống",
      "designPatterns": ["Pattern 1", "Pattern 2", "Pattern 3"],
      "scalabilityConsiderations": "Các yếu tố về khả năng mở rộng"
    },
    "techStack": {
      "frontend": [{"name": "Technology", "version": "x.x.x", "purpose": "Mục đích sử dụng"}],
      "backend": [{"name": "Technology", "version": "x.x.x", "purpose": "Mục đích sử dụng"}],
      "database": [{"name": "Database", "purpose": "Lý do chọn"}],
      "devOps": [{"name": "Tool", "purpose": "Automation purpose"}]
    }
  },
  "functionalRequirements": [
    {
      "featureId": "F001",
      "title": "Feature Name",
      "description": "Chi tiết tính năng",
      "userStories": [
        "As a [user type], I want [goal] so that [benefit]"
      ],
      "acceptanceCriteria": [
        "Given [context], when [action], then [outcome]"
      ],
      "priority": "High/Medium/Low",
      "complexity": "Simple/Medium/Complex"
    }
  ],
  "nonFunctionalRequirements": {
    "performance": {
      "responseTime": "< 2 seconds for 95% of requests",
      "throughput": "1000 concurrent users",
      "scalability": "Horizontal scaling capability"
    },
    "security": {
      "authentication": "JWT-based authentication",
      "authorization": "Role-based access control",
      "dataProtection": "AES-256 encryption"
    },
    "reliability": {
      "availability": "99.9% uptime",
      "errorRate": "< 0.1% error rate",
      "backupStrategy": "Daily automated backups"
    }
  },
  "databaseDesign": {
    "schema": [
      {
        "tableName": "users",
        "fields": [
          {"name": "id", "type": "UUID", "constraints": "PRIMARY KEY", "description": "Unique identifier"},
          {"name": "email", "type": "VARCHAR(255)", "constraints": "UNIQUE NOT NULL", "description": "User email address"}
        ],
        "relationships": [
          {"type": "hasMany", "target": "projects", "foreignKey": "user_id"}
        ]
      }
    ],
    "indexes": [
      {"table": "users", "columns": ["email"], "type": "UNIQUE"},
      {"table": "projects", "columns": ["user_id", "created_at"], "type": "COMPOSITE"}
    ]
  },
  "apiDocumentation": {
    "baseUrl": "https://api.example.com/v1",
    "authentication": "Bearer token required",
    "endpoints": [
      {
        "method": "GET",
        "path": "/users/{id}",
        "description": "Retrieve user information",
        "parameters": [
          {"name": "id", "type": "string", "required": true, "description": "User UUID"}
        ],
        "responses": {
          "200": {"description": "Success", "schema": "User object"},
          "404": {"description": "User not found"},
          "401": {"description": "Unauthorized"}
        },
        "example": {
          "request": "GET /users/123e4567-e89b-12d3-a456-426614174000",
          "response": {"id": "123e4567-e89b-12d3-a456-426614174000", "email": "user@example.com"}
        }
      }
    ]
  }
}

**LƯU Ý:**
1. CHỈ TRẢ VỀ JSON HỢP LỆ, KHÔNG THÊM TEXT
2. ĐẢM BẢO TẤT CẢ CÁC KEY ĐỀU CÓ DẤU NHÁY KÉP
3. ĐẢM BẢO SỐ LƯỢNG DẤU NGOẶC NHỌN MỞ VÀ ĐÓNG BẰNG NHAU
4. KHÔNG THÊM COMMENTS HOẶC GIẢI THÍCH
5. KHÔNG THÊM MARKDOWN FORMATTING
''';
  }
}
