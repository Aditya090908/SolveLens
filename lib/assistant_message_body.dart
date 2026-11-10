import 'package:flutter/material.dart';

import 'assistant_content/assistant_renderer.dart';

/// Renders assistant answer text with a controlled prose + math pipeline.
class AssistantMessageBody extends StatelessWidget {
  const AssistantMessageBody({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final double fontSize =
        Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14;
    final TextStyle baseStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: fontSize,
      height: 1.4,
    );

    return AssistantRenderer(data: data, baseStyle: baseStyle);
  }
}
