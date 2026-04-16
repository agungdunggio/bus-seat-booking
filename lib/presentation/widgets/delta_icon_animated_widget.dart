import 'dart:math' as math;

import 'package:flutter/material.dart';

class DeltaIconAnimatedWidget extends StatefulWidget {
  final bool isIncrease;

  const DeltaIconAnimatedWidget({
    super.key,
    required this.isIncrease,
  });


  @override
  State<DeltaIconAnimatedWidget> createState() =>
      _DeltaIconAnimatedWidgetState();
}

class _DeltaIconAnimatedWidgetState extends State<DeltaIconAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color trendColor =
        widget.isIncrease ?  const Color(0xFFEF4444) : const Color(0xFF10B981);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final active = _activeLayerIndex(_controller.value);
        return _buildStackedArrows(trendColor, active);
      },
    );
  }

  int _activeLayerIndex(double v) {
    if (v >= 1.0) return 2;
    return math.min((v * 3).floor(), 2);
  }

  Widget _buildStackedArrows(Color baseColor, int activeIndex) {
    final IconData iconData = widget.isIncrease
        ? Icons.keyboard_arrow_up_rounded
        : Icons.keyboard_arrow_down_rounded;
    const iconSize = 22.0;
    const step = 5.0;

    return SizedBox(
      width: iconSize + 2,
      height: iconSize + step * 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment:
            widget.isIncrease ? Alignment.bottomCenter : Alignment.topCenter,
        children: [
          for (var i = 0; i < 3; i++)
            Positioned(
              bottom: widget.isIncrease ? i * step : null,
              top: widget.isIncrease ? null : i * step,
              child: Icon(
                iconData,
                size: iconSize,
                color: baseColor.withValues(
                  alpha: i == activeIndex ? 1.0 : 0.26,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
