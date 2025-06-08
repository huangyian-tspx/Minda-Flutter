import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomProgressCard extends StatefulWidget {
  final double progressValue; // 0.0 - 1.0
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final List<Color>? gradientColors;
  final TextStyle? textStyle;

  const CustomProgressCard({
    Key? key,
    required this.progressValue,
    this.size = 120,
    this.strokeWidth = 10,
    this.backgroundColor = const Color(0xFFE0F7FA),
    this.gradientColors,
    this.textStyle,
  }) : super(key: key);

  @override
  State<CustomProgressCard> createState() => _CustomProgressCardState();
}

class _CustomProgressCardState extends State<CustomProgressCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0, end: widget.progressValue).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CustomProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressValue != widget.progressValue) {
      _oldValue = _animation.value;
      _controller.reset();
      _animation = Tween<double>(begin: _oldValue, end: widget.progressValue).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradientColors ?? [
      const Color(0xFF80DEEA),
      const Color(0xFF00BCD4),
      const Color(0xFF0097A7),
    ];
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _GradientCircularProgressPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              backgroundColor: widget.backgroundColor,
              gradientColors: gradient,
            ),
            child: Center(
              child: Text(
                "${(_animation.value * 100).toInt()}%",
                style: widget.textStyle ?? const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final double strokeWidth;
  final Color backgroundColor;
  final List<Color> gradientColors;

  _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.gradientColors,
  });

  List<double> _generateStops(int colorCount) {
    if (colorCount == 1) return [1.0];
    return List.generate(colorCount, (i) => i / (colorCount - 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc with gradient
    final sweepAngle = 2 * math.pi * progress;
    final stops = _generateStops(gradientColors.length);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: gradientColors,
      stops: stops,
    );
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);

    // Draw moving dot
    final dotAngle = -math.pi / 2 + sweepAngle;
    final dotOffset = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    final dotPaint = Paint()..color = gradientColors.last;
    if (progress > 0) {
      canvas.drawCircle(dotOffset, strokeWidth * 0.7, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gradientColors != gradientColors;
  }
} 