import 'dart:async';
import 'package:flutter/material.dart';
import '../models/energy_stats.dart';
import '../services/tesla_api_service.dart';

class EnergyProvider with ChangeNotifier {
  final TeslaApiService _apiService = TeslaApiService();
  
  EnergyStats _stats = EnergyStats.initial();
  EnergyStats get stats => _stats;

  List<HistoricalData> _historicalData = [];
  List<HistoricalData> get historicalData => _historicalData;

  String _selectedRange = 'Day';
  String get selectedRange => _selectedRange;

  StreamSubscription<EnergyStats>? _subscription;

  EnergyProvider() {
    _startListening();
    fetchHistoricalData(_selectedRange);
  }

  void _startListening() {
    _apiService.startMocking();
    _subscription = _apiService.liveStats.listen((newStats) {
      _stats = newStats;
      notifyListeners();
    });
  }

  void fetchHistoricalData(String range) async {
    _selectedRange = range;
    notifyListeners();
    
    _historicalData = await _apiService.getHistoricalData(range);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _apiService.stopMocking();
    super.dispose();
  }
}
