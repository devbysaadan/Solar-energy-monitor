import 'dart:math';
import 'package:flutter/material.dart';
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
  List<Offset> _lightningPath1 = [];
  List<Offset> _lightningPath2 = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _generateLightning();
  }
  
  void _generateLightning() {
    _lightningPath1 = _createLightningPath();
    _lightningPath2 = _createLightningPath();
    
    // Periodically generate new lightning positions every 2-5 seconds
    Future.delayed(Duration(milliseconds: 10000 + _random.nextInt(20000)), () {
      if (mounted) {
        setState(() {
          _generateLightning();
        });
      }
    });
  }

  List<Offset> _createLightningPath() {
    List<Offset> path = [];
    double currentX = _random.nextDouble() * 400; // rough screen width mapping
    double currentY = -50; // start slightly above screen
    path.add(Offset(currentX, currentY));
    
    while (currentY < 900) { // rough screen height mapping
      currentY += _random.nextDouble() * 60 + 20; // jump down
      currentX += (_random.nextDouble() - 0.5) * 100; // jagged left/right
      path.add(Offset(currentX, currentY));
    }
    return path;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark Base Color
        Container(color: AppTheme.background),
        
        // Lightning Animation Layer 1
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                 // Fast flicker math
                 double flicker = (_controller.value * 10) % 1.0; 
                 // Base opacity with sudden bright flashes
                 double opacity = (flicker > 0.8) ? 0.3 : 0.05;
                 
                 return CustomPaint(
                   painter: _LightningPainter(
                     pathPoints: _lightningPath1,
                     opacity: opacity,
                     color: AppTheme.gridBlue,
                   ),
                 );
              },
            ),
          ),
        ),
        
        // Lightning Animation Layer 2
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                 double flicker = (_controller.value * 7) % 1.0; 
                 double opacity = (flicker > 0.9) ? 0.25 : 0.02;
                 
                 return CustomPaint(
                   painter: _LightningPainter(
                     pathPoints: _lightningPath2,
                     opacity: opacity,
                     color: AppTheme.solarGreen,
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
  final List<Offset> pathPoints;
  final double opacity;
  final Color color;

  _LightningPainter({required this.pathPoints, required this.opacity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (pathPoints.isEmpty) return;

    final glowPaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15.0); // Powerful glow
      
    final corePaint = Paint()
      ..color = Colors.white.withOpacity(opacity > 0.1 ? opacity + 0.5 : opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    path.moveTo((pathPoints.first.dx / 400.0) * size.width, pathPoints.first.dy);
    
    for (int i = 1; i < pathPoints.length; i++) {
       double sx = (pathPoints[i].dx / 400.0) * size.width;
       double sy = (pathPoints[i].dy / 900.0) * size.height;
       path.lineTo(sx, sy);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant _LightningPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.pathPoints != pathPoints;
  }
}
