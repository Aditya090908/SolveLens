import 'package:material_ui/material_ui.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Inline math via [Math.tex] with plain-text fallback (no Parser Error UI).
class AssistantInlineMath extends StatelessWidget {
  const AssistantInlineMath({
    super.key,
    required this.tex,
    required this.textStyle,
  });

  final String tex;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    if (tex.isEmpty) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.hardEdge,
      child: Math.tex(
        tex,
        mathStyle: MathStyle.text,
        textStyle: textStyle,
        onErrorFallback: (_) => Text(tex, style: textStyle),
      ),
    );
  }
}

/// Display math via [Math.tex] with plain-text fallback.
class AssistantDisplayMath extends StatelessWidget {
  const AssistantDisplayMath({
    super.key,
    required this.tex,
    required this.textStyle,
  });

  final String tex;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    if (tex.isEmpty) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Math.tex(
          tex,
          mathStyle: MathStyle.display,
          textStyle: textStyle,
          onErrorFallback: (_) => Text(tex, style: textStyle),
        ),
      ),
    );
  }
}
