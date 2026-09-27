import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'demo_solver.dart';
import 'math_hero.dart';

/// Phase 2 home screen: local/demo conversation interface.
///
/// In-memory conversation only: user messages, a transient "Analyzing..."
/// assistant state, and deterministic answers from [solveDemo]. No AI API,
/// backend, camera, gallery, microphone, persistence, or navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  int _nextId = 0;
  late final TextEditingController _controller;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode(
      // ignore: deprecated_member_use
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          // ignore: deprecated_member_use
          if (event is RawKeyDownEvent && !event.repeat) {
            // ignore: deprecated_member_use
            if (event.isShiftPressed) {
              _insertShiftEnterNewline();
              node.requestFocus();
              return KeyEventResult.handled;
            }
            _submit(_controller.text);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }
        return KeyEventResult.ignored;
      },
    );
  }

  void _insertShiftEnterNewline() {
    final String text = _controller.text;
    final TextSelection selection = _controller.selection;
    if (!selection.isValid) {
      final String newText = '$text\n';
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else {
      final String newText = text.replaceRange(
        selection.start,
        selection.end,
        '\n',
      );
      final int newOffset = (selection.start + 1).clamp(0, newText.length);
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String raw) {
    final String text = raw.trim();
    if (text.isEmpty) {
      // Approved behavior: clear whitespace-only input, create no message.
      if (_controller.text.isNotEmpty) {
        _controller.clear();
      }
      return;
    }
    _controller.clear();
    // Keep the keyboard open for follow-up questions.
    _focusNode.requestFocus();
    final int userId = _nextId++;
    final int analyzingId = _nextId++;
    setState(() {
      _messages.add(
        _ChatMessage(id: userId, author: _MessageAuthor.user, text: text),
      );
      _messages.add(
        _ChatMessage(
          id: analyzingId,
          author: _MessageAuthor.assistant,
          text: 'Analyzing...',
          isAnalyzing: true,
        ),
      );
    });
    _scrollToBottom();
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) {
        return;
      }
      final String answer = solveDemo(text);
      setState(() {
        final int index = _messages.indexWhere(
          (_ChatMessage m) => m.id == analyzingId,
        );
        if (index != -1) {
          _messages[index] = _ChatMessage(
            id: analyzingId,
            author: _MessageAuthor.assistant,
            text: answer,
          );
        }
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

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
                    // Visual only: no settings screen.
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Middle: empty-state hero or conversation list.
            Expanded(
              child: _messages.isEmpty
                  ? SingleChildScrollView(
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
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _MessageBubble(message: _messages[index]);
                      },
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
              child: _HomeInputBar(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// In-memory conversation message for Phase 2.
///
/// [isAnalyzing] marks the transient "Analyzing..." assistant placeholder
/// that is replaced in place by the deterministic demo answer.
enum _MessageAuthor { user, assistant }

class _ChatMessage {
  const _ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    this.isAnalyzing = false,
  });

  final int id;
  final _MessageAuthor author;
  final String text;
  final bool isAnalyzing;
}

/// Single conversation bubble.
///
/// User messages use the SolveLens brand gradient; assistant messages use a
/// theme-aware surface with a small "Demo · local result" caption so the
/// local demo is never mistaken for a real AI answer.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isUser = message.author == _MessageAuthor.user;
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            key: ValueKey<String>('user-message-${message.id}'),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: SolveLensTheme.brandGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          key: ValueKey<String>('assistant-message-${message.id}'),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: isDark
                ? const Color(0xFF141B33).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.85),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Demo · local result',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SolveLensTheme.brandPurple.withValues(
                    alpha: isDark ? 0.9 : 0.8,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (message.isAnalyzing)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  message.text,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom input bar for Phase 2.
///
/// The plus button stands in for future camera/gallery, the microphone
/// button for future voice input. Neither performs any action.
class _HomeInputBar extends StatelessWidget {
  const _HomeInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

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
              controller: controller,
              focusNode: focusNode,
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
              textInputAction: TextInputAction.send,
              onSubmitted: onSubmitted,
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
