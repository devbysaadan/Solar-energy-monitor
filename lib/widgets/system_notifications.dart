import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../models/energy_stats.dart';

class SystemNotifications extends StatelessWidget {
  final EnergyStats stats;

  const SystemNotifications({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stats.systemOnline ? AppTheme.surface : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stats.systemOnline ? AppTheme.solarGreen.withOpacity(0.3) : Colors.red.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stats.systemOnline ? AppTheme.solarGreen.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stats.systemOnline ? LucideIcons.checkCircle2 : LucideIcons.alertTriangle,
              color: stats.systemOnline ? AppTheme.solarGreen : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.systemOnline ? 'System Online' : 'System Offline',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  stats.systemOnline 
                      ? 'All components are operating normally.' 
                      : 'Communication with inverter lost. Check connection.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
