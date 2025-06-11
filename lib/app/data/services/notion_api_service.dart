import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/config/app_configs.dart';
import '../../core/utils/app_logger.dart';
import '../models/api_error.dart';
import '../models/api_response.dart';

/// Service xử lý tất cả API calls đến Notion
///
/// Handles page creation, formatting, và error handling
class NotionAPIService {
  static NotionAPIService? _instance;
  late Dio _dio;

  static NotionAPIService get instance {
    _instance ??= NotionAPIService._();
    return _instance!;
  }

  NotionAPIService._() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.notion.com/v1',
        connectTimeout: AppConfigs.connectTimeout,
        receiveTimeout: AppConfigs.receiveTimeout,
        headers: {
          'Authorization': 'Bearer ${AppConfigs.apiKeyNotion}',
          'Notion-Version': '2022-06-28',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => AppLogger.d('[NOTION] ${object.toString()}'),
      ),
    );
  }

  /// Create a new page trong Notion database với professional formatting
  ///
  /// [title] Tiêu đề của document
  /// [content] Nội dung đã được structure từ AI
  /// Returns: Notion page URL hoặc error
  Future<ApiResponse<String>> createProjectDocument({
    required String title,
    required Map<String, dynamic> content,
  }) async {
    try {
      AppLogger.d("Creating Notion document for: $title");

      // Format content thành Notion blocks
      final blocks = _formatContentToNotionBlocks(content);

      // Prepare request body cho Notion API
      final requestBody = {
        "parent": {"type": "database_id", "database_id": AppConfigs.dbIDNotion},
        "properties": {
          "Name": {
            "title": [
              {
                "text": {"content": title},
              },
            ],
          },
        },
        "children": blocks,
      };

      AppLogger.d("Sending request to Notion API...");

      // Make API call
      final response = await _dio.post('/pages', data: requestBody);

      AppLogger.d("Notion response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final pageId = response.data['id'] as String;
        final pageUrl = response.data['url'] as String;
        
        AppLogger.d("Successfully created Notion page: $pageUrl");
        
        return Success(pageUrl);
      } else {
        AppLogger.e("Notion API error: ${response.statusCode} - ${response.data}");
        return Failure(
          ApiError.server(
            message: "Lỗi từ Notion API: ${response.statusMessage}",
            statusCode: response.statusCode ?? 500,
            technicalDetails: "Response data: ${response.data}",
          ),
        );
      }
    } on DioException catch (e) {
      AppLogger.e("DioException in Notion API: ${e.message}");
      AppLogger.e("Response data: ${e.response?.data}");
      
      // Handle specific Notion errors
      if (e.response?.statusCode == 401) {
        return Failure(
          ApiError.parsing(
            message: "Notion API key không hợp lệ. Vui lòng kiểm tra lại.",
            technicalDetails: "Invalid Notion API key",
          ),
        );
      }
      
      if (e.response?.statusCode == 404) {
        return Failure(
          ApiError.parsing(
            message:
                "Database Notion không tồn tại. Vui lòng kiểm tra Database ID.",
            technicalDetails: "Database ID: ${AppConfigs.dbIDNotion}",
          ),
        );
      }

      if (e.response?.statusCode == 400) {
        return Failure(
          ApiError.parsing(
            message: "Dữ liệu request không hợp lệ. Kiểm tra database schema.",
            technicalDetails: "Notion 400 error: ${e.response?.data}",
          ),
        );
      }
      
      return Failure(ApiError.fromDioException(e));
    } catch (e) {
      AppLogger.e("Unexpected error in Notion API: $e");
      return Failure(
        ApiError.server(
          message: "Lỗi không xác định khi tạo Notion document",
          statusCode: 500,
          technicalDetails: e.toString(),
        ),
      );
    }
  }

  /// Format content từ AI response thành Notion blocks (NO EMOJIS)
  /// 
  /// Converts structured data thành Notion block format
  List<Map<String, dynamic>> _formatContentToNotionBlocks(
    Map<String, dynamic> content,
  ) {
    final blocks = <Map<String, dynamic>>[];

    try {
      // Header
      blocks.add(_createHeading1Block(content['title'] ?? 'Project Documentation'));

      // Table of Contents
      blocks.add(_createHeading2Block("Muc Luc"));
      blocks.add(_createBulletedListBlock("1. Tong quan du an"));
      blocks.add(_createBulletedListBlock("2. Phan tich yeu cau"));
      blocks.add(_createBulletedListBlock("3. Kien truc he thong"));
      blocks.add(_createBulletedListBlock("4. Cong nghe su dung"));
      blocks.add(_createBulletedListBlock("5. Tinh nang chinh"));
      blocks.add(_createBulletedListBlock("6. Database Design"));
      blocks.add(_createBulletedListBlock("7. API Documentation"));
      blocks.add(_createBulletedListBlock("8. Ke hoach trien khai"));
      
      blocks.add(_createDividerBlock());

      // 1. Project Overview
      blocks.add(_createHeading2Block("1. Tong Quan Du An"));
      blocks.add(_createParagraphBlock(content['overview'] ?? ''));
      
      // Key metrics
      if (content['keyMetrics'] != null) {
        blocks.add(_createParagraphBlock("Key Metrics: ${content['keyMetrics']}"));
      }
      
      blocks.add(_createDividerBlock());

      // 2. Requirements Analysis
      blocks.add(_createHeading2Block("2. Phan Tich Yeu Cau"));
      
      // Functional Requirements
      blocks.add(_createHeading3Block("2.1 Yeu Cau Chuc Nang"));
      if (content['functionalRequirements'] is List) {
        for (final req in content['functionalRequirements']) {
          blocks.add(_createToggleBlock(
            req['title'] ?? '',
            req['description'] ?? '',
          ));
        }
      }

      // Non-functional Requirements
      blocks.add(_createHeading3Block("2.2 Yeu Cau Phi Chuc Nang"));
      if (content['nonFunctionalRequirements'] is List) {
        for (final req in content['nonFunctionalRequirements']) {
          blocks.add(_createNumberedListBlock(req.toString()));
        }
      }
      
      blocks.add(_createDividerBlock());

      // 3. System Architecture
      blocks.add(_createHeading2Block("3. Kien Truc He Thong"));
      blocks.add(_createParagraphBlock(content['architecture'] ?? ''));
      
      blocks.add(_createDividerBlock());

      // 4. Tech Stack
      blocks.add(_createHeading2Block("4. Cong Nghe Su Dung"));
      
      // Frontend Technologies
      blocks.add(_createHeading3Block("Frontend"));
      if (content['frontendTech'] is List) {
        for (final tech in content['frontendTech']) {
          blocks.add(_createBulletedListBlock("${tech['name']}: ${tech['reason']}"));
        }
      }

      // Backend Technologies
      blocks.add(_createHeading3Block("Backend"));
      if (content['backendTech'] is List) {
        for (final tech in content['backendTech']) {
          blocks.add(_createBulletedListBlock("${tech['name']}: ${tech['reason']}"));
        }
      }
      
      blocks.add(_createDividerBlock());

      // 5. Core Features
      blocks.add(_createHeading2Block("5. Tinh Nang Chinh"));
      
      if (content['coreFeatures'] is List) {
        int index = 1;
        for (final feature in content['coreFeatures']) {
          blocks.add(_createHeading3Block("5.${index}. ${feature['name']}"));
          blocks.add(_createParagraphBlock(feature['description'] ?? ''));
          
          // User story
          if (feature['userStory'] != null) {
            blocks.add(_createParagraphBlock("User Story: ${feature['userStory']}"));
          }
          
          // Acceptance criteria
          if (feature['acceptanceCriteria'] is List) {
            blocks.add(_createParagraphBlock("Acceptance Criteria:"));
            for (final criteria in feature['acceptanceCriteria']) {
              blocks.add(_createCheckboxBlock(criteria, false));
            }
          }
          
          index++;
        }
      }
      
      blocks.add(_createDividerBlock());

      // 6. Database Design
      blocks.add(_createHeading2Block("6. Database Design"));
      
      if (content['database'] != null && content['database']['tables'] is List) {
        for (final table in content['database']['tables']) {
          blocks.add(_createHeading3Block(table['name'] ?? ''));
          if (table['fields'] is List) {
            for (final field in table['fields']) {
              blocks.add(_createBulletedListBlock(
                "${field['name']} (${field['type']}): ${field['description'] ?? ''}"
              ));
            }
          }
        }
      }
      
      blocks.add(_createDividerBlock());

      // 7. API Documentation
      blocks.add(_createHeading2Block("7. API Documentation"));
      
      if (content['apiEndpoints'] is List) {
        for (final endpoint in content['apiEndpoints']) {
          blocks.add(_createToggleBlock(
            "${endpoint['method']} ${endpoint['path']}",
            _formatApiEndpoint(endpoint),
          ));
        }
      }
      
      blocks.add(_createDividerBlock());

      // 8. Implementation Plan
      blocks.add(_createHeading2Block("8. Ke Hoach Trien Khai"));
      
      if (content['milestones'] is List) {
        for (final milestone in content['milestones']) {
          blocks.add(_createHeading3Block("${milestone['phase']}"));
          blocks.add(_createParagraphBlock("Thoi gian: ${milestone['duration']}"));
          blocks.add(_createParagraphBlock("Deliverables:"));
          
          if (milestone['deliverables'] is List) {
            for (final deliverable in milestone['deliverables']) {
              blocks.add(_createCheckboxBlock(deliverable, false));
            }
          }
        }
      }
      
      blocks.add(_createDividerBlock());

      // Footer với metadata
      blocks.add(_createQuoteBlock(
        "Document duoc tao tu dong boi Mind AI App - ${DateTime.now().toLocal()}",
      ));

    } catch (e) {
      AppLogger.e("Error formatting Notion blocks: $e");
      // Return basic blocks nếu có lỗi
      blocks.clear();
      blocks.add(_createHeading1Block("Project Documentation"));
      blocks.add(_createParagraphBlock("Error formatting content. Please check data structure."));
    }

    return blocks;
  }

  /// Format API endpoint details
  String _formatApiEndpoint(Map<String, dynamic> endpoint) {
    final buffer = StringBuffer();

    buffer.writeln("**Description:** ${endpoint['description'] ?? 'N/A'}");
    buffer.writeln();

    if (endpoint['parameters'] != null) {
      buffer.writeln("**Parameters:**");
      for (final param in endpoint['parameters']) {
        buffer.writeln(
          "- `${param['name']}` (${param['type']}): ${param['description']}",
        );
      }
      buffer.writeln();
    }

    if (endpoint['requestBody'] != null) {
      buffer.writeln("**Request Body:**");
      buffer.writeln("```json");
      buffer.writeln(json.encode(endpoint['requestBody']));
      buffer.writeln("```");
      buffer.writeln();
    }

    if (endpoint['responseExample'] != null) {
      buffer.writeln("**Response Example:**");
      buffer.writeln("```json");
      buffer.writeln(json.encode(endpoint['responseExample']));
      buffer.writeln("```");
    }

    return buffer.toString();
  }

  // === Notion Block Helpers ===

  Map<String, dynamic> _createHeading1Block(String text) => {
    "type": "heading_1",
    "heading_1": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": text},
        },
      ],
    },
  };

  Map<String, dynamic> _createHeading2Block(String text) => {
    "type": "heading_2",
    "heading_2": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": text},
        },
      ],
    },
  };

  Map<String, dynamic> _createHeading3Block(String text) => {
    "type": "heading_3",
    "heading_3": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": text},
        },
      ],
    },
  };

  Map<String, dynamic> _createParagraphBlock(String text) => {
    "type": "paragraph",
    "paragraph": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": text},
        },
      ],
    },
  };

  Map<String, dynamic> _createBulletedListBlock(String text) => {
    "type": "bulleted_list_item",
    "bulleted_list_item": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": text},
        },
      ],
    },
  };

  Map<String, dynamic> _createNumberedListBlock(String text) => {
    "type": "numbered_list_item",
    "numbered_list_item": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": text},
        },
      ],
    },
  };

  Map<String, dynamic> _createCheckboxBlock(String text, bool checked) => {
    "type": "to_do",
    "to_do": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": text},
        },
      ],
      "checked": checked,
    },
  };

  Map<String, dynamic> _createToggleBlock(String title, String content) => {
    "type": "toggle",
    "toggle": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": title},
        },
      ],
      "children": [_createParagraphBlock(content)],
    },
  };

  Map<String, dynamic> _createCalloutBlock(String emoji, String text) => {
    "type": "callout",
    "callout": {
      "rich_text": [{"type": "text", "text": {"content": text}}],
      "icon": {"type": "emoji", "emoji": emoji.substring(0, 1)},
    },
  };

  Map<String, dynamic> _createQuoteBlock(String text) => {
    "type": "quote",
    "quote": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": text},
        },
      ],
    },
  };

  Map<String, dynamic> _createDividerBlock() => {
    "type": "divider",
    "divider": {},
  };

  Map<String, dynamic> _createCodeBlock(String code, String language) => {
    "type": "code",
    "code": {
      "rich_text": [
        {
          "type": "text",
          "text": {"content": code},
        },
      ],
      "language": language,
    },
  };

  Map<String, dynamic> _createTableBlock(List<Map<String, dynamic>> fields) {
    // Notion API doesn't support direct table creation
    // Use formatted text instead
    final rows = <Map<String, dynamic>>[];

    // Header
    rows.add(_createParagraphBlock("**Field Name | Type | Description**"));
    rows.add(_createParagraphBlock("---|---|---"));

    // Data rows
    for (final field in fields) {
      final row =
          "${field['name']} | ${field['type']} | ${field['description'] ?? ''}";
      rows.add(_createParagraphBlock(row));
    }

    return _createParagraphBlock(""); // Return empty, will use rows separately
  }
}
