import 'assistant_ast.dart';

/// Parses raw assistant answer text into [AssistantBlock]s.
class AssistantLexer {
  const AssistantLexer._();

  static List<AssistantBlock> parse(String input) {
    return _parseBlocks(input);
  }

  static List<InlineNode> parseInline(String text) {
    return _parseInline(text, 0, text.length);
  }
}

List<AssistantBlock> _parseBlocks(String input) {
  if (input.isEmpty) {
    return const <AssistantBlock>[];
  }
  final List<String> lines = input.split('\n');
  final List<AssistantBlock> blocks = <AssistantBlock>[];
  var i = 0;
  while (i < lines.length) {
    final String line = lines[i];
    if (line.trim().isEmpty) {
      i += 1;
      continue;
    }

    final DisplayParseResult? display = _tryParseDisplayBlock(lines, i);
    if (display != null) {
      blocks.add(DisplayMathBlock(display.tex.trim()));
      i = display.nextLineIndex;
      continue;
    }

    final NumberedMatch? numbered = _tryParseNumberedLine(line);
    if (numbered != null) {
      blocks.add(NumberedBlock(numbered.index, _parseInlineLine(numbered.rest)));
      i += 1;
      continue;
    }

    if (line.startsWith('- ')) {
      blocks.add(BulletBlock(_parseInlineLine(line.substring(2))));
      i += 1;
      continue;
    }

    final StringBuffer paragraph = StringBuffer(line);
    i += 1;
    while (i < lines.length) {
      final String next = lines[i];
      if (next.trim().isEmpty) {
        break;
      }
      if (_tryParseDisplayBlock(lines, i) != null ||
          next.startsWith('- ') ||
          _tryParseNumberedLine(next) != null) {
        break;
      }
      paragraph.write('\n');
      paragraph.write(next);
      i += 1;
    }
    blocks.add(ParagraphBlock(_parseInlineLine(paragraph.toString())));
  }
  return blocks;
}

class DisplayParseResult {
  DisplayParseResult(this.tex, this.nextLineIndex);

  final String tex;
  final int nextLineIndex;
}

DisplayParseResult? _tryParseDisplayBlock(List<String> lines, int start) {
  final String line = lines[start];
  final String trimmed = line.trim();

  if (trimmed.startsWith(r'\[')) {
    return _tryParseBracketDisplay(lines, start, trimmed);
  }

  if (!trimmed.startsWith(r'$$')) {
    return null;
  }

  if (trimmed.endsWith(r'$$') && trimmed.length > 4) {
    final String body = trimmed.substring(2, trimmed.length - 2);
    return DisplayParseResult(body, start + 1);
  }

  if (trimmed == r'$$') {
    final StringBuffer body = StringBuffer();
    var j = start + 1;
    while (j < lines.length) {
      final String current = lines[j];
      if (current.trim() == r'$$' || current.trim().endsWith(r'$$')) {
        final String t = current.trim();
        if (t != r'$$') {
          body.write(t.substring(0, t.length - 2));
        }
        return DisplayParseResult(body.toString(), j + 1);
      }
      if (body.isNotEmpty) {
        body.write('\n');
      }
      body.write(current);
      j += 1;
    }
    return null;
  }

  final String body = trimmed.substring(2);
  if (body.endsWith(r'$$')) {
    return DisplayParseResult(
      body.substring(0, body.length - 2),
      start + 1,
    );
  }

  final StringBuffer multiline = StringBuffer(body);
  var j = start + 1;
  while (j < lines.length) {
    final String current = lines[j];
    if (current.trim().endsWith(r'$$')) {
      final String t = current.trim();
      final String last = t.substring(0, t.length - 2);
      if (multiline.isNotEmpty) {
        multiline.write('\n');
      }
      multiline.write(last);
      return DisplayParseResult(multiline.toString(), j + 1);
    }
    multiline.write('\n');
    multiline.write(current);
    j += 1;
  }
  return null;
}

DisplayParseResult? _tryParseBracketDisplay(
  List<String> lines,
  int start,
  String trimmed,
) {
  if (trimmed.endsWith(r'\]') && trimmed.length > 4) {
    return DisplayParseResult(
      trimmed.substring(2, trimmed.length - 2),
      start + 1,
    );
  }
  final StringBuffer body = StringBuffer(trimmed.substring(2));
  var j = start + 1;
  while (j < lines.length) {
    final String current = lines[j];
    if (current.trim().endsWith(r'\]')) {
      final String t = current.trim();
      body.write('\n');
      body.write(t.substring(0, t.length - 2));
      return DisplayParseResult(body.toString(), j + 1);
    }
    body.write('\n');
    body.write(current);
    j += 1;
  }
  return null;
}

class NumberedMatch {
  NumberedMatch(this.index, this.rest);

  final int index;
  final String rest;
}

NumberedMatch? _tryParseNumberedLine(String line) {
  var i = 0;
  while (i < line.length && line.codeUnitAt(i) >= 0x30 && line.codeUnitAt(i) <= 0x39) {
    i += 1;
  }
  if (i == 0 || i >= line.length || line[i] != '.') {
    return null;
  }
  var j = i + 1;
  if (j < line.length && line[j] == ' ') {
    j += 1;
  } else if (j >= line.length) {
    return null;
  }
  final int index = int.parse(line.substring(0, i));
  return NumberedMatch(index, line.substring(j));
}

List<InlineNode> _parseInlineLine(String line) {
  return _parseInline(line, 0, line.length);
}

List<InlineNode> _parseInline(String text, int start, int end) {
  final List<InlineNode> nodes = <InlineNode>[];
  var i = start;
  while (i < end) {
    if (_startsWith(text, i, end, '**')) {
      final int? close = _indexOfUnescaped(text, '**', i + 2, end);
      if (close != null) {
        nodes.add(
          BoldRun(_parseInline(text, i + 2, close)),
        );
        i = close + 2;
        continue;
      }
    }

    if (text[i] == r'$' && !_isEscaped(text, i)) {
      if (_startsWith(text, i, end, r'$$')) {
        nodes.add(TextRun(r'$'));
        i += 1;
        continue;
      }
      final int? close = _findInlineDollarEnd(text, i + 1, end);
      if (close != null) {
        final String body = text.substring(i + 1, close).trim();
        if (body.isNotEmpty) {
          nodes.add(InlineMath(body));
        } else {
          nodes.add(const TextRun(r'$$'));
        }
        i = close + 1;
        continue;
      }
      nodes.add(const TextRun(r'$'));
      i += 1;
      continue;
    }

    if (_startsWith(text, i, end, r'\(')) {
      final int? close = _findParenInlineEnd(text, i + 2, end);
      if (close != null) {
        nodes.add(InlineMath(text.substring(i + 2, close).trim()));
        i = close + 2;
        continue;
      }
    }

    final int next = _findNextInlineSpecial(text, i, end);
    if (next > i) {
      nodes.add(TextRun(text.substring(i, next)));
    }
    i = next > i ? next : i + 1;
  }
  return _mergeAdjacentTextRuns(nodes);
}

List<InlineNode> _mergeAdjacentTextRuns(List<InlineNode> nodes) {
  if (nodes.isEmpty) {
    return nodes;
  }
  final List<InlineNode> merged = <InlineNode>[];
  for (final InlineNode node in nodes) {
    if (node is TextRun &&
        merged.isNotEmpty &&
        merged.last is TextRun) {
      final TextRun last = merged.last as TextRun;
      merged[merged.length - 1] = TextRun('${last.text}${node.text}');
    } else {
      merged.add(node);
    }
  }
  return merged;
}

int _findNextInlineSpecial(String text, int i, int end) {
  var j = i;
  while (j < end) {
    if (_startsWith(text, j, end, '**')) {
      return j;
    }
    if (text[j] == r'$' && !_isEscaped(text, j)) {
      return j;
    }
    if (_startsWith(text, j, end, r'\(')) {
      return j;
    }
    j += 1;
  }
  return end;
}

int? _findInlineDollarEnd(String text, int contentStart, int end) {
  var j = contentStart;
  while (j < end) {
    if (text[j] == '\n') {
      return null;
    }
    if (text[j] == r'$' && !_isEscaped(text, j)) {
      if (_startsWith(text, j, end, r'$$')) {
        return null;
      }
      return j;
    }
    j += 1;
  }
  return null;
}

int? _findParenInlineEnd(String text, int contentStart, int end) {
  var j = contentStart;
  while (j < end) {
    if (text[j] == '\n') {
      return null;
    }
    if (_startsWith(text, j, end, r'\)')) {
      return j;
    }
    j += 1;
  }
  return null;
}

int? _indexOfUnescaped(String text, String token, int start, int end) {
  var j = start;
  while (j < end) {
    if (_startsWith(text, j, end, token) && !_isEscaped(text, j)) {
      return j;
    }
    j += 1;
  }
  return null;
}

bool _startsWith(String text, int index, int end, String token) {
  return index + token.length <= end &&
      text.substring(index, index + token.length) == token;
}

bool _isEscaped(String text, int index) {
  var backslashes = 0;
  var j = index - 1;
  while (j >= 0 && text[j] == r'\') {
    backslashes += 1;
    j -= 1;
  }
  return backslashes.isOdd;
}
