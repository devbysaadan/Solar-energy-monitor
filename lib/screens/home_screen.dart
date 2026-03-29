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

import '../widgets/electric_background.dart';
import '../widgets/circuit_tap_effect.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CircuitTapEffect(
      child: ElectricBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Solar Energy', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.settings),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppTheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Consumer<EnergyProvider>(
                      builder: (context, provider, child) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Settings', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                title: const Text('Enable Ambient Animations'),
                                subtitle: const Text('Toggle live energy flows and lighting effects'),
                                activeColor: AppTheme.solarGreen,
                                contentPadding: EdgeInsets.zero,
                                value: provider.isAnimationEnabled,
                                onChanged: (val) => provider.toggleAnimation(val),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
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
    )));
  }
}
