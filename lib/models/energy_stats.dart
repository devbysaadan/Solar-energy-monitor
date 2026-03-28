class EnergyStats {
  final double solarYield; // kW
  final double homeUsage; // kW
  final double gridFlow; // kW (positive is export, negative is import)
  final double batteryFlow; // kW
  final double batteryPercentage; // %
  final double co2Offset; // kg
  final int treesSaved;
  final bool systemOnline;

  const EnergyStats({
    required this.solarYield,
    required this.homeUsage,
    required this.gridFlow,
    required this.batteryFlow,
    required this.batteryPercentage,
    required this.co2Offset,
    required this.treesSaved,
    required this.systemOnline,
  });

  factory EnergyStats.initial() {
    return const EnergyStats(
      solarYield: 0.0,
      homeUsage: 0.0,
      gridFlow: 0.0,
      batteryFlow: 0.0,
      batteryPercentage: 50.0,
      co2Offset: 0.0,
      treesSaved: 0,
      systemOnline: true,
    );
  }
}

class HistoricalData {
  final DateTime time;
  final double solar;
  final double home;
  final double grid;
  final double battery;

  const HistoricalData({
    required this.time,
    required this.solar,
    required this.home,
    required this.grid,
    required this.battery,
  });
}
