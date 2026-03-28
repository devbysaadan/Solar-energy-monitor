import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/energy_provider.dart';
import '../theme/app_theme.dart';
import '../models/energy_stats.dart';

class EnergyFlowDiagram extends StatefulWidget {
  const EnergyFlowDiagram({super.key});

  @override
  State<EnergyFlowDiagram> createState() => _EnergyFlowDiagramState();
}

class _EnergyFlowDiagramState extends State<EnergyFlowDiagram> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 300,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: AnimatedBuilder(
            animation: _controller,
            child: const _FlowNodes(),
            builder: (context, child) {
              return RepaintBoundary(
                child: CustomPaint(
                  painter: _FlowPainter(
                    animationValue: _controller.value,
                    stats: provider.stats,
                  ),
                  child: child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FlowNodes extends StatelessWidget {
  const _FlowNodes();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solar Top
        Align(
          alignment: Alignment.topCenter,
          child: _buildNode(LucideIcons.sun, AppTheme.solarGreen),
        ),
        // Home Right
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: _buildNode(LucideIcons.home, AppTheme.homePurple),
          ),
        ),
        // Grid Left
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _buildNode(LucideIcons.zap, AppTheme.gridBlue),
          ),
        ),
        // Battery Bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildNode(LucideIcons.batteryMedium, AppTheme.batteryYellow),
        ),
      ],
    );
  }

  Widget _buildNode(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class _FlowPainter extends CustomPainter {
  final double animationValue;
  final EnergyStats stats;

  _FlowPainter({required this.animationValue, required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Node centers
    final solarCenter = Offset(w / 2, 30);
    final homeCenter = Offset(w - 50, h / 2);
    final gridCenter = Offset(50, h / 2);
    final batteryCenter = Offset(w / 2, h - 30);
    final centerJunction = Offset(w / 2, h / 2);

    final linePaint = Paint()
      ..color = AppTheme.textSecondary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw static lines
    canvas.drawLine(solarCenter, centerJunction, linePaint);
    canvas.drawLine(centerJunction, homeCenter, linePaint);
    canvas.drawLine(centerJunction, gridCenter, linePaint);
    canvas.drawLine(centerJunction, batteryCenter, linePaint);

    final particlePaint = Paint()..style = PaintingStyle.fill;

    // Helper to draw moving particles
    void drawParticles(Offset start, Offset end, Color color, double amount, bool reverse) {
      if (amount <= 0) return;
      particlePaint.color = color;
      
      // Calculate 3 particles spaced apart
      for (int i = 0; i < 3; i++) {
        double progress = (animationValue + (i / 3.0)) % 1.0;
        if (reverse) progress = 1.0 - progress;

        final startAdjusted = _adjustForRadius(start, end, 30);
        final endAdjusted = _adjustForRadius(end, start, 30);

        final x = startAdjusted.dx + (endAdjusted.dx - startAdjusted.dx) * progress;
        final y = startAdjusted.dy + (endAdjusted.dy - startAdjusted.dy) * progress;
        
        final sizeMult = min(1.0, amount / 5.0); // max size at 5kW
        canvas.drawCircle(Offset(x, y), 3 + (2 * sizeMult), particlePaint);
      }
    }

    // Solar to Junction
    drawParticles(solarCenter, centerJunction, AppTheme.solarGreen, stats.solarYield, false);

    // Junction to Home (Home always consumes)
    drawParticles(centerJunction, homeCenter, AppTheme.homePurple, stats.homeUsage, false);

    // Battery flow
    if (stats.batteryFlow > 0) {
      // Charging
      drawParticles(centerJunction, batteryCenter, AppTheme.batteryYellow, stats.batteryFlow, false);
    } else if (stats.batteryFlow < 0) {
      // Discharging
      drawParticles(centerJunction, batteryCenter, AppTheme.batteryYellow, stats.batteryFlow.abs(), true);
    }

    // Grid flow
    if (stats.gridFlow > 0) {
      // Export to Grid
      drawParticles(centerJunction, gridCenter, AppTheme.gridBlue, stats.gridFlow, false);
    } else if (stats.gridFlow < 0) {
      // Import from Grid
      drawParticles(centerJunction, gridCenter, AppTheme.gridBlue, stats.gridFlow.abs(), true);
    }
  }

  Offset _adjustForRadius(Offset start, Offset target, double radius) {
    final dx = target.dx - start.dx;
    final dy = target.dy - start.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist == 0) return start;
    return Offset(start.dx + (dx / dist) * radius, start.dy + (dy / dist) * radius);
  }

  @override
  bool shouldRepaint(covariant _FlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.stats != stats;
  }
}
