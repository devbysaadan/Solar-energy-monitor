import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_provider.dart';
import '../theme/app_theme.dart';

class ElectricBackground extends StatefulWidget {
  final Widget child;
  const ElectricBackground({super.key, required this.child});

  @override
  State<ElectricBackground> createState() => _ElectricBackgroundState();
}

class _ElectricBackgroundState extends State<ElectricBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  Path _lightningPath = Path();

  @override
  void initState() {
    super.initState();
    // Vastly slower, ambient 5-second cycle for premium heartbeat feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
       if (status == AnimationStatus.completed) {
           _generateLightning();
           _controller.forward(from: 0.0);
       }
    });
    
    _generateLightning();
    _controller.forward();
  }
  
  void _generateLightning() {
    _lightningPath = _createLightningPath();
  }

  Path _createLightningPath() {
    Path path = Path();
    List<Offset> mainTrunk = [];
    double currentX = _random.nextDouble() * 400; // rough screen width
    double currentY = -50; 
    mainTrunk.add(Offset(currentX, currentY));
    
    // Wider horizontal jumps for slow creeping lightning
    while (currentY < 1000) { 
      currentY += _random.nextDouble() * 60 + 30; 
      currentX += (_random.nextDouble() - 0.5) * 120; 
      mainTrunk.add(Offset(currentX, currentY));
    }
    
    // Draw trunk smoothly
    path.moveTo(mainTrunk.first.dx, mainTrunk.first.dy);
    for (int i = 1; i < mainTrunk.length; i++) {
       path.lineTo(mainTrunk[i].dx, mainTrunk[i].dy);
       // Add organic sprawling branches 
       if (_random.nextDouble() > 0.4) {
           _addBranch(path, mainTrunk[i], (_random.nextDouble() - 0.5) * pi, 120);
       }
    }
    return path;
  }
  
  void _addBranch(Path path, Offset start, double angle, double length) {
      double cx = start.dx;
      double cy = start.dy;
      path.moveTo(cx, cy);
      int segments = 4;
      for (int i=0; i<segments; i++) {
          cx += cos(angle) * (length/segments) + (_random.nextDouble() - 0.5) * 20;
          cy += sin(angle) * (length/segments) + (_random.nextDouble() - 0.5) * 20;
          path.lineTo(cx, cy);
          angle += (_random.nextDouble() - 0.5) * 0.5; // wander
      }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAnimationEnabled = Provider.of<EnergyProvider>(context).isAnimationEnabled;
    if (!isAnimationEnabled) {
      return Stack(
        children: [
          Container(color: AppTheme.background),
          widget.child,
        ],
      );
    }

    return Stack(
      children: [
        // Dark Base Color
        Container(color: AppTheme.background),
        
        // Single Gorgeous Heartbeat Lightning Layer
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                 
                 // Phase 1 (0 to 0.4): Smoothly extract and draw downward
                 double pathProgress = _controller.value < 0.4 
                      ? Curves.easeOutCubic.transform(_controller.value / 0.4) 
                      : 1.0;
                      
                 // Phase 2 (0.4 to 1.0): Heartbeat pulse and fade out
                 double opacity = 1.0;
                 if (_controller.value > 0.4) {
                    double fadePhase = (_controller.value - 0.4) / 0.6; // normalized 0..1
                    // A majestic double heartbeat logic (sin wave over 0 to 2pi -> 2 peaks)
                    double pulse = (sin(fadePhase * pi * 4) + 1.0) / 2.0; 
                    opacity = pulse * (1.0 - fadePhase * 0.8); // pulses while slowly fading
                 } else {
                    opacity = pathProgress; // ramps up beautifully with drawing
                 }

                 return CustomPaint(
                   painter: _LightningPainter(
                     path: _lightningPath,
                     progress: pathProgress,
                     opacity: opacity,
                   ),
                 );
              },
            ),
          ),
        ),
        
        // Main Content above background
        widget.child,
      ],
    );
  }
}

class _LightningPainter extends CustomPainter {
  final Path path;
  final double progress;
  final double opacity;

  _LightningPainter({required this.path, required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01 || progress < 0.01) return; 

    // Scale gracefully to actual device screen size
    final m1 = Matrix4.identity();
    m1.scale(size.width / 400.0, size.height / 900.0);
    final scaledPath = path.transform(m1.storage);

    // Smoothly draw path out using PathMetrics
    Path animatedPath = Path();
    for (PathMetric metric in scaledPath.computeMetrics()) {
       animatedPath.addPath(metric.extractPath(0.0, metric.length * progress), Offset.zero);
    }

    // 1. Massive localized ambient blue background exactly under the lightning!
    final ambientCloudPaint = Paint()
      ..color = AppTheme.gridBlue.withOpacity(opacity * 0.45) // deep blue clouds
      ..style = PaintingStyle.stroke
      ..strokeWidth = 120.0 // Fills the background wherever lightning touches
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80.0);

    // 2. Focused aura surrounding the bolt
    final glowPaint = Paint()
      ..color = AppTheme.gridBlue.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      
    // 3. Sharp super-bright core
    final corePaint = Paint()
      ..color = Colors.white.withOpacity(opacity > 0.1 ? opacity + 0.2 : opacity)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;

    canvas.drawPath(animatedPath, ambientCloudPaint);
    canvas.drawPath(animatedPath, glowPaint);
    canvas.drawPath(animatedPath, corePaint);
  }

  @override
  bool shouldRepaint(covariant _LightningPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity || oldDelegate.path != path;
  }
}
