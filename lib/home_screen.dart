import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'math_hero.dart';

/// Phase 1 home screen: visual foundation only.
///
/// Contains branding, a decorative math hero, headline, supporting text,
/// and a bottom input bar. All controls are visual only: no camera,
/// gallery, microphone, navigation, API, or backend behavior.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top area: branding left, settings right.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SolveLensTheme.brandGradient,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SolveLens',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    tooltip: 'Settings',
                    // Visual only in Phase 1: no settings screen.
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Middle: hero + headline + supporting text.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder:
                      (
                        BuildContext context,
                        double value,
                        Widget? child,
                      ) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      const MathHero(),
                      const SizedBox(height: 24),
                      Text(
                        'What can I solve for you today?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ask a question, take a photo, or use your voice.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom input bar, respects keyboard and safe area.
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: const _HomeInputBar(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom input bar. Visual only in Phase 1.
///
/// The plus button stands in for future camera/gallery, the microphone
/// button for future voice input. Neither performs any action.
class _HomeInputBar extends StatelessWidget {
  const _HomeInputBar();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: isDark
            ? const Color(0xFF141B33).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.7),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          // Plus button: future camera/gallery. Visual only.
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SolveLensTheme.brandGradient,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Add photo (coming soon)',
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              cursorColor: Theme.of(context).colorScheme.onSurface,
              decoration: const InputDecoration(
                hintText: 'Ask anything...',
              ),
              maxLines: 4,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              // Visual only: no submission behavior in Phase 1.
              onSubmitted: (_) {},
            ),
          ),
          const SizedBox(width: 4),
          // Microphone button: future voice input. Visual only.
          IconButton(
            icon: Icon(
              Icons.mic_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'Voice input (coming soon)',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
