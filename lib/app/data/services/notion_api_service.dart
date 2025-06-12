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
        logPrint: (object) => AppLogger.d('[NOTION] ${object.toString()}'),
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

  /// -- CẢI TIẾN LỚN: TÁCH LOGIC TẠO BLOCK THÀNH CÁC HÀM RIÊNG BIỆT --
  /// Chuyển đổi nội dung từ AI thành danh sách các block của Notion.
  List<Map<String, dynamic>> _formatContentToNotionBlocks(
    Map<String, dynamic> content,
  ) {
    final List<Map<String, dynamic>> blocks = [];

    try {
      // -- TIÊU ĐỀ CHÍNH & MỤC LỤC TỰ ĐỘNG --
      blocks.add(
        _createHeading1Block(content['title'] ?? 'Project Documentation'),
      );
      blocks.add(
        _createCalloutBlock(
          '✨',
          'Đây là tài liệu dự án được tạo tự động bởi AI. Tất cả các mục chính đều có trong mục lục bên dưới.',
        ),
      );
      blocks.add(_createHeading2Block("Mục Lục"));
      blocks.add(
        _createTableOfContentsBlock(),
      ); // Mục lục tự động dựa trên các heading
      blocks.add(_createDividerBlock());

      // -- CÁC PHẦN CỦA TÀI LIỆU --
      // Mỗi phần được tạo bởi một hàm riêng để dễ quản lý.
      blocks.addAll(_buildOverviewSection(content));
      blocks.addAll(_buildRequirementsSection(content));
      blocks.addAll(_buildArchitectureSection(content));
      blocks.addAll(_buildTechStackSection(content));
      blocks.addAll(_buildCoreFeaturesSection(content));
      blocks.addAll(_buildDatabaseSection(content));
      blocks.addAll(_buildApiSection(content));
      blocks.addAll(_buildImplementationPlanSection(content));

      // -- FOOTER --
      blocks.add(_createDividerBlock());
      blocks.add(
        _createQuoteBlock(
          "Tài liệu được tạo vào lúc: ${DateTime.now().toLocal().toString().substring(0, 16)} bởi Mind AI App.",
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e("Error formatting Notion blocks");
      return [
        _createHeading1Block("Lỗi Tạo Tài Liệu"),
        _createCalloutBlock(
          "❗",
          "Đã xảy ra lỗi trong quá trình định dạng nội dung. Vui lòng kiểm tra lại cấu trúc dữ liệu đầu vào. Chi tiết lỗi: $e",
        ),
      ];
    }

    return blocks;
  }

  // -- CÁC HÀM XÂY DỰNG TỪNG PHẦN --

  List<Map<String, dynamic>> _buildOverviewSection(
    Map<String, dynamic> content,
  ) {
    if (content['overview'] == null) return [];
    return [
      _createHeading2Block("1. Tổng Quan Dự Án"),
      _createParagraphBlock(content['overview']),
      if (content['keyMetrics'] != null)
        _createCalloutBlock('🎯', "Key Metrics: ${content['keyMetrics']}"),
      _createDividerBlock(),
    ];
  }

  List<Map<String, dynamic>> _buildRequirementsSection(
    Map<String, dynamic> content,
  ) {
    final List<Map<String, dynamic>> sectionBlocks = [];

    final funcReqs = content['functionalRequirements'];
    final nonFuncReqs = content['nonFunctionalRequirements'];

    if (funcReqs == null && nonFuncReqs == null) return [];

    sectionBlocks.add(_createHeading2Block("2. Phân Tích Yêu Cầu"));

    // Yêu cầu chức năng
    if (funcReqs is List && funcReqs.isNotEmpty) {
      sectionBlocks.add(_createHeading3Block("2.1. Yêu Cầu Chức Năng"));
      for (final req in funcReqs) {
        if (req is Map) {
          final title = req['title'] ?? 'Chưa có tiêu đề';
          final description = req['description'] ?? 'Chưa có mô tả.';
          // Sử dụng toggle để gọn gàng hơn
          sectionBlocks.add(
            _createToggleBlock(title, [_createParagraphBlock(description)]),
          );
        }
      }
    }

    // Yêu cầu phi chức năng
    if (nonFuncReqs is List && nonFuncReqs.isNotEmpty) {
      sectionBlocks.add(_createHeading3Block("2.2. Yêu Cầu Phi Chức Năng"));
      for (final req in nonFuncReqs) {
        sectionBlocks.add(_createBulletedListBlock(req.toString()));
      }
    }

    sectionBlocks.add(_createDividerBlock());
    return sectionBlocks;
  }

  List<Map<String, dynamic>> _buildArchitectureSection(
    Map<String, dynamic> content,
  ) {
    if (content['architecture'] == null) return [];
    return [
      _createHeading2Block("3. Kiến Trúc Hệ Thống"),
      _createParagraphBlock(content['architecture']),
      _createDividerBlock(),
    ];
  }

  List<Map<String, dynamic>> _buildTechStackSection(
    Map<String, dynamic> content,
  ) {
    final frontend = content['frontendTech'];
    final backend = content['backendTech'];

    if (frontend == null && backend == null) return [];

    // Sử dụng cột để trình bày đẹp hơn
    final List<Map<String, dynamic>> feBlocks = [];
    if (frontend is List && frontend.isNotEmpty) {
      feBlocks.add(_createHeading3Block("Frontend"));
      for (final tech in frontend) {
        if (tech is Map) {
          feBlocks.add(
            _createBulletedListBlock("**${tech['name']}:** ${tech['reason']}"),
          );
        }
      }
    }

    final List<Map<String, dynamic>> beBlocks = [];
    if (backend is List && backend.isNotEmpty) {
      beBlocks.add(_createHeading3Block("Backend"));
      for (final tech in backend) {
        if (tech is Map) {
          beBlocks.add(
            _createBulletedListBlock("**${tech['name']}:** ${tech['reason']}"),
          );
        }
      }
    }

    return [
      _createHeading2Block("4. Công Nghệ Sử Dụng"),
      _createColumnListBlock([
        feBlocks,
        beBlocks,
      ]), // Cột 1: Frontend, Cột 2: Backend
      _createDividerBlock(),
    ];
  }

  List<Map<String, dynamic>> _buildCoreFeaturesSection(
    Map<String, dynamic> content,
  ) {
    final features = content['coreFeatures'];
    if (features is! List || features.isEmpty) return [];

    final List<Map<String, dynamic>> sectionBlocks = [];
    sectionBlocks.add(_createHeading2Block("5. Tính Năng Chính"));

    int index = 1;
    for (final feature in features) {
      if (feature is! Map) continue;

      sectionBlocks.add(
        _createHeading3Block("5.$index. ${feature['name'] ?? 'Chưa có tên'}"),
      );
      sectionBlocks.add(_createParagraphBlock(feature['description'] ?? ''));

      if (feature['userStory'] != null) {
        sectionBlocks.add(
          _createQuoteBlock("User Story: ${feature['userStory']}"),
        );
      }

      final criteria = feature['acceptanceCriteria'];
      if (criteria is List && criteria.isNotEmpty) {
        sectionBlocks.add(_createParagraphBlock("**Tiêu chí nghiệm thu:**"));
        for (final item in criteria) {
          sectionBlocks.add(_createCheckboxBlock(item.toString(), false));
        }
      }
      index++;
    }

    sectionBlocks.add(_createDividerBlock());
    return sectionBlocks;
  }

  List<Map<String, dynamic>> _buildDatabaseSection(
    Map<String, dynamic> content,
  ) {
    final database = content['database'];
    final tables = database?['tables'];
    if (tables is! List || tables.isEmpty) return [];

    final List<Map<String, dynamic>> sectionBlocks = [];
    sectionBlocks.add(_createHeading2Block("6. Thiết Kế Database"));
    sectionBlocks.add(
      _createCalloutBlock(
        'ℹ️',
        'Dưới đây là schema dự kiến cho các bảng trong database. Mỗi bảng được đặt trong một toggle.',
      ),
    );

    for (final table in tables) {
      if (table is! Map) continue;

      final tableName = table['name'] ?? 'Chưa có tên bảng';
      final fields = table['fields'];
      final List<Map<String, dynamic>> fieldBlocks = [];

      if (fields is List && fields.isNotEmpty) {
        for (final field in fields) {
          if (field is Map) {
            final fieldInfo =
                "**${field['name']}** (`${field['type']}`) - ${field['description'] ?? 'Chưa có mô tả.'}";
            fieldBlocks.add(_createBulletedListBlock(fieldInfo));
          }
        }
      } else {
        fieldBlocks.add(
          _createParagraphBlock("Chưa có thông tin về các trường."),
        );
      }
      sectionBlocks.add(_createToggleBlock('📜 $tableName', fieldBlocks));
    }

    sectionBlocks.add(_createDividerBlock());
    return sectionBlocks;
  }

  List<Map<String, dynamic>> _buildApiSection(Map<String, dynamic> content) {
    final endpoints = content['apiEndpoints'];
    if (endpoints is! List || endpoints.isEmpty) return [];

    final List<Map<String, dynamic>> sectionBlocks = [];
    sectionBlocks.add(_createHeading2Block("7. API Documentation"));

    for (final endpoint in endpoints) {
      if (endpoint is! Map) continue;

      final method = endpoint['method'] ?? 'GET';
      final path = endpoint['path'] ?? '/';
      final title = '$method $path';

      sectionBlocks.add(
        _createToggleBlock(title, _formatApiEndpointToBlocks(endpoint)),
      );
    }

    sectionBlocks.add(_createDividerBlock());
    return sectionBlocks;
  }

  List<Map<String, dynamic>> _buildImplementationPlanSection(
    Map<String, dynamic> content,
  ) {
    final milestones = content['milestones'];
    if (milestones is! List || milestones.isEmpty) return [];

    final List<Map<String, dynamic>> sectionBlocks = [];
    sectionBlocks.add(_createHeading2Block("8. Kế Hoạch Triển Khai"));

    for (final milestone in milestones) {
      if (milestone is! Map) continue;

      sectionBlocks.add(
        _createHeading3Block(milestone['phase'] ?? 'Giai đoạn'),
      );

      final List<Map<String, dynamic>> milestoneContent = [];
      milestoneContent.add(
        _createParagraphBlock(
          "**Thời gian dự kiến:** ${milestone['duration'] ?? 'N/A'}",
        ),
      );

      final deliverables = milestone['deliverables'];
      if (deliverables is List && deliverables.isNotEmpty) {
        milestoneContent.add(_createParagraphBlock("**Sản phẩm bàn giao:**"));
        for (final item in deliverables) {
          milestoneContent.add(_createCheckboxBlock(item.toString(), false));
        }
      }
      sectionBlocks.addAll(milestoneContent);
    }

    sectionBlocks.add(_createDividerBlock());
    return sectionBlocks;
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
