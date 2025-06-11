import 'package:json_annotation/json_annotation.dart';

part 'notion_history_model.g.dart';

/// Model cho lịch sử Notion documents
@JsonSerializable()
class NotionHistoryItem {
  /// ID unique cho mỗi item
  final String id;
  
  /// Tiêu đề của document
  final String title;
  
  /// URL của Notion page
  final String url;
  
  /// Thời gian tạo
  final DateTime createdAt;
  
  /// Mô tả ngắn (optional)
  final String? description;

  const NotionHistoryItem({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    this.description,
  });

  /// Factory constructor từ JSON
  factory NotionHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$NotionHistoryItemFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$NotionHistoryItemToJson(this);

  /// Tạo NotionHistoryItem mới từ project data
  factory NotionHistoryItem.create({
    required String title,
    required String url,
    String? description,
  }) {
    return NotionHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      url: url,
      createdAt: DateTime.now(),
      description: description,
    );
  }

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      return 'Hôm nay ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Copy with method
  NotionHistoryItem copyWith({
    String? id,
    String? title,
    String? url,
    DateTime? createdAt,
    String? description,
  }) {
    return NotionHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotionHistoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotionHistoryItem{id: $id, title: $title, url: $url, createdAt: $createdAt}';
  }
} 