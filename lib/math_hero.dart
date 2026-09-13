import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Decorative mathematical hero visual for the Phase 1 home screen.
///
/// 100% code-drawn: gradient blobs plus a [CustomPaint] layer with axes,
/// a graph curve, a circle, a triangle, grid dots, and subtle symbols.
/// No packages, no image assets.
///
/// Sizing is responsive: the hero fills available width through an
/// [AspectRatio] with reasonable min/max guards, so it adapts to
/// portrait and landscape phone screens. No fixed height is used.
class MathHero extends StatelessWidget {
  const MathHero({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ExcludeSemantics(
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 120,
              maxHeight: 320,
              maxWidth: 520,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Stack(
                    children: <Widget>[
                      // Soft gradient blob, top-left.
                      Positioned(
                        left: constraints.maxWidth * 0.05,
                        top: constraints.maxHeight * 0.05,
                        child: Container(
                          width: constraints.maxWidth * 0.45,
                          height: constraints.maxWidth * 0.45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                SolveLensTheme.brandPurple,
                                SolveLensTheme.brandBlue,
                              ],
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: SolveLensTheme.brandPurple.withValues(
                                  alpha: isDark ? 0.35 : 0.25,
                                ),
                                blurRadius: 48,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          // Keep the blob itself translucent so it stays
                          // an accent rather than covering the surface.
                          foregroundDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withValues(
                              alpha: isDark ? 0.55 : 0.6,
                            ),
                          ),
                        ),
                      ),
                      // Soft gradient blob, bottom-right.
                      Positioned(
                        right: constraints.maxWidth * 0.04,
                        bottom: constraints.maxHeight * 0.04,
                        child: Container(
                          width: constraints.maxWidth * 0.38,
                          height: constraints.maxWidth * 0.38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                SolveLensTheme.brandBlue,
                                SolveLensTheme.brandPink,
                              ],
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: SolveLensTheme.brandPink.withValues(
                                  alpha: isDark ? 0.3 : 0.22,
                                ),
                                blurRadius: 48,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          foregroundDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withValues(
                              alpha: isDark ? 0.55 : 0.6,
                            ),
                          ),
                        ),
                      ),
                      // Mathematical line work drawn in relative units.
                      CustomPaint(
                        size: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        painter: _MathHeroPainter(isDark: isDark),
                      ),
                      // Subtle decorative symbols.
                      Positioned(
                        left: constraints.maxWidth * 0.12,
                        top: constraints.maxHeight * 0.12,
                        child: _HeroSymbol(text: 'π', isDark: isDark),
                      ),
                      Positioned(
                        right: constraints.maxWidth * 0.14,
                        top: constraints.maxHeight * 0.22,
                        child: _HeroSymbol(text: '∑', isDark: isDark),
                      ),
                      Positioned(
                        left: constraints.maxWidth * 0.2,
                        bottom: constraints.maxHeight * 0.14,
                        child: _HeroSymbol(text: '√x', isDark: isDark),
                      ),
                      Positioned(
                        right: constraints.maxWidth * 0.22,
                        bottom: constraints.maxHeight * 0.2,
                        child: _HeroSymbol(text: 'x²', isDark: isDark),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSymbol extends StatelessWidget {
  const _HeroSymbol({required this.text, required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: (isDark ? Colors.white : SolveLensTheme.brandPurple).withValues(
          alpha: isDark ? 0.5 : 0.35,
        ),
      ),
    );
  }
}

/// Draws axes, a parabola, a circle, a triangle, and grid dots.
///
/// All coordinates are fractions of [size] so the drawing scales with
/// whatever width the responsive [AspectRatio] produces.
class _MathHeroPainter extends CustomPainter {
  _MathHeroPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final Color lineColor = (isDark ? Colors.white : const Color(0xFF4B5563))
        .withValues(alpha: isDark ? 0.35 : 0.3);
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint accentPaint = Paint()
      ..color = SolveLensTheme.brandPurple.withValues(
        alpha: isDark ? 0.8 : 0.6,
      )
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = isDark
          ? const MaskFilter.blur(BlurStyle.normal, 3)
          : null;

    final Paint nodePaint = Paint()
      ..color = SolveLensTheme.brandPink.withValues(
        alpha: isDark ? 0.85 : 0.65,
      )
      ..style = PaintingStyle.fill;

    // Grid dots.
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 7; col++) {
        canvas.drawCircle(
          Offset(
            size.width * (0.12 + col * 0.126),
            size.height * (0.15 + row * 0.23),
          ),
          1.5,
          Paint()
            ..color = lineColor.withValues(alpha: isDark ? 0.3 : 0.2),
        );
      }
    }

    // Coordinate axes.
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.78),
      Offset(size.width * 0.9, size.height * 0.78),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.08),
      Offset(size.width * 0.18, size.height * 0.9),
      linePaint,
    );

    // Parabola / graph curve.
    final Path curve = Path()
      ..moveTo(size.width * 0.22, size.height * 0.75);
    curve.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.75,
      size.width * 0.55,
      size.height * 0.4,
    );
    curve.quadraticBezierTo(
      size.width * 0.62,
      size.height * 0.18,
      size.width * 0.82,
      size.height * 0.15,
    );
    canvas.drawPath(curve, accentPaint);

    // Nodes on the curve.
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.68),
      4,
      nodePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.4),
      4,
      nodePaint,
    );

    // Decorative circle, right side.
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.6),
      size.width * 0.07,
      linePaint,
    );

    // Decorative triangle, left side.
    final Path triangle = Path()
      ..moveTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.38, size.height * 0.48)
      ..lineTo(size.width * 0.22, size.height * 0.48)
      ..close();
    canvas.drawPath(triangle, linePaint);
  }

  @override
  bool shouldRepaint(_MathHeroPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
