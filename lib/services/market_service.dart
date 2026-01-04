import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service to fetch real-time mutual fund NAV data
/// Uses MFAPI.in - Free API for Indian Mutual Funds
class MarketService {
  static final MarketService _instance = MarketService._internal();
  factory MarketService() => _instance;
  MarketService._internal();

  // Cache for NAV data
  final Map<String, NavData> _navCache = {};
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 15);

  // Popular Indian Mutual Fund scheme codes (AMFI codes)
  static const Map<String, String> fundCodes = {
    'hdfc_liquid': '118989',      // HDFC Liquid Fund
    'sbi_bluechip': '119598',     // SBI Blue Chip Fund
    'axis_long_term': '120503',   // Axis Long Term Equity
    'icici_balanced': '120594',   // ICICI Prudential Balanced Advantage
    'parag_flexi': '122639',      // Parag Parikh Flexi Cap
    'mirae_large': '118834',      // Mirae Asset Large Cap
    'kotak_small': '125497',      // Kotak Small Cap Fund
    'nippon_liquid': '118778',    // Nippon India Liquid Fund
    'hdfc_index_nifty': '120847', // HDFC Index Fund Nifty 50
    'uti_nifty': '120716',        // UTI Nifty Index Fund
  };

  /// Fetch NAV for a specific fund
  Future<NavData?> fetchNav(String fundId) async {
    final schemeCode = fundCodes[fundId];
    if (schemeCode == null) {
      debugPrint('Unknown fund ID: $fundId');
      return null;
    }

    // Check cache
    if (_navCache.containsKey(fundId) && _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _navCache[fundId];
      }
    }

    try {
      final url = 'https://api.mfapi.in/mf/$schemeCode';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final navData = NavData.fromJson(data, fundId);
        _navCache[fundId] = navData;
        _lastFetchTime = DateTime.now();
        return navData;
      }
    } catch (e) {
      debugPrint('Error fetching NAV for $fundId: $e');
    }
    return null;
  }

  /// Fetch NAV for multiple funds
  Future<Map<String, NavData>> fetchMultipleNavs(List<String> fundIds) async {
    final results = <String, NavData>{};
    
    for (final fundId in fundIds) {
      final nav = await fetchNav(fundId);
      if (nav != null) {
        results[fundId] = nav;
      }
    }
    
    return results;
  }

  /// Calculate current value based on units and current NAV
  double calculateCurrentValue(double units, double currentNav) {
    return units * currentNav;
  }

  /// Calculate returns
  double calculateReturns(double investedAmount, double currentValue) {
    return currentValue - investedAmount;
  }

  /// Calculate returns percentage
  double calculateReturnsPercentage(double investedAmount, double currentValue) {
    if (investedAmount <= 0) return 0;
    return ((currentValue - investedAmount) / investedAmount) * 100;
  }

  /// Get fund info
  static FundInfo? getFundInfo(String fundId) {
    return _fundInfoMap[fundId];
  }

  static const Map<String, FundInfo> _fundInfoMap = {
    'hdfc_liquid': FundInfo(
      id: 'hdfc_liquid',
      name: 'HDFC Liquid Fund',
      nameHindi: 'HDFC लिक्विड फंड',
      category: 'Liquid',
      riskLevel: 'Low',
      minInvestment: 100,
      expectedReturns: 6.5,
    ),
    'sbi_bluechip': FundInfo(
      id: 'sbi_bluechip',
      name: 'SBI Blue Chip Fund',
      nameHindi: 'SBI ब्लू चिप फंड',
      category: 'Large Cap',
      riskLevel: 'Moderate',
      minInvestment: 500,
      expectedReturns: 12.0,
    ),
    'axis_long_term': FundInfo(
      id: 'axis_long_term',
      name: 'Axis Long Term Equity (ELSS)',
      nameHindi: 'Axis लॉन्ग टर्म इक्विटी',
      category: 'ELSS',
      riskLevel: 'High',
      minInvestment: 500,
      expectedReturns: 14.0,
    ),
    'parag_flexi': FundInfo(
      id: 'parag_flexi',
      name: 'Parag Parikh Flexi Cap',
      nameHindi: 'पराग पारिख फ्लेक्सी कैप',
      category: 'Flexi Cap',
      riskLevel: 'Moderate-High',
      minInvestment: 1000,
      expectedReturns: 15.0,
    ),
    'mirae_large': FundInfo(
      id: 'mirae_large',
      name: 'Mirae Asset Large Cap',
      nameHindi: 'मिरे एसेट लार्ज कैप',
      category: 'Large Cap',
      riskLevel: 'Moderate',
      minInvestment: 500,
      expectedReturns: 13.0,
    ),
    'kotak_small': FundInfo(
      id: 'kotak_small',
      name: 'Kotak Small Cap Fund',
      nameHindi: 'कोटक स्मॉल कैप फंड',
      category: 'Small Cap',
      riskLevel: 'Very High',
      minInvestment: 500,
      expectedReturns: 18.0,
    ),
  };
}

/// NAV Data model
class NavData {
  final String fundId;
  final String schemeName;
  final double currentNav;
  final String navDate;
  final List<HistoricalNav> history;

  NavData({
    required this.fundId,
    required this.schemeName,
    required this.currentNav,
    required this.navDate,
    this.history = const [],
  });

  factory NavData.fromJson(Map<String, dynamic> json, String fundId) {
    final meta = json['meta'] ?? {};
    final data = json['data'] as List? ?? [];
    
    double nav = 0;
    String date = '';
    List<HistoricalNav> history = [];

    if (data.isNotEmpty) {
      nav = double.tryParse(data[0]['nav']?.toString() ?? '0') ?? 0;
      date = data[0]['date']?.toString() ?? '';
      
      // Get last 30 days history
      history = data.take(30).map((item) => HistoricalNav(
        date: item['date']?.toString() ?? '',
        nav: double.tryParse(item['nav']?.toString() ?? '0') ?? 0,
      )).toList();
    }

    return NavData(
      fundId: fundId,
      schemeName: meta['scheme_name']?.toString() ?? '',
      currentNav: nav,
      navDate: date,
      history: history,
    );
  }

  /// Calculate 1-day change
  double get oneDayChange {
    if (history.length < 2) return 0;
    final prevNav = history[1].nav;
    if (prevNav <= 0) return 0;
    return ((currentNav - prevNav) / prevNav) * 100;
  }

  /// Calculate 1-week change
  double get oneWeekChange {
    if (history.length < 7) return 0;
    final prevNav = history[6].nav;
    if (prevNav <= 0) return 0;
    return ((currentNav - prevNav) / prevNav) * 100;
  }
}

/// Historical NAV data point
class HistoricalNav {
  final String date;
  final double nav;

  HistoricalNav({required this.date, required this.nav});
}

/// Fund information model
class FundInfo {
  final String id;
  final String name;
  final String nameHindi;
  final String category;
  final String riskLevel;
  final double minInvestment;
  final double expectedReturns;

  const FundInfo({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.category,
    required this.riskLevel,
    required this.minInvestment,
    required this.expectedReturns,
  });
}
