import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/energy_provider.dart';
import '../theme/app_theme.dart';

class HistoricalChart extends StatelessWidget {
  const HistoricalChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyProvider>(
      builder: (context, provider, child) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.barChart2, color: AppTheme.textPrimary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Energy Usage',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildTimeRangeSelector(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: provider.historicalData.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.solarGreen))
                    : _buildCustomChart(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context, EnergyProvider provider) {
    final ranges = ['Day', 'Week', 'Month', 'Year'];
    return Row(
      children: ranges.map((range) {
        final isSelected = provider.selectedRange == range;
        return GestureDetector(
          onTap: () => provider.fetchHistoricalData(range),
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.textPrimary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              range,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomChart(EnergyProvider provider) {
    double maxVal = 1.0;
    for (var d in provider.historicalData) {
      if (d.solar > maxVal) maxVal = d.solar;
      if (d.home > maxVal) maxVal = d.home;
    }
    maxVal *= 1.2; // Add vertical padding

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        final count = provider.historicalData.length;
        
        if (count == 0 || width <= 0 || height <= 0) return const SizedBox();

        final totalBars = width * 0.7; // 70% of width for bars
        final barGroupWidth = totalBars / count;
        final individualBarWidth = (barGroupWidth - 2) / 2;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (index) {
            final data = provider.historicalData[index];
            final solarH = (data.solar / maxVal) * height;
            final homeH = (data.home / maxVal) * height;

            return SizedBox(
              width: barGroupWidth,
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: individualBarWidth,
                    height: solarH,
                    decoration: const BoxDecoration(
                      color: AppTheme.solarGreen,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  Container(
                    width: individualBarWidth,
                    height: homeH,
                    decoration: const BoxDecoration(
                      color: AppTheme.homePurple,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
