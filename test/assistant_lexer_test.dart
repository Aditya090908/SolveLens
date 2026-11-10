import 'package:flutter_test/flutter_test.dart';
import 'package:solvelens/assistant_content/assistant_ast.dart';
import 'package:solvelens/assistant_content/assistant_lexer.dart';

void main() {
  group('AssistantLexer.parseInline', () {
    test('two inline math segments with prose between', () {
      final List<InlineNode> nodes = AssistantLexer.parseInline(
        r'$x=2$ or $x=3$',
      );
      expect(nodes.length, 3);
      expect(nodes[0], isA<InlineMath>());
      expect((nodes[0] as InlineMath).tex, 'x=2');
      expect(nodes[1], isA<TextRun>());
      expect((nodes[1] as TextRun).text, ' or ');
      expect(nodes[2], isA<InlineMath>());
      expect((nodes[2] as InlineMath).tex, 'x=3');
    });

    test('bold label with two math segments', () {
      final List<InlineNode> nodes = AssistantLexer.parseInline(
        r'**Roots:** $x=2$ or $x=3$',
      );
      expect(nodes[0], isA<BoldRun>());
      final BoldRun bold = nodes[0] as BoldRun;
      expect(bold.children.single, isA<TextRun>());
      expect((bold.children.single as TextRun).text, 'Roots:');
      expect(nodes[1], isA<TextRun>());
      expect((nodes[1] as TextRun).text, ' ');
      expect(nodes[2], isA<InlineMath>());
      expect(nodes[3], isA<TextRun>());
      expect(nodes[4], isA<InlineMath>());
    });

    test('bold wrapping inline math only', () {
      final List<InlineNode> nodes = AssistantLexer.parseInline(
        r'The value is **$3$**.',
      );
      expect(nodes[1], isA<BoldRun>());
      expect(
        (nodes[1] as BoldRun).children.single,
        isA<InlineMath>(),
      );
    });

    test('unclosed dollar is literal', () {
      final List<InlineNode> nodes = AssistantLexer.parseInline(
        r'broken $x^2 here',
      );
      expect(nodes.any((InlineNode n) => n is TextRun && n.text.contains(r'$')),
          isTrue);
      expect(nodes.whereType<InlineMath>(), isEmpty);
    });
  });

  group('AssistantLexer.parse blocks', () {
    test('display dollar math block', () {
      final List<AssistantBlock> blocks = AssistantLexer.parse(
        r'$$\nx^2 + 1\n$$',
      );
      expect(blocks.single, isA<DisplayMathBlock>());
      expect((blocks.single as DisplayMathBlock).tex, contains('x^2'));
    });

    test('display bracket math block', () {
      final List<AssistantBlock> blocks = AssistantLexer.parse(
        r'\[x^2 + 1\]',
      );
      expect(blocks.single, isA<DisplayMathBlock>());
    });

    test('bullet line', () {
      final List<AssistantBlock> blocks = AssistantLexer.parse(
        r'- Item: $x^2$',
      );
      expect(blocks.single, isA<BulletBlock>());
    });
  });
}
