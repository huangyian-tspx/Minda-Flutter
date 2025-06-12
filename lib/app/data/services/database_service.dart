import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project_history.dart';
import '../../core/utils/app_logger.dart';
import 'package:get/get.dart';

class DatabaseService {
  static const String _databaseName = 'mind_ai_app.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _tableProjectHistory = 'project_history';

  Database? _database;

  Future<void> init() async {
    await _openDatabase();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      AppLogger.d('Opening database at: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      AppLogger.e('e opening database');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Create project_history table
      await db.execute('''
        CREATE TABLE $_tableProjectHistory (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          projectId TEXT NOT NULL UNIQUE,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          viewedAt TEXT NOT NULL,
          projectData TEXT NOT NULL,
          isFavorite INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Create indexes for better performance
      await db.execute('''
        CREATE INDEX idx_project_history_viewed_at ON $_tableProjectHistory(viewedAt DESC)
      ''');

      await db.execute('''
        CREATE INDEX idx_project_history_is_favorite ON $_tableProjectHistory(isFavorite)
      ''');

      AppLogger.i('Database tables created successfully');
    } catch (e) {
      AppLogger.e('e creating database tables');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades in future versions
    AppLogger.i('Database upgraded from version $oldVersion to $newVersion');
  }

  // ========== Project History Operations ==========

  /// Save or update a project in history
  Future<int> saveProjectHistory(ProjectHistory project) async {
    try {
      final db = await database;

      // Check if project already exists
      final existing = await db.query(
        _tableProjectHistory,
        where: 'projectId = ?',
        whereArgs: [project.projectId],
      );

      if (existing.isNotEmpty) {
        // Update existing record with new viewedAt time
        final existingProject = ProjectHistory.fromMap(existing.first);
        final updated = existingProject.copyWith(
          viewedAt: DateTime.now(),
          // Preserve favorite status
          isFavorite: existingProject.isFavorite,
        );

        await db.update(
          _tableProjectHistory,
          updated.toMap(),
          where: 'projectId = ?',
          whereArgs: [project.projectId],
        );

        AppLogger.i('Updated project history: ${project.title}');
        return existing.first['id'] as int;
      } else {
        // Insert new record
        final id = await db.insert(_tableProjectHistory, project.toMap());

        AppLogger.i('Saved new project to history: ${project.title}');
        return id;
      }
    } catch (e) {
      AppLogger.e('e saving project history');
      rethrow;
    }
  }

  /// Get all project history, sorted by viewedAt desc
  Future<List<ProjectHistory>> getProjectHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableProjectHistory,
        orderBy: 'viewedAt DESC',
        limit: limit,
        offset: offset,
      );

      return maps.map((map) => ProjectHistory.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('e getting project history');
      return [];
    }
  }

  /// Get project by ID
  Future<ProjectHistory?> getProjectById(String projectId) async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableProjectHistory,
        where: 'projectId = ?',
        whereArgs: [projectId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return ProjectHistory.fromMap(maps.first);
    } catch (e) {
      AppLogger.e('e getting project by ID');
      return null;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String projectId) async {
    try {
      final db = await database;

      // Get current status
      final existing = await db.query(
        _tableProjectHistory,
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      if (existing.isEmpty) {
        AppLogger.d('Project not found: $projectId');
        return false;
      }

      final currentProject = ProjectHistory.fromMap(existing.first);
      final newFavoriteStatus = !currentProject.isFavorite;

      // Update favorite status
      await db.update(
        _tableProjectHistory,
        {'isFavorite': newFavoriteStatus ? 1 : 0},
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      AppLogger.i(
        'Toggled favorite for project: $projectId to $newFavoriteStatus',
      );

      // Show user feedback
      Get.snackbar(
        newFavoriteStatus ? 'Đã thêm yêu thích' : 'Đã xoá khỏi yêu thích',
        currentProject.title,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: newFavoriteStatus ? Get.theme.primaryColor : null,
        colorText: newFavoriteStatus ? Get.theme.colorScheme.onPrimary : null,
      );

      return newFavoriteStatus;
    } catch (e) {
      AppLogger.e('e toggling favorite');
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật trạng thái yêu thích',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get all favorite projects
  Future<List<ProjectHistory>> getFavoriteProjects() async {
    try {
      final db = await database;
      final maps = await db.query(
        _tableProjectHistory,
        where: 'isFavorite = ?',
        whereArgs: [1],
        orderBy: 'viewedAt DESC',
      );

      return maps.map((map) => ProjectHistory.fromMap(map)).toList();
    } catch (e) {
      AppLogger.e('e getting favorite projects');
      return [];
    }
  }

  /// Delete a project from history
  Future<bool> deleteProject(String projectId) async {
    try {
      final db = await database;
      final rowsDeleted = await db.delete(
        _tableProjectHistory,
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      if (rowsDeleted > 0) {
        AppLogger.i('Deleted project: $projectId');
        Get.snackbar(
          'Đã xóa',
          'Dự án đã được xóa khỏi lịch sử',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }

      return rowsDeleted > 0;
    } catch (e) {
      AppLogger.e('e deleting project');
      Get.snackbar(
        'Lỗi',
        'Không thể xóa dự án',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Clear all project history
  Future<bool> clearAllHistory() async {
    try {
      final db = await database;
      await db.delete(_tableProjectHistory);

      AppLogger.i('Cleared all project history');
      Get.snackbar(
        'Đã xóa tất cả',
        'Lịch sử dự án đã được xóa sạch',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      AppLogger.e('e clearing history');
      Get.snackbar(
        'Lỗi',
        'Không thể xóa lịch sử',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Clear all favorites (remove favorite status, not delete)
  Future<bool> clearAllFavorites() async {
    try {
      final db = await database;
      await db.update(
        _tableProjectHistory,
        {'isFavorite': 0},
        where: 'isFavorite = ?',
        whereArgs: [1],
      );

      AppLogger.i('Cleared all favorites');
      Get.snackbar(
        'Đã xóa tất cả yêu thích',
        'Danh sách yêu thích đã được xóa sạch',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      AppLogger.e('e clearing favorites');
      Get.snackbar(
        'Lỗi',
        'Không thể xóa danh sách yêu thích',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final db = await database;

      // Total projects
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableProjectHistory',
      );
      final total = totalResult.first['count'] as int;

      // Total favorites
      final favoritesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableProjectHistory WHERE isFavorite = 1',
      );
      final favorites = favoritesResult.first['count'] as int;

      // Safe projects
      final safeResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableProjectHistory WHERE category = ?',
        ['safe'],
      );
      final safe = safeResult.first['count'] as int;

      // Challenging projects
      final challengingResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableProjectHistory WHERE category = ?',
        ['challenging'],
      );
      final challenging = challengingResult.first['count'] as int;

      return {
        'total': total,
        'favorites': favorites,
        'safe': safe,
        'challenging': challenging,
      };
    } catch (e) {
      AppLogger.e('e getting statistics');
      return {'total': 0, 'favorites': 0, 'safe': 0, 'challenging': 0};
    }
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    AppLogger.i('Database closed');
  }
}
