import 'package:flutter/material.dart';

import 'assistant_ast.dart';
import 'assistant_lexer.dart';
import 'assistant_math.dart';

/// Builds Flutter widgets from [AssistantLexer] output.
class AssistantRenderer extends StatelessWidget {
  const AssistantRenderer({
    super.key,
    required this.data,
    required this.baseStyle,
  });

  final String data;
  final TextStyle baseStyle;

  @override
  Widget build(BuildContext context) {
    final List<AssistantBlock> blocks = AssistantLexer.parse(data);
    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < blocks.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
            child: _buildBlock(blocks[i]),
          ),
      ],
    );
  }

  Widget _buildBlock(AssistantBlock block) {
    return switch (block) {
      ParagraphBlock(:final inlines) => _buildInlineRichText(inlines),
      BulletBlock(:final inlines) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('• ', style: baseStyle),
            Expanded(child: _buildInlineRichText(inlines)),
          ],
        ),
      NumberedBlock(:final index, :final inlines) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('$index. ', style: baseStyle),
            Expanded(child: _buildInlineRichText(inlines)),
          ],
        ),
      DisplayMathBlock(:final tex) => AssistantDisplayMath(
          tex: tex,
          textStyle: baseStyle,
        ),
    };
  }

  Widget _buildInlineRichText(List<InlineNode> nodes) {
    return SelectableText.rich(
      TextSpan(children: _inlineToTextSpans(nodes, bold: false)),
      style: baseStyle,
    );
  }

  List<InlineSpan> _inlineToTextSpans(List<InlineNode> nodes, {required bool bold}) {
    final List<InlineSpan> spans = <InlineSpan>[];
    final TextStyle spanStyle = bold
        ? baseStyle.copyWith(fontWeight: FontWeight.bold)
        : baseStyle;

    for (final InlineNode node in nodes) {
      switch (node) {
        case TextRun(:final text):
          spans.add(TextSpan(text: text, style: spanStyle));
        case BoldRun(:final children):
          spans.addAll(_inlineToTextSpans(children, bold: true));
        case InlineMath(:final tex):
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: AssistantInlineMath(tex: tex, textStyle: baseStyle),
            ),
          );
      }
    }
    return spans;
  }
}
