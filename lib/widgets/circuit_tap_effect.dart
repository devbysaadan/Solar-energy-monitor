import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CircuitTapEffect extends StatefulWidget {
  final Widget child;
  const CircuitTapEffect({super.key, required this.child});

  @override
  State<CircuitTapEffect> createState() => _CircuitTapEffectState();
}

class _CircuitTapEffectState extends State<CircuitTapEffect> {
  final List<_TapSpark> _sparks = [];

  void _addSpark(Offset position) {
    final spark = _TapSpark(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(),
      position: position,
    );
    setState(() {
      _sparks.add(spark);
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _sparks.removeWhere((s) => s.id == spark.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
         _addSpark(event.position);
      },
      behavior: HitTestBehavior.translucent, 
      child: Stack(
        children: [
          widget.child,
          // Draw all active sparks
          ..._sparks.map((spark) => Positioned(
            left: spark.position.dx - 150, // 300x300 canvas to safely contain long branches
            top: spark.position.dy - 150,
            child: IgnorePointer(
              child: _SparkAnimation(key: ValueKey(spark.id)),
            ),
          )),
        ],
      ),
    );
  }
}

class _TapSpark {
  final String id;
  final Offset position;
  _TapSpark({required this.id, required this.position});
}

class _SparkAnimation extends StatefulWidget {
  const _SparkAnimation({super.key});

  @override
  State<_SparkAnimation> createState() => _SparkAnimationState();
}

class _SparkAnimationState extends State<_SparkAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Path _circuitPath;

  @override
  void initState() {
    super.initState();
    // Smooth, buttery 1-second burst
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1000),
    )..forward();
    
    _generateCircuit();
  }
  
  void _generateCircuit() {
     _circuitPath = Path();
     final random = Random();
     int numBranches = random.nextInt(5) + 6; // 6 to 10 branching tendrils
     for (int i = 0; i < numBranches; i++) {
         double angle = (2 * pi / numBranches) * i + (random.nextDouble() - 0.5);
         double length = random.nextDouble() * 80 + 50; // 50 to 130 px long burst
         _buildBranch(_circuitPath, const Offset(150, 150), angle, length, random);
     }
  }

  void _buildBranch(Path path, Offset start, double angle, double length, Random random) {
      double cx = start.dx;
      double cy = start.dy;
      path.moveTo(cx, cy);
      int segments = 5;
      for (int i=0; i<segments; i++) {
          cx += cos(angle) * (length/segments) + (random.nextDouble() - 0.5) * 20;
          cy += sin(angle) * (length/segments) + (random.nextDouble() - 0.5) * 20;
          path.lineTo(cx, cy);
          angle += (random.nextDouble() - 0.5) * 0.8; // wander
          
          // Split recursive sub-branch organically
          if (random.nextDouble() > 0.6 && length > 50) {
              double subAngle = angle + (random.nextBool() ? 1 : -1) * (pi/4 + random.nextDouble());
              _buildSubBranch(path, Offset(cx, cy), subAngle, length * 0.5, random);
              path.moveTo(cx, cy); // restore cursor to continue main branch
          }
      }
  }

  void _buildSubBranch(Path path, Offset start, double angle, double length, Random random) {
      double cx = start.dx;
      double cy = start.dy;
      path.moveTo(cx, cy);
      int segments = 3;
      for (int i=0; i<segments; i++) {
          cx += cos(angle) * (length/segments) + (random.nextDouble() - 0.5) * 10;
          cy += sin(angle) * (length/segments) + (random.nextDouble() - 0.5) * 10;
          path.lineTo(cx, cy);
      }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Curved animation for buttery organic expansion
          final curvedValue = Curves.easeOutQuart.transform(_controller.value);
          return CustomPaint(
            size: const Size(300, 300),
            painter: _SmoothCircuitPainter(
               path: _circuitPath,
               progress: curvedValue,
               fadeProgress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _SmoothCircuitPainter extends CustomPainter {
  final Path path;
  final double progress;
  final double fadeProgress;

  _SmoothCircuitPainter({required this.path, required this.progress, required this.fadeProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // Elegant fade out calculation
    double opacity = 1.0;
    if (fadeProgress > 0.4) {
       opacity = 1.0 - ((fadeProgress - 0.4) / 0.6);
    }
    opacity = opacity.clamp(0.0, 1.0);
    
    if (opacity <= 0.0) return;
    
    // Draw expanding plasma ripple at center for heavy click feel
    final ripplePaint = Paint()
      ..color = AppTheme.gridBlue.withOpacity(opacity * 0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);
    canvas.drawCircle(const Offset(150, 150), progress * 50, ripplePaint);

    // Glowing electricity lines
    final glowPaint = Paint()
       ..color = AppTheme.solarGreen.withOpacity(opacity)
       ..style = PaintingStyle.stroke
       ..strokeWidth = 3.0
       ..strokeJoin = StrokeJoin.round
       ..strokeCap = StrokeCap.round
       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
       
    final corePaint = Paint()
       ..color = Colors.white.withOpacity(opacity)
       ..style = PaintingStyle.stroke
       ..strokeWidth = 1.0
       ..strokeJoin = StrokeJoin.round
       ..strokeCap = StrokeCap.round;

    // Use pure native PathMetrics for zero-stutter buttery smooth drawing!
    Path animatedPath = Path();
    for (PathMetric metric in path.computeMetrics()) {
       animatedPath.addPath(metric.extractPath(0.0, metric.length * progress), Offset.zero);
       
       // Draw an intense little node at the tip of the lightning bolt
       if (progress > 0.05 && progress < 1.0) {
           Tangent? tangent = metric.getTangentForOffset(metric.length * progress);
           if (tangent != null) {
              canvas.drawCircle(tangent.position, 2.5, Paint()..color = Colors.white.withOpacity(opacity));
           }
       }
    }
       
    canvas.drawPath(animatedPath, glowPaint);
    canvas.drawPath(animatedPath, corePaint);
  }

  @override
  bool shouldRepaint(covariant _SmoothCircuitPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.fadeProgress != fadeProgress;
  }
}
