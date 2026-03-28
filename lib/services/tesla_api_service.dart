import 'dart:async';
import 'dart:math';
import '../models/energy_stats.dart';

class TeslaApiService {
  final Random _random = Random();
  Timer? _timer;
  final StreamController<EnergyStats> _streamController = StreamController<EnergyStats>.broadcast();

  Stream<EnergyStats> get liveStats => _streamController.stream;

  void startMocking() {
    _timer?.cancel();
    // Current base values
    double currentSolar = 4.0 + _random.nextDouble(); // 4-5 kW
    double currentHome = 1.5 + _random.nextDouble(); // 1.5-2.5 kW
    double currentBatteryPct = 12.0;
    double currentCo2 = 450.5;

    // Initial emit
    _emitStat(currentSolar, currentHome, currentBatteryPct, currentCo2);

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Fluctuate the values slightly
      currentSolar = max(0.0, currentSolar + (_random.nextDouble() - 0.5) * 0.5);
      currentHome = max(0.0, currentHome + (_random.nextDouble() - 0.5) * 0.3);
      
      // Calculate flows. Simple physics: Solar = Home + BatteryCharge + GridExport
      // If Solar > Home: Excess goes to Battery, then Grid.
      // If Solar < Home: Shortage comes from Battery, then Grid.
      // Mock simple model.
      
      currentCo2 += (currentSolar * 0.1); // Fake increment
      
      _emitStat(currentSolar, currentHome, currentBatteryPct, currentCo2);
    });
  }

  void _emitStat(double solar, double home, double batteryPct, double co2) {
    double netDiff = solar - home;
    double batteryFlow = 0.0;
    double gridFlow = 0.0;
    
    // Incomplete simplistic simulation
    if (netDiff > 0) {
      if (batteryPct < 100) {
        batteryFlow = min(netDiff, 5.0); // max 5kW charge
      }
      gridFlow = netDiff - batteryFlow;
    } else {
      batteryFlow = max(netDiff, -5.0); // max 5kW discharge
      gridFlow = netDiff - batteryFlow; // remaining from grid (negative is import)
    }

    _streamController.add(EnergyStats(
      solarYield: (solar * 10).roundToDouble() / 10,
      homeUsage: double.parse(home.toStringAsFixed(1)),
      batteryFlow: double.parse(batteryFlow.toStringAsFixed(1)),
      gridFlow: double.parse(gridFlow.toStringAsFixed(1)),
      batteryPercentage: batteryPct,
      co2Offset: double.parse(co2.toStringAsFixed(1)),
      treesSaved: (co2 / 20).floor(),
      systemOnline: true,
    ));
  }

  void stopMocking() {
    _timer?.cancel();
    _streamController.close();
  }

  Future<List<HistoricalData>> getHistoricalData(String range) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Network delay
    List<HistoricalData> data = [];
    int dataPoints = range == 'Day' ? 24 : (range == 'Week' ? 7 : 30);
    
    DateTime now = DateTime.now();
    for (int i = dataPoints; i >= 0; i--) {
      DateTime time = range == 'Day' ? now.subtract(Duration(hours: i)) : now.subtract(Duration(days: i));
      data.add(HistoricalData(
        time: time,
        solar: _random.nextDouble() * 20,
        home: _random.nextDouble() * 15,
        grid: (_random.nextDouble() - 0.5) * 10,
        battery: (_random.nextDouble() - 0.5) * 5,
      ));
    }
    return data;
  }
}
