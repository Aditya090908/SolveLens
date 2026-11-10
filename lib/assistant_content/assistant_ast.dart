// Parsed assistant answer structure for the controlled renderer.

sealed class AssistantBlock {
  const AssistantBlock();
}

/// Prose and inline math (may contain line breaks in [inlines] as text).
class ParagraphBlock extends AssistantBlock {
  const ParagraphBlock(this.inlines);

  final List<InlineNode> inlines;
}

class BulletBlock extends AssistantBlock {
  const BulletBlock(this.inlines);

  final List<InlineNode> inlines;
}

class NumberedBlock extends AssistantBlock {
  const NumberedBlock(this.index, this.inlines);

  final int index;
  final List<InlineNode> inlines;
}

class DisplayMathBlock extends AssistantBlock {
  const DisplayMathBlock(this.tex);

  final String tex;
}

sealed class InlineNode {
  const InlineNode();
}

class TextRun extends InlineNode {
  const TextRun(this.text);

  final String text;
}

class BoldRun extends InlineNode {
  const BoldRun(this.children);

  final List<InlineNode> children;
}

class InlineMath extends InlineNode {
  const InlineMath(this.tex);

  final String tex;
}
