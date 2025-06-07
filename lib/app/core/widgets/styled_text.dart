import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isMain;
  const StyledText(this.text, {Key? key, this.style, this.isMain = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = isMain
        ? theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)
        : theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary);
    return Text(
      text,
      style: defaultStyle?.merge(style),
    );
  }
} 