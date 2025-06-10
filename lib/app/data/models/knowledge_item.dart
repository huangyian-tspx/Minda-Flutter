/// Model cho item kiến thức có độ khó
class KnowledgeItem {
  final String title;
  final KnowledgeDifficulty difficulty;

  KnowledgeItem({
    required this.title,
    required this.difficulty,
  });
}

/// Enum cho độ khó của kiến thức
enum KnowledgeDifficulty { easy, medium, hard }

/// Extension để lấy thông tin về màu sắc và text hiển thị
extension KnowledgeDifficultyExtension on KnowledgeDifficulty {
  String get displayText {
    switch (this) {
      case KnowledgeDifficulty.easy:
        return 'Easy';
      case KnowledgeDifficulty.medium:
        return 'Medium';
      case KnowledgeDifficulty.hard:
        return 'Hard';
    }
  }
} 