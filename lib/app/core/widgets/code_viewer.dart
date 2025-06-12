import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

/// Simple Code Viewer Widget - No complex layouts
class CodeViewer extends StatelessWidget {
  final String code;
  final String language;
  final String? title;
  final bool showCopyButton;
  final bool showLanguageLabel;
  final EdgeInsets? padding;
  final double? maxHeight;

  const CodeViewer({
    Key? key,
    required this.code,
    required this.language,
    this.title,
    this.showCopyButton = true,
    this.showLanguageLabel = true,
    this.padding,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simple header
          _buildSimpleHeader(),

          // Simple code content
          _buildSimpleCodeContent(),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            // Title
            if (title != null) ...[
              SizedBox(
                width: 140.w,
                child: Text(
                  title!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 8),
            ],

            // Language label
            if (showLanguageLabel)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLanguageColor(language).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getLanguageColor(language),
                    width: 1,
                  ),
                ),
                child: Text(
                  language.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getLanguageColor(language),
                  ),
                ),
              ),

            Spacer(),

            // Copy button
            if (showCopyButton)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: _copyToClipboard,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.copy, size: 16, color: Colors.white70),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCodeContent() {
    return Container(
      width: double.infinity,
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight! - 60) // Account for header
          : BoxConstraints(maxHeight: 250), // Default max height
      padding: EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Text(
          code,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'monospace',
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
      case 'flutter':
        return const Color(0xFF0175C2);
      case 'javascript':
      case 'js':
        return const Color(0xFFF7DF1E);
      case 'python':
        return const Color(0xFF3776AB);
      case 'java':
        return const Color(0xFFED8B00);
      default:
        return AppTheme.primary;
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'Copied',
      'Code copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

/// Simple Code Example Model
class CodeExample {
  final String title;
  final String description;
  final String code;
  final String language;
  final String? explanation;

  const CodeExample({
    required this.title,
    required this.description,
    required this.code,
    required this.language,
    this.explanation,
  });

  factory CodeExample.fromJson(Map<String, dynamic> json) {
    return CodeExample(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      language: json['language']?.toString() ?? 'dart',
      explanation: json['explanation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'code': code,
      'language': language,
      'explanation': explanation,
    };
  }
}

/// Simple Code Examples Section - No complex animations
class CodeExamplesSection extends StatelessWidget {
  final List<CodeExample> examples;
  final String? sectionTitle;

  const CodeExamplesSection({
    Key? key,
    required this.examples,
    this.sectionTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (examples.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null) ...[
          Text(
            sectionTitle!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 16),
        ],

        // Simple list without complex layouts
        ...examples
            .map(
              (example) => Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          example.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          example.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondary,
                          ),
                        ),
                        SizedBox(height: 12),
                        CodeViewer(
                          code: example.code,
                          language: example.language,
                          title: example.title,
                          maxHeight: 300,
                        ),
                        if (example.explanation != null) ...[
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Explanation: ${example.explanation}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
