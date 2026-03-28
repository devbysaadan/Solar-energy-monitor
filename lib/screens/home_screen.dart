import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/energy_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/energy_flow_painter.dart';
import '../widgets/stat_card.dart';
import '../widgets/historical_chart.dart';
import '../widgets/impact_metrics.dart';
import '../widgets/system_notifications.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Energy', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {},
          )
        ],
      ),
      body: Consumer<EnergyProvider>(
        builder: (context, provider, child) {
          final stats = provider.stats;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Live Energy Flow',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const EnergyFlowDiagram(),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: StatCard(
                        title: 'Solar Yield',
                        value: '${stats.solarYield}',
                        unit: 'kW',
                        icon: LucideIcons.sun,
                        iconColor: AppTheme.solarGreen,
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: StatCard(
                        title: 'Home Usage',
                        value: '${stats.homeUsage}',
                        unit: 'kW',
                        icon: LucideIcons.home,
                        iconColor: AppTheme.homePurple,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: StatCard(
                        title: 'Grid Flow',
                        value: '${stats.gridFlow.abs()}',
                        unit: 'kW',
                        icon: stats.gridFlow >= 0 ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                        iconColor: AppTheme.gridBlue,
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: StatCard(
                        title: 'Battery',
                        value: '${stats.batteryPercentage.toInt()}',
                        unit: '%',
                        icon: LucideIcons.batteryMedium,
                        iconColor: AppTheme.batteryYellow,
                      )),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const HistoricalChart(),
                  
                  const SizedBox(height: 24),
                  ImpactMetrics(stats: stats),
                  
                  const SizedBox(height: 24),
                  SystemNotifications(stats: stats),
                  
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
