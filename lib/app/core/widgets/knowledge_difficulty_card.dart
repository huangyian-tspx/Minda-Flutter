import 'package:flutter/material.dart';
import '../../data/models/knowledge_item.dart';
import '../theme/app_theme.dart';
import '../values/app_sizes.dart';

/// Widget hiển thị item kiến thức với độ khó
class KnowledgeDifficultyCard extends StatelessWidget {
  final KnowledgeItem knowledgeItem;

  const KnowledgeDifficultyCard({
    Key? key,
    required this.knowledgeItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.p8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.school_outlined,
          color: AppTheme.primary,
          size: 24,
        ),
        title: Text(
          knowledgeItem.title,
          style: TextStyle(
            fontSize: AppSizes.f16,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
          ),
        ),
        trailing: _buildDifficultyChip(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p8,
        ),
      ),
    );
  }

  Widget _buildDifficultyChip() {
    Color backgroundColor;
    Color textColor;

    switch (knowledgeItem.difficulty) {
      case KnowledgeDifficulty.easy:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case KnowledgeDifficulty.medium:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case KnowledgeDifficulty.hard:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.p12,
        vertical: AppSizes.p4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.r8),
      ),
      child: Text(
        knowledgeItem.difficulty.displayText,
        style: TextStyle(
          fontSize: AppSizes.f12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
} 