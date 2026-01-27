import 'dart:math' as math;
import 'package:flutter/material.dart';

class BubbleAnimationWidget extends StatefulWidget {
  const BubbleAnimationWidget({super.key});

  @override
  State<BubbleAnimationWidget> createState() => _BubbleAnimationWidgetState();
}

class _BubbleAnimationWidgetState extends State<BubbleAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = List.generate(15, (index) => Bubble());
  Offset _touchPosition = Offset.infinite;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => _touchPosition = event.localPosition),
      onExit: (_) => setState(() => _touchPosition = Offset.infinite),
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => _touchPosition = details.localPosition),
        onPanEnd: (_) => setState(() => _touchPosition = Offset.infinite),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            for (var bubble in _bubbles) {
              bubble.update(_touchPosition);
            }
            return CustomPaint(
              painter: BubblePainter(bubbles: _bubbles),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class Bubble {
  late double x;
  late double y;
  late double radius;
  late double speed;
  late double drift;
  late double opacity;

  Bubble() {
    reset();
    y = math.Random().nextDouble() * 800; // Initial random height
  }

  void reset() {
    x = math.Random().nextDouble() * 400; // Screen width approx
    y = 800 + math.Random().nextDouble() * 100;
    radius = 5 + math.Random().nextDouble() * 15;
    speed = 0.3 + math.Random().nextDouble() * 0.7;
    drift = (math.Random().nextDouble() - 0.5) * 0.5;
    opacity = 0.1 + math.Random().nextDouble() * 0.3;
  }

  void update(Offset touchPos) {
    y -= speed;
    x += drift;

    // React to touch (Repulsion)
    if (touchPos != Offset.infinite) {
      double dx = x - touchPos.dx;
      double dy = y - touchPos.dy;
      double dist = math.sqrt(dx * dx + dy * dy);
      if (dist < 100) {
        double force = (100 - dist) / 100;
        x += (dx / dist) * force * 5;
        y += (dy / dist) * force * 5;
      }
    }

    if (y < -50) {
      reset();
    }
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var bubble in bubbles) {
      paint.color = Colors.white.withOpacity(bubble.opacity);
      
      // Draw outer circle
      canvas.drawCircle(Offset(bubble.x % size.width, bubble.y), bubble.radius, paint);
      
      // Draw inner shine (reflex)
      final shinePaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity * 0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset((bubble.x % size.width) - bubble.radius * 0.3, bubble.y - bubble.radius * 0.3),
        bubble.radius * 0.2,
        shinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
