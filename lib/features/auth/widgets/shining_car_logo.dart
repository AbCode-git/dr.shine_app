import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';

class ShiningCarLogo extends StatefulWidget {
  final double size;
  const ShiningCarLogo({super.key, this.size = 120});

  @override
  State<ShiningCarLogo> createState() => _ShiningCarLogoState();
}

class _ShiningCarLogoState extends State<ShiningCarLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 0.6),
          painter: _CarPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _CarPainter extends CustomPainter {
  final double progress;
  _CarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw a stylized car body
    double w = size.width;
    double h = size.height;

    // Roof
    path.moveTo(w * 0.25, h * 0.4);
    path.quadraticBezierTo(w * 0.5, h * 0.1, w * 0.75, h * 0.4);

    // Body top
    path.lineTo(w * 0.95, h * 0.45);
    path.quadraticBezierTo(w, h * 0.5, w * 0.95, h * 0.8);

    // Bottom
    path.lineTo(w * 0.05, h * 0.8);
    path.quadraticBezierTo(0, h * 0.5, w * 0.05, h * 0.45);
    path.close();

    canvas.drawPath(path, paint);

    // Wheels
    final wheelPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(w * 0.2, h * 0.85), h * 0.15, wheelPaint);
    canvas.drawCircle(Offset(w * 0.8, h * 0.85), h * 0.15, wheelPaint);

    // Rims (Primary color)
    wheelPaint.color = AppColors.primary.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(w * 0.2, h * 0.85), h * 0.05, wheelPaint);
    canvas.drawCircle(Offset(w * 0.8, h * 0.85), h * 0.05, wheelPaint);

    // Windows (Transparent white)
    final windowPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    final windowPath = Path();
    windowPath.moveTo(w * 0.3, h * 0.4);
    windowPath.quadraticBezierTo(w * 0.5, h * 0.2, w * 0.7, h * 0.4);
    windowPath.close();
    canvas.drawPath(windowPath, windowPaint);

    // Shine Effect (Sweep Gradient)
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.white.withValues(alpha: 0.6),
          Colors.transparent,
          Colors.transparent,
        ],
        transform: GradientRotation(progress * 2 * 3.1415),
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, shinePaint);

    // Extra sparkle at progress
    if (progress > 0.4 && progress < 0.6) {
      final sparklePaint = Paint()
        ..color = Colors.white
            .withValues(alpha: (1.0 - (progress - 0.5).abs() * 10).clamp(0, 1))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(w * 0.7, h * 0.3), 3, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
