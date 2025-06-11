import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../core/values/app_sizes.dart';
import '../core/widgets/code_viewer.dart';

/// Simple CodeViewer Demo - No complex layouts
class CodeViewerDemoController extends GetxController {
  // Keep only 2 simple examples để test
  final List<CodeExample> sampleCodeExamples = [
    CodeExample(
      title: 'Flutter Basic Widget',
      description: 'Simple StatelessWidget example',
      code: '''class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello Flutter'),
    );
  }
}''',
      language: 'dart',
      explanation: 'Basic Flutter widget structure.',
    ),
    CodeExample(
      title: 'Simple Function',
      description: 'Basic Dart function',
      code: '''void greetUser(String name) {
  print('Hello, \$name!');
}

void main() {
  greetUser('World');
}''',
      language: 'dart',
      explanation: 'Simple Dart function with string interpolation.',
    ),
  ];
}

class CodeViewerDemoView extends GetView<CodeViewerDemoController> {
  const CodeViewerDemoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Code Viewer Demo',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Simple header
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Code Viewer Test - Simple Examples',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Simple list of code examples
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: controller.sampleCodeExamples.length,
                itemBuilder: (context, index) {
                  final example = controller.sampleCodeExamples[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${example.title}',
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
                            // Simple CodeViewer without complex features
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 