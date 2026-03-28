import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../models/energy_stats.dart';

class ImpactMetrics extends StatelessWidget {
  final EnergyStats stats;

  const ImpactMetrics({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.leaf, color: AppTheme.solarGreen, size: 24),
              const SizedBox(width: 8),
              Text(
                'Environmental Impact',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                context,
                title: 'CO2 Offset',
                value: '${stats.co2Offset}',
                unit: 'kg',
                icon: LucideIcons.cloudRain,
              ),
              Container(width: 1, height: 40, color: AppTheme.textSecondary.withOpacity(0.2)),
              _buildMetricItem(
                context,
                title: 'Trees Saved',
                value: '${stats.treesSaved}',
                unit: '',
                icon: LucideIcons.treePine,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.solarGreen,
                  ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
