import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import '../../../core/config/app_configs.dart';
import '../../../core/utils/app_logger.dart';

/// Cached response model for storing in Hive
class CachedResponse {
  final String key;
  final String jsonResponse;
  final DateTime createdAt;
  final String model;
  final String promptHash;

  CachedResponse({
    required this.key,
    required this.jsonResponse,
    required this.createdAt,
    required this.model,
    required this.promptHash,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'jsonResponse': jsonResponse,
    'createdAt': createdAt.toIso8601String(),
    'model': model,
    'promptHash': promptHash,
  };

  factory CachedResponse.fromJson(Map<String, dynamic> json) => CachedResponse(
    key: json['key'],
    jsonResponse: json['jsonResponse'],
    createdAt: DateTime.parse(json['createdAt']),
    model: json['model'],
    promptHash: json['promptHash'],
  );

  /// Check if this cached response is still valid
  bool get isValid {
    final now = DateTime.now();
    final expiry = createdAt.add(AppConfigs.cacheExpiry);
    return now.isBefore(expiry);
  }

  /// Get age of cached response in human readable format
  String get ageDescription {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    
    if (diff.inMinutes < 1) {
      return 'vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} giờ trước';
    } else {
      return '${diff.inDays} ngày trước';
    }
  }
}

/// Service for caching OpenRouter API responses to reduce costs and improve performance
class PromptCachingService extends GetxService {
  static const String _boxName = AppConfigs.cacheBoxName;
  Box<String>? _cacheBox;
  
  /// Initialize the caching service
  Future<PromptCachingService> init() async {
    try {
      AppLogger.d("Initializing PromptCachingService...");
      
      // Initialize Hive if not already done
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }
      
      // Open cache box
      _cacheBox = await Hive.openBox<String>(_boxName);
      
      AppLogger.d("PromptCachingService initialized successfully with ${_cacheBox?.length ?? 0} cached responses");
      
      // Clean expired cache on startup
      await _cleanExpiredCache();
      
      return this;
    } catch (e) {
      AppLogger.e("Error initializing PromptCachingService: $e");
      rethrow;
    }
  }

  /// Cache an API response
  /// 
  /// [key] Unique cache key
  /// [jsonResponse] JSON response from API to cache
  /// [model] AI model used for this response
  /// [prompt] Original prompt (for validation)
  Future<void> cacheResponse({
    required String key,
    required String jsonResponse,
    String? model,
    String? prompt,
  }) async {
    try {
      if (_cacheBox == null) {
        AppLogger.e("Cache box not initialized");
        return;
      }

      // Create cached response object
      final cachedResponse = CachedResponse(
        key: key,
        jsonResponse: jsonResponse,
        createdAt: DateTime.now(),
        model: model ?? AppConfigs.openRouterModel,
        promptHash: prompt != null ? _createHash(prompt) : '',
      );

      // Store in Hive
      await _cacheBox!.put(key, jsonEncode(cachedResponse.toJson()));
      
      AppLogger.d("Cache WRITE: Saved response for key '$key' (${jsonResponse.length} chars, model: ${cachedResponse.model})");
      
      // Clean cache if it gets too large
      await _cleanCacheIfNeeded();
      
    } catch (e) {
      AppLogger.e("Error caching response for key '$key': $e");
    }
  }

  /// Get cached API response
  /// 
  /// [key] Cache key to lookup
  /// Returns cached JSON response or null if not found/expired
  Future<String?> getCachedResponse({required String key}) async {
    try {
      if (_cacheBox == null) {
        AppLogger.e("Cache box not initialized");
        return null;
      }

      final cachedJson = _cacheBox!.get(key);
      if (cachedJson == null) {
        AppLogger.d("Cache MISS: No cached response for key '$key'");
        return null;
      }

      // Parse cached response
      final cachedResponse = CachedResponse.fromJson(
        jsonDecode(cachedJson) as Map<String, dynamic>,
      );

      // Check if cache is still valid
      if (!cachedResponse.isValid) {
        AppLogger.d("Cache EXPIRED: Removing expired response for key '$key' (age: ${cachedResponse.ageDescription})");
        await _cacheBox!.delete(key);
        return null;
      }

      AppLogger.d("Cache HIT: Found valid response for key '$key' (age: ${cachedResponse.ageDescription}, model: ${cachedResponse.model})");
      return cachedResponse.jsonResponse;
      
    } catch (e) {
      AppLogger.e("Error getting cached response for key '$key': $e");
      return null;
    }
  }

  /// Create a cache key from model and prompt
  /// 
  /// [model] AI model name
  /// [prompt] Full prompt text
  /// Returns SHA-256 hash as cache key
  String createCacheKey({
    required String model, 
    required String prompt,
  }) {
    final input = '$model:$prompt';
    final hash = _createHash(input);
    
    AppLogger.d("Cache KEY: Created key '${hash.substring(0, 16)}...' for model '$model' (prompt length: ${prompt.length})");
    
    return hash;
  }

  /// Create SHA-256 hash from input string
  String _createHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Clean expired cache entries
  Future<void> _cleanExpiredCache() async {
    try {
      if (_cacheBox == null) return;

      final keys = _cacheBox!.keys.toList();
      int cleanedCount = 0;

      for (final key in keys) {
        final cachedJson = _cacheBox!.get(key);
        if (cachedJson != null) {
          try {
            final cachedResponse = CachedResponse.fromJson(
              jsonDecode(cachedJson) as Map<String, dynamic>,
            );

            if (!cachedResponse.isValid) {
              await _cacheBox!.delete(key);
              cleanedCount++;
            }
          } catch (e) {
            // If we can't parse it, delete it
            await _cacheBox!.delete(key);
            cleanedCount++;
          }
        }
      }

      if (cleanedCount > 0) {
        AppLogger.d("Cache CLEANUP: Removed $cleanedCount expired entries");
      }
    } catch (e) {
      AppLogger.e("Error cleaning expired cache: $e");
    }
  }

  /// Clean cache if it exceeds maximum size
  Future<void> _cleanCacheIfNeeded() async {
    try {
      if (_cacheBox == null) return;

      final currentSize = _cacheBox!.length;
      if (currentSize <= AppConfigs.maxCacheSize) return;

      AppLogger.d("Cache SIZE: Current size ($currentSize) exceeds limit (${AppConfigs.maxCacheSize}), cleaning oldest entries...");

      // Get all entries with their creation times
      final entries = <String, DateTime>{};
      final keys = _cacheBox!.keys.toList();

      for (final key in keys) {
        final cachedJson = _cacheBox!.get(key);
        if (cachedJson != null) {
          try {
            final cachedResponse = CachedResponse.fromJson(
              jsonDecode(cachedJson) as Map<String, dynamic>,
            );
            entries[key.toString()] = cachedResponse.createdAt;
          } catch (e) {
            // If we can't parse it, mark for deletion
            entries[key.toString()] = DateTime.fromMillisecondsSinceEpoch(0);
          }
        }
      }

      // Sort by creation time (oldest first)
      final sortedEntries = entries.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      // Delete oldest entries until we're under the limit
      final entriesToDelete = currentSize - AppConfigs.maxCacheSize + 10; // Delete a few extra for buffer
      int deletedCount = 0;

      for (int i = 0; i < entriesToDelete && i < sortedEntries.length; i++) {
        await _cacheBox!.delete(sortedEntries[i].key);
        deletedCount++;
      }

      AppLogger.d("Cache CLEANUP: Removed $deletedCount oldest entries to maintain size limit");
    } catch (e) {
      AppLogger.e("Error cleaning cache by size: $e");
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    try {
      if (_cacheBox == null) {
        return {
          'totalEntries': 0,
          'validEntries': 0,
          'expiredEntries': 0,
          'totalSizeKB': 0,
        };
      }

      final keys = _cacheBox!.keys.toList();
      int validEntries = 0;
      int expiredEntries = 0;
      int totalSize = 0;

      for (final key in keys) {
        final cachedJson = _cacheBox!.get(key);
        if (cachedJson != null) {
          totalSize += cachedJson.length;
          
          try {
            final cachedResponse = CachedResponse.fromJson(
              jsonDecode(cachedJson) as Map<String, dynamic>,
            );

            if (cachedResponse.isValid) {
              validEntries++;
            } else {
              expiredEntries++;
            }
          } catch (e) {
            expiredEntries++;
          }
        }
      }

      return {
        'totalEntries': keys.length,
        'validEntries': validEntries,
        'expiredEntries': expiredEntries,
        'totalSizeKB': (totalSize / 1024).round(),
      };
    } catch (e) {
      AppLogger.e("Error getting cache stats: $e");
      return {
        'totalEntries': 0,
        'validEntries': 0,
        'expiredEntries': 0,
        'totalSizeKB': 0,
      };
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      if (_cacheBox == null) return;

      final count = _cacheBox!.length;
      await _cacheBox!.clear();
      
      AppLogger.d("Cache CLEAR: Removed all $count cached entries");
    } catch (e) {
      AppLogger.e("Error clearing cache: $e");
    }
  }

  /// Close the cache box
  Future<void> close() async {
    try {
      await _cacheBox?.close();
      AppLogger.d("PromptCachingService closed");
    } catch (e) {
      AppLogger.e("Error closing PromptCachingService: $e");
    }
  }
} 