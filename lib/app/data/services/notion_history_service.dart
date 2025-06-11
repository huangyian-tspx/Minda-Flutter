import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_logger.dart';
import '../models/notion_history_model.dart';

/// Service quản lý lịch sử Notion documents
class NotionHistoryService {
  static NotionHistoryService? _instance;
  static NotionHistoryService get instance {
    _instance ??= NotionHistoryService._();
    return _instance!;
  }

  NotionHistoryService._();

  static const String _historyKey = 'notion_history';
  static const int _maxHistoryItems = 50; // Giới hạn số lượng items

  /// Lưu Notion URL vào lịch sử
  Future<bool> saveToHistory({
    required String title,
    required String url,
    String? description,
  }) async {
    try {
      AppLogger.d("Saving to Notion history: $title");

      final prefs = await SharedPreferences.getInstance();

      // Lấy lịch sử hiện tại
      final currentHistory = await getHistory();

      // Tạo item mới
      final newItem = NotionHistoryItem.create(
        title: title,
        url: url,
        description: description,
      );

      // Kiểm tra xem URL đã tồn tại chưa
      final existingIndex = currentHistory.indexWhere(
        (item) => item.url == url,
      );
      if (existingIndex != -1) {
        // Nếu đã tồn tại, cập nhật thời gian
        currentHistory[existingIndex] = newItem.copyWith(
          id: currentHistory[existingIndex].id,
        );
        AppLogger.d("Updated existing history item");
      } else {
        // Thêm mới vào đầu danh sách
        currentHistory.insert(0, newItem);
        AppLogger.d("Added new history item");
      }

      // Giới hạn số lượng items
      if (currentHistory.length > _maxHistoryItems) {
        currentHistory.removeRange(_maxHistoryItems, currentHistory.length);
        AppLogger.d("Trimmed history to $_maxHistoryItems items");
      }

      // Chuyển đổi thành JSON và lưu
      final jsonList = currentHistory.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);

      final success = await prefs.setString(_historyKey, jsonString);

      if (success) {
        AppLogger.d("Successfully saved Notion history");
      } else {
        AppLogger.e("Failed to save Notion history");
      }

      return success;
    } catch (e) {
      AppLogger.e("Error saving to Notion history: $e");
      return false;
    }
  }

  /// Lấy toàn bộ lịch sử
  Future<List<NotionHistoryItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);

      if (jsonString == null || jsonString.isEmpty) {
        AppLogger.d("No Notion history found");
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      final history = jsonList
          .map(
            (json) => NotionHistoryItem.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      // Sắp xếp theo thời gian tạo (mới nhất trước)
      history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      AppLogger.d("Retrieved ${history.length} history items");
      return history;
    } catch (e) {
      AppLogger.e("Error retrieving Notion history: $e");
      return [];
    }
  }

  /// Xóa một item khỏi lịch sử
  Future<bool> removeFromHistory(String id) async {
    try {
      AppLogger.d("Removing item from Notion history: $id");

      final currentHistory = await getHistory();
      final updatedHistory = currentHistory
          .where((item) => item.id != id)
          .toList();

      if (currentHistory.length == updatedHistory.length) {
        AppLogger.e("Item not found in history: $id");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final jsonList = updatedHistory.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);

      final success = await prefs.setString(_historyKey, jsonString);

      if (success) {
        AppLogger.d("Successfully removed item from history");
      } else {
        AppLogger.e("Failed to remove item from history");
      }

      return success;
    } catch (e) {
      AppLogger.e("Error removing from Notion history: $e");
      return false;
    }
  }

  /// Xóa toàn bộ lịch sử
  Future<bool> clearHistory() async {
    try {
      AppLogger.d("Clearing all Notion history");

      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_historyKey);

      if (success) {
        AppLogger.d("Successfully cleared Notion history");
      } else {
        AppLogger.e("Failed to clear Notion history");
      }

      return success;
    } catch (e) {
      AppLogger.e("Error clearing Notion history: $e");
      return false;
    }
  }

  /// Lấy số lượng items trong lịch sử
  Future<int> getHistoryCount() async {
    try {
      final history = await getHistory();
      return history.length;
    } catch (e) {
      AppLogger.e("Error getting history count: $e");
      return 0;
    }
  }

  /// Kiểm tra xem URL đã tồn tại trong lịch sử chưa
  Future<bool> isUrlInHistory(String url) async {
    try {
      final history = await getHistory();
      return history.any((item) => item.url == url);
    } catch (e) {
      AppLogger.e("Error checking URL in history: $e");
      return false;
    }
  }

  /// Lấy lịch sử theo khoảng thời gian
  Future<List<NotionHistoryItem>> getHistoryByDateRange({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final allHistory = await getHistory();

      return allHistory.where((item) {
        if (fromDate != null && item.createdAt.isBefore(fromDate)) {
          return false;
        }
        if (toDate != null && item.createdAt.isAfter(toDate)) {
          return false;
        }
        return true;
      }).toList();
    } catch (e) {
      AppLogger.e("Error getting history by date range: $e");
      return [];
    }
  }
}
