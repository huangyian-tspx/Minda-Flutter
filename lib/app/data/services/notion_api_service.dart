import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/config/app_configs.dart';
import '../../core/utils/app_logger.dart';
import '../models/api_error.dart';
import '../models/api_response.dart';

/// Service xử lý tất cả API calls đến Notion, đã được cải tiến để tạo ra
/// các trang tài liệu có định dạng chuyên nghiệp, đẹp mắt và chi tiết hơn.
///
/// Các cải tiến chính:
/// - **Cấu trúc module hóa:** Logic tạo block được chia thành các hàm nhỏ hơn.
/// - **Sử dụng Block nâng cao:** Tận dụng Callouts, Columns, Toggles và Code Blocks.
/// - **Mục lục động:** Sử dụng block `table_of_contents` của Notion.
/// - **Định dạng bảng (Schema):** Trình bày schema database một cách rõ ràng.
/// - **Định dạng API Endpoint:** Hiển thị chi tiết từng endpoint trong toggle.
/// - **Cải thiện tính ổn định:** Xử lý tốt hơn các trường hợp thiếu dữ liệu.
class NotionAPIService extends GetxService {
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

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  /// Tạo một trang Notion mới với định dạng chuyên nghiệp.
  ///
  /// [title] Tiêu đề của trang.
  /// [content] Nội dung đã được structure từ AI.
  /// Returns: URL của trang Notion hoặc lỗi.
  Future<ApiResponse<String>> createProjectDocument({
    required String title,
    required Map<String, dynamic> content,
  }) async {
    try {
      AppLogger.d("Creating advanced Notion document for: $title");

      // Cải tiến: Tạo blocks với cấu trúc module hóa và định dạng nâng cao.
      final blocks = _formatContentToNotionBlocks(content);

      final requestBody = {
        "parent": {"database_id": AppConfigs.dbIDNotion},
        "icon": {"type": "emoji", "emoji": "📑"}, // Thêm icon cho trang
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

      AppLogger.d("Sending request to Notion API with advanced blocks...");
      final response = await _dio.post(
        '/pages',
        data: json.encode(requestBody),
      );

      AppLogger.d("Notion response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final pageUrl = response.data['url'] as String;
        AppLogger.d("Successfully created Notion page: $pageUrl");
        return Success(pageUrl);
      } else {
        AppLogger.e(
          "Notion API error: ${response.statusCode} - ${response.data}",
        );
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

      String message = "Lỗi khi kết nối đến Notion.";
      String technicalDetails = "DioException: ${e.message}";

      if (e.response != null) {
        final responseData = e.response?.data;
        final notionErrorCode = responseData?['code'];
        final notionErrorMessage = responseData?['message'];

        switch (e.response?.statusCode) {
          case 401:
            message = "API key của Notion không hợp lệ hoặc hết hạn.";
            technicalDetails = "Invalid API key. Notion code: $notionErrorCode";
            break;
          case 404:
            message =
                "Database ID của Notion không tồn tại hoặc không có quyền truy cập.";
            technicalDetails =
                "Database ID not found: ${AppConfigs.dbIDNotion}. Notion code: $notionErrorCode";
            break;
          case 400:
            message =
                "Dữ liệu gửi lên không hợp lệ. Vui lòng kiểm tra cấu trúc database và dữ liệu đầu vào.";
            technicalDetails =
                "Bad request. Notion error: $notionErrorMessage. Data: $responseData";
            break;
          default:
            message = "Lỗi từ server Notion: ${e.response?.statusMessage}";
            technicalDetails =
                "Status: ${e.response?.statusCode}. Data: $responseData";
        }
      }
      return Failure(
        ApiError.fromDioException(
          e,
        ).copyWith(message: message, technicalDetails: technicalDetails),
      );
    } catch (e, stackTrace) {
      AppLogger.e("Unexpected error in Notion API");
      return Failure(ApiError.server(message: "message", statusCode: 1));
    }
  }

  // --- OVERVIEW ---
  List<Map<String, dynamic>> _buildOverviewSection(
    Map<String, dynamic> content,
  ) {
    final overview = content['projectOverview'] ?? content['overview'];
    if (overview == null) return [];
    return [
      _createHeading2Block("1. Tổng Quan Dự Án"),
      if (overview is String)
        _createParagraphBlock(overview)
      else ...[
        if (overview['problemStatement'] != null)
          _createParagraphBlock("Vấn đề: ${overview['problemStatement']}"),
        if (overview['targetAudience'] != null)
          _createParagraphBlock("Đối tượng: ${overview['targetAudience']}"),
        if (overview['solution'] != null)
          _createParagraphBlock("Giải pháp: ${overview['solution']}"),
      ],
      _createDividerBlock(),
    ];
  }

  // --- USER PERSONAS ---
  List<Map<String, dynamic>> _buildUserPersonasSection(
    Map<String, dynamic> content,
  ) {
    final personas = content['userPersonas'];
    if (personas is! List || personas.isEmpty) return [];
    final blocks = <Map<String, dynamic>>[];
    blocks.add(_createHeading2Block("2. User Personas"));
    for (final persona in personas) {
      if (persona is Map) {
        blocks.add(_createHeading3Block(persona['name'] ?? 'Persona'));
        if (persona['demographics'] != null) {
          blocks.add(
            _createParagraphBlock("Nhân khẩu học: ${persona['demographics']}"),
          );
        }
        if (persona['goals'] is List && persona['goals'].isNotEmpty) {
          blocks.add(_createParagraphBlock("Mục tiêu:"));
          for (final g in persona['goals']) {
            blocks.add(_createBulletedListBlock(g.toString()));
          }
        }
        if (persona['frustrations'] is List &&
            persona['frustrations'].isNotEmpty) {
          blocks.add(_createParagraphBlock("Khó khăn:"));
          for (final f in persona['frustrations']) {
            blocks.add(_createBulletedListBlock(f.toString()));
          }
        }
      }
    }
    blocks.add(_createDividerBlock());
    return blocks;
  }

  // --- FUNCTIONAL & NON-FUNCTIONAL REQUIREMENTS ---
  List<Map<String, dynamic>> _buildRequirementsSection(
    Map<String, dynamic> content,
  ) {
    final funcReqs = content['functionalRequirements'];
    final nonFuncReqs = content['nonFunctionalRequirements'];
    if (funcReqs == null && nonFuncReqs == null) return [];
    final blocks = <Map<String, dynamic>>[];
    blocks.add(_createHeading2Block("3. Yêu Cầu Dự Án"));

    if (funcReqs is List && funcReqs.isNotEmpty) {
      blocks.add(_createHeading3Block("3.1. Yêu cầu chức năng"));
      for (final req in funcReqs) {
        if (req is Map) {
          blocks.add(
            _createToggleBlock(
              req['name'] ?? req['title'] ?? req['id'] ?? 'Tính năng',
              [
                if (req['userStory'] != null)
                  _createQuoteBlock(req['userStory']),
                if (req['acceptanceCriteria'] is List)
                  ...req['acceptanceCriteria'].map<Map<String, dynamic>>(
                    (c) => _createCheckboxBlock(c.toString(), false),
                  ),
                if (req['description'] != null)
                  _createParagraphBlock(req['description']),
              ],
            ),
          );
        }
      }
    }

    if (nonFuncReqs is List && nonFuncReqs.isNotEmpty) {
      blocks.add(_createHeading3Block("3.2. Yêu cầu phi chức năng"));
      for (final req in nonFuncReqs) {
        if (req is Map) {
          blocks.add(
            _createBulletedListBlock(
              "[${req['category'] ?? ''}] ${req['requirement'] ?? req['description'] ?? req.toString()}",
            ),
          );
        } else {
          blocks.add(_createBulletedListBlock(req.toString()));
        }
      }
    }
    blocks.add(_createDividerBlock());
    return blocks;
  }

  // --- OVERRIDE _formatContentToNotionBlocks ---
  List<Map<String, dynamic>> _formatContentToNotionBlocks(
    Map<String, dynamic> content,
  ) {
    final blocks = <Map<String, dynamic>>[];
    try {
      blocks.add(
        _createHeading1Block(content['title'] ?? 'Project Documentation'),
      );
      blocks.add(
        _createCalloutBlock(
          '✨',
          'Tài liệu dự án tự động bởi AI. Xem mục lục bên dưới.',
        ),
      );
      blocks.add(_createHeading2Block("Mục Lục"));
      blocks.add(_createTableOfContentsBlock());
      blocks.add(_createDividerBlock());

      blocks.addAll(_buildOverviewSection(content));
      blocks.addAll(_buildUserPersonasSection(content));
      blocks.addAll(_buildRequirementsSection(content));
      blocks.addAll(_buildArchitectureSection(content));
      blocks.addAll(_buildTechStackSection(content));
      blocks.addAll(_buildCoreFeaturesSection(content));
      blocks.addAll(_buildDatabaseSection(content));
      blocks.addAll(_buildApiSection(content));
      blocks.addAll(_buildImplementationPlanSection(content));

      blocks.add(_createDividerBlock());
      blocks.add(
        _createQuoteBlock(
          "Tài liệu được tạo vào: ${DateTime.now().toLocal().toString().substring(0, 16)} bởi Mind AI App.",
        ),
      );
    } catch (e) {
      AppLogger.e("Error formatting Notion blocks: $e");
      return [
        _createHeading1Block("Lỗi Tạo Tài Liệu"),
        _createCalloutBlock(
          "❗",
          "Đã xảy ra lỗi khi định dạng nội dung. Chi tiết: $e",
        ),
      ];
    }
    return blocks;
  }

  // ...existing code...
  List<Map<String, dynamic>> _buildArchitectureSection(
    Map<String, dynamic> content,
  ) {
    final arch = content['architecture'] ?? content['systemArchitecture'];
    if (arch == null) return [];
    final blocks = <Map<String, dynamic>>[];
    blocks.add(_createHeading2Block("4. Kiến Trúc Hệ Thống"));
    if (arch is String) {
      blocks.add(_createParagraphBlock(arch));
    } else if (arch is Map) {
      if (arch['overview'] != null) {
        blocks.add(_createParagraphBlock(arch['overview']));
      }
      if (arch['diagramDescription'] != null) {
        blocks.add(
          _createParagraphBlock("Sơ đồ: ${arch['diagramDescription']}"),
        );
      }
      if (arch['components'] is List && arch['components'].isNotEmpty) {
        for (final comp in arch['components']) {
          if (comp is Map) {
            blocks.add(
              _createToggleBlock(comp['name'] ?? 'Thành phần', [
                _createParagraphBlock(comp['description'] ?? ''),
              ]),
            );
          }
        }
      }
    }
    blocks.add(_createDividerBlock());
    return blocks;
  }

  // --- TECH STACK ---
  List<Map<String, dynamic>> _buildTechStackSection(
    Map<String, dynamic> content,
  ) {
    final techStack = content['techStack'];
    if (techStack is! List || techStack.isEmpty) return [];
    final blocks = <Map<String, dynamic>>[];
    blocks.add(_createHeading2Block("5. Công Nghệ Sử Dụng"));
    for (final tech in techStack) {
      if (tech is Map) {
        blocks.add(
          _createBulletedListBlock(
            "${tech['name'] ?? tech['tech']}: ${tech['reason'] ?? ''}",
          ),
        );
      } else {
        blocks.add(_createBulletedListBlock(tech.toString()));
      }
    }
    blocks.add(_createDividerBlock());
    return blocks;
  }

  List<Map<String, dynamic>> _buildCoreFeaturesSection(
    Map<String, dynamic> content,
  ) {
    final features = content['coreFeatures'];
    if (features is! List || features.isEmpty) return [];
    final blocks = <Map<String, dynamic>>[];
    blocks.add(_createHeading2Block("6. Tính Năng Chính"));
    int idx = 1;
    for (final feature in features) {
      if (feature is Map) {
        blocks.add(
          _createHeading3Block("6.$idx. ${feature['name'] ?? 'Tính năng'}"),
        );
        if (feature['description'] != null) {
          blocks.add(_createParagraphBlock(feature['description']));
        }
        if (feature['userStory'] != null) {
          blocks.add(_createQuoteBlock(feature['userStory']));
        }
        if (feature['acceptanceCriteria'] is List) {
          for (final c in feature['acceptanceCriteria']) {
            blocks.add(_createCheckboxBlock(c.toString(), false));
          }
        }
        idx++;
      }
    }
    blocks.add(_createDividerBlock());
    return blocks;
  }

  List<Map<String, dynamic>> _buildDatabaseSection(
    Map<String, dynamic> content,
  ) {
    final schema = content['databaseSchema'] ?? content['database'];
    if (schema is! List || schema.isEmpty) return [];
    final blocks = <Map<String, dynamic>>[];
    blocks.add(_createHeading2Block("7. Thiết Kế Database"));
    for (final table in schema) {
      if (table is Map) {
        final columns = table['columns'] ?? table['fields'];
        final colBlocks = <Map<String, dynamic>>[];
        if (columns is List && columns.isNotEmpty) {
          for (final col in columns) {
            if (col is Map) {
              colBlocks.add(
                _createBulletedListBlock(
                  "**${col['name']}** (${col['type']}) - ${col['description'] ?? ''}",
                ),
              );
            }
          }
        }
        if (table['relations'] != null) {
          colBlocks.add(
            _createParagraphBlock("Quan hệ: ${table['relations']}"),
          );
        }
        blocks.add(
          _createToggleBlock(
            table['tableName'] ?? table['name'] ?? 'Bảng',
            colBlocks,
          ),
        );
      }
    }
    blocks.add(_createDividerBlock());
    return blocks;
  }

  List<Map<String, dynamic>> _buildApiSection(Map<String, dynamic> content) {
    final endpoints = content['apiEndpoints'];
    if (endpoints is! List || endpoints.isEmpty) return [];
    final blocks = <Map<String, dynamic>>[];
    blocks.add(_createHeading2Block("8. API Documentation"));
    for (final ep in endpoints) {
      if (ep is Map) {
        final title = "${ep['method'] ?? 'METHOD'} ${ep['path'] ?? ''}";
        final children = <Map<String, dynamic>>[];
        if (ep['description'] != null) {
          children.add(_createParagraphBlock(ep['description']));
        }
        if (ep['requestBody'] != null) {
          children.add(_createParagraphBlock("Request:"));
          children.add(_createCodeBlock(jsonEncode(ep['requestBody']), 'json'));
        }
        if (ep['responseSuccess'] != null) {
          children.add(_createParagraphBlock("Response:"));
          children.add(
            _createCodeBlock(jsonEncode(ep['responseSuccess']), 'json'),
          );
        }
        blocks.add(_createToggleBlock(title, children));
      }
    }
    blocks.add(_createDividerBlock());
    return blocks;
  }

  List<Map<String, dynamic>> _buildImplementationPlanSection(
    Map<String, dynamic> content,
  ) {
    final roadmap = content['projectRoadmap'] ?? content['milestones'];
    if (roadmap is! List || roadmap.isEmpty) return [];
    final blocks = <Map<String, dynamic>>[];
    blocks.add(_createHeading2Block("9. Lộ Trình Triển Khai"));
    for (final phase in roadmap) {
      if (phase is Map) {
        blocks.add(_createHeading3Block(phase['phase'] ?? 'Giai đoạn'));
        if (phase['goals'] is List && phase['goals'].isNotEmpty) {
          blocks.add(_createParagraphBlock("Mục tiêu:"));
          for (final g in phase['goals']) {
            blocks.add(_createBulletedListBlock(g.toString()));
          }
        }
        if (phase['keyFeatures'] is List && phase['keyFeatures'].isNotEmpty) {
          blocks.add(_createParagraphBlock("Tính năng chính:"));
          for (final f in phase['keyFeatures']) {
            blocks.add(_createBulletedListBlock(f.toString()));
          }
        }
      }
    }
    blocks.add(_createDividerBlock());
    return blocks;
  }

  /// -- CẢI TIẾN: Định dạng API endpoint thành một danh sách các block thay vì một string --
  List<Map<String, dynamic>> _formatApiEndpointToBlocks(
    Map<dynamic, dynamic> endpoint,
  ) {
    final List<Map<String, dynamic>> blocks = [];
    final JsonEncoder encoder = JsonEncoder.withIndent('  ');

    blocks.add(
      _createParagraphBlock(
        "**Mô tả:** ${endpoint['description'] ?? 'Chưa có mô tả.'}",
      ),
    );

    final params = endpoint['parameters'];
    if (params is List && params.isNotEmpty) {
      blocks.add(_createParagraphBlock("**Parameters:**"));
      for (final param in params) {
        if (param is Map) {
          blocks.add(
            _createBulletedListBlock(
              "`${param['name']}` (`${param['type']}`) - ${param['description'] ?? ''}",
            ),
          );
        }
      }
    }

    final reqBody = endpoint['requestBody'];
    if (reqBody != null) {
      blocks.add(_createParagraphBlock("**Request Body Example:**"));
      blocks.add(_createCodeBlock(encoder.convert(reqBody), 'json'));
    }

    final resExample = endpoint['responseExample'];
    if (resExample != null) {
      blocks.add(_createParagraphBlock("**Response Example:**"));
      blocks.add(_createCodeBlock(encoder.convert(resExample), 'json'));
    }

    return blocks;
  }

  // === CÁC HÀM HELPER TẠO NOTION BLOCK ===
  // (Đã được bổ sung thêm các block mới và định dạng rich_text)

  Map<String, dynamic> _createRichText(String text) {
    // Helper để xử lý markdown đơn giản như **bold** và `code`
    // Đây là một phiên bản đơn giản, có thể mở rộng thêm
    // Hiện tại Notion API không hỗ trợ trực tiếp markdown trong một text object
    // nên chúng ta sẽ giữ nó đơn giản.
    return {
      "type": "text",
      "text": {"content": text},
    };
  }

  Map<String, dynamic> _createHeading1Block(String text) => {
    "heading_1": {
      "rich_text": [_createRichText(text)],
      "color": "default",
    },
  };

  Map<String, dynamic> _createHeading2Block(String text) => {
    "heading_2": {
      "rich_text": [_createRichText(text)],
      "color": "default",
      "is_toggleable": false,
    },
  };

  Map<String, dynamic> _createHeading3Block(String text) => {
    "heading_3": {
      "rich_text": [_createRichText(text)],
      "color": "default",
      "is_toggleable": false,
    },
  };

  Map<String, dynamic> _createParagraphBlock(String text) => {
    "paragraph": {
      "rich_text": [_createRichText(text)],
    },
  };

  Map<String, dynamic> _createBulletedListBlock(String text) => {
    "bulleted_list_item": {
      "rich_text": [_createRichText(text)],
    },
  };

  Map<String, dynamic> _createCheckboxBlock(String text, bool checked) => {
    "to_do": {
      "rich_text": [_createRichText(text)],
      "checked": checked,
    },
  };

  Map<String, dynamic> _createToggleBlock(
    String title,
    List<Map<String, dynamic>> children,
  ) => {
    "toggle": {
      "rich_text": [_createRichText(title)],
      "children": children,
    },
  };

  Map<String, dynamic> _createCalloutBlock(String emoji, String text) => {
    "callout": {
      "icon": {"type": "emoji", "emoji": emoji},
      "rich_text": [_createRichText(text)],
    },
  };

  Map<String, dynamic> _createQuoteBlock(String text) => {
    "quote": {
      "rich_text": [_createRichText(text)],
    },
  };

  Map<String, dynamic> _createDividerBlock() => {"divider": {}};

  Map<String, dynamic> _createCodeBlock(String code, String language) => {
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

  Map<String, dynamic> _createTableOfContentsBlock() => {
    "table_of_contents": {"color": "default"},
  };

  Map<String, dynamic> _createColumnListBlock(
    List<List<Map<String, dynamic>>> columnsChildren,
  ) {
    final columns = columnsChildren
        .map(
          (children) => {
            "object": "block",
            "type": "column",
            "column": {"children": children},
          },
        )
        .toList();

    return {
      "column_list": {"children": columns},
    };
  }
}
