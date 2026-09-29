import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// AI-side animated typing indicator — three pulsing dots.
///
/// Sits in the same position as an AI bubble (left-aligned with avatar).
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Small robot avatar (same as message bubble).
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: const BoxDecoration(
              color: OleenaTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: OleenaTheme.primaryTint,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _Dot(controller: _controller, index: i)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _Dot({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    // Each dot lags 0.2s behind the previous.
    final offset = index * 0.25;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        // value oscillates 0→1→0; shift by offset and wrap.
        final t = ((controller.value - offset) % 1.0 + 1.0) % 1.0;
        // Smooth sine wave: 0 at start, peak at mid.
        final scale = 0.6 + 0.4 * math.sin(t * math.pi);
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(left: index == 0 ? 0 : 5),
          decoration: BoxDecoration(
            color: OleenaTheme.primary.withValues(alpha: 0.6 + 0.4 * scale),
            shape: BoxShape.circle,
          ),
          transform: Matrix4.translationValues(0.0, -4 * (scale - 0.6) / 0.4, 0.0),
        );
      },
    );
  }
}
