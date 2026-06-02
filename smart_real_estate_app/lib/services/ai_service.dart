import '../models/property_model.dart';
import 'mock_data_service.dart';
import 'api_service.dart';

class AIRecommendation {
  final Property property;
  final double matchScore;
  final List<String> matchReasons;
  final List<String> matchReasonsAr;
  final String aiInsight;
  final String aiInsightAr;

  AIRecommendation({
    required this.property,
    required this.matchScore,
    required this.matchReasons,
    required this.matchReasonsAr,
    required this.aiInsight,
    required this.aiInsightAr,
  });
}

class AIPriceAnalysis {
  final double estimatedPrice;
  final double pricePerSqm;
  final double marketAverage;
  final double priceVariance;
  final String trend;
  final String trendAr;
  final String insight;
  final String insightAr;
  final List<Map<String, dynamic>> comparables;

  AIPriceAnalysis({
    required this.estimatedPrice,
    required this.pricePerSqm,
    required this.marketAverage,
    required this.priceVariance,
    required this.trend,
    required this.trendAr,
    required this.insight,
    required this.insightAr,
    required this.comparables,
  });
}

class AISearchResult {
  final List<Property> properties;
  final String summary;
  final String summaryAr;
  final Map<String, dynamic> filters;
  final List<String> suggestions;
  final List<String> suggestionsAr;

  AISearchResult({
    required this.properties,
    required this.summary,
    required this.summaryAr,
    required this.filters,
    required this.suggestions,
    required this.suggestionsAr,
  });
}

class UserPreference {
  String? preferredType;
  String? preferredCity;
  double? minBudget;
  double? maxBudget;
  int? minBedrooms;
  double? minArea;
  List<String> viewedProperties;
  List<String> favoriteTypes;

  UserPreference({
    this.preferredType,
    this.preferredCity,
    this.minBudget,
    this.maxBudget,
    this.minBedrooms,
    this.minArea,
    this.viewedProperties = const [],
    this.favoriteTypes = const [],
  });
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  List<Property> _cachedProperties = [];

  Future<List<Property>> _getProperties() async {
    if (_cachedProperties.isNotEmpty) return _cachedProperties;
    final apiProps = await ApiService.getProperties();
    _cachedProperties = apiProps.isNotEmpty ? apiProps : MockDataService.getProperties();
    return _cachedProperties;
  }

  void updateCachedProperties(List<Property> properties) {
    if (properties.isNotEmpty) _cachedProperties = properties;
  }

  UserPreference _userPreference = UserPreference(
    preferredCity: 'الرياض',
    maxBudget: 3000000,
    minBedrooms: 3,
    preferredType: 'villa',
  );

  UserPreference get userPreference => _userPreference;

  void updatePreference(UserPreference preference) {
    _userPreference = preference;
  }

  Future<List<AIRecommendation>> getRecommendationsAsync({int count = 5}) async {
    final allProperties = await _getProperties();
    return _computeRecommendations(allProperties, count);
  }

  List<AIRecommendation> getRecommendations({int count = 5}) {
    final allProperties = _cachedProperties.isNotEmpty
        ? _cachedProperties
        : MockDataService.getProperties();
    final scored = <AIRecommendation>[];

    for (final property in allProperties) {
      double score = 0;
      final reasons = <String>[];
      final reasonsAr = <String>[];

      if (_userPreference.preferredType != null &&
          property.propertyType == _userPreference.preferredType) {
        score += 30;
        reasons.add('Matches your preferred property type');
        reasonsAr.add('يطابق نوع العقار المفضل لديك');
      }

      if (_userPreference.preferredCity != null &&
          (property.location?.contains(_userPreference.preferredCity!) ==
              true)) {
        score += 25;
        reasons.add('Located in your preferred city');
        reasonsAr.add('يقع في مدينتك المفضلة');
      }

      if (_userPreference.maxBudget != null &&
          property.price <= _userPreference.maxBudget!) {
        final budgetRatio = property.price / _userPreference.maxBudget!;
        if (budgetRatio >= 0.6 && budgetRatio <= 1.0) {
          score += 20;
          reasons.add('Within your budget range');
          reasonsAr.add('ضمن ميزانيتك المحددة');
        } else if (budgetRatio < 0.6) {
          score += 10;
          reasons.add('Below your budget');
          reasonsAr.add('أقل من ميزانيتك');
        }
      }

      if (_userPreference.minBedrooms != null &&
          property.bedrooms != null &&
          property.bedrooms! >= _userPreference.minBedrooms!) {
        score += 15;
        reasons.add('Has ${property.bedrooms} bedrooms as needed');
        reasonsAr.add('يحتوي على ${property.bedrooms} غرف نوم كما تريد');
      }

      if (property.images.length > 1) {
        score += 5;
        reasons.add('Multiple photos available');
        reasonsAr.add('صور متعددة متاحة');
      }

      if (property.virtualTourUrl != null) {
        score += 5;
        reasons.add('Virtual tour available');
        reasonsAr.add('جولة افتراضية متاحة');
      }

      final matchPercent = (score / 100 * 95).clamp(55.0, 98.0);

      String insight;
      String insightAr;
      if (matchPercent >= 90) {
        insight =
            'Excellent match! This property perfectly aligns with all your preferences.';
        insightAr =
            'تطابق ممتاز! هذا العقار يتوافق تماماً مع جميع تفضيلاتك.';
      } else if (matchPercent >= 75) {
        insight =
            'Great match! Most of your requirements are met with this property.';
        insightAr = 'تطابق جيد! معظم متطلباتك متوفرة في هذا العقار.';
      } else {
        insight =
            'Good option. Consider this property as an alternative within your budget.';
        insightAr =
            'خيار جيد. فكر في هذا العقار كبديل ضمن ميزانيتك.';
      }

      if (reasons.isNotEmpty) {
        scored.add(AIRecommendation(
          property: property,
          matchScore: matchPercent,
          matchReasons: reasons,
          matchReasonsAr: reasonsAr,
          aiInsight: insight,
          aiInsightAr: insightAr,
        ));
      }
    }

    scored.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return scored.take(count).toList();
  }

  List<AIRecommendation> _computeRecommendations(List<Property> allProperties, int count) {
    final scored = <AIRecommendation>[];
    for (final property in allProperties) {
      double score = 0;
      final reasons = <String>[];
      final reasonsAr = <String>[];
      if (_userPreference.preferredType != null && property.propertyType == _userPreference.preferredType) {
        score += 30; reasons.add('Matches your preferred property type'); reasonsAr.add('يطابق نوع العقار المفضل لديك');
      }
      if (_userPreference.preferredCity != null && (property.location?.contains(_userPreference.preferredCity!) == true)) {
        score += 25; reasons.add('Located in your preferred city'); reasonsAr.add('يقع في مدينتك المفضلة');
      }
      if (_userPreference.maxBudget != null && property.price <= _userPreference.maxBudget!) {
        final ratio = property.price / _userPreference.maxBudget!;
        if (ratio >= 0.6) { score += 20; reasons.add('Within your budget'); reasonsAr.add('ضمن ميزانيتك'); }
        else { score += 10; reasons.add('Below your budget'); reasonsAr.add('أقل من ميزانيتك'); }
      }
      if (reasons.isNotEmpty) {
        scored.add(AIRecommendation(
          property: property, matchScore: score,
          matchReasons: reasons, matchReasonsAr: reasonsAr,
          aiInsight: 'Good match', aiInsightAr: 'مطابقة جيدة',
        ));
      }
    }
    scored.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return scored.take(count).toList();
  }

  AIPriceAnalysis analyzePricing(Property property) {
    final allProps = _cachedProperties.isNotEmpty ? _cachedProperties : MockDataService.getProperties();
    final sameType = allProps
        .where((p) => p.propertyType == property.propertyType && p.id != property.id)
        .toList();

    double marketAvg = sameType.isEmpty
        ? property.price
        : sameType.map((p) => p.price).reduce((a, b) => a + b) /
            sameType.length;

    final pricePerSqm =
        property.area != null && property.area! > 0
            ? property.price / property.area!
            : 0.0;

    final variance = ((property.price - marketAvg) / marketAvg * 100);
    final String trend;
    final String trendAr;
    String insight;
    String insightAr;

    if (variance > 15) {
      trend = 'Overpriced';
      trendAr = 'مرتفع السعر';
      insight =
          'This property is priced ${variance.abs().toStringAsFixed(0)}% above market average. Consider negotiating.';
      insightAr =
          'هذا العقار مسعّر بـ${variance.abs().toStringAsFixed(0)}% فوق متوسط السوق. فكر في التفاوض.';
    } else if (variance < -10) {
      trend = 'Great Deal';
      trendAr = 'صفقة ممتازة';
      insight =
          'This property is ${variance.abs().toStringAsFixed(0)}% below market average — an excellent deal!';
      insightAr =
          'هذا العقار بـ${variance.abs().toStringAsFixed(0)}% أقل من متوسط السوق — صفقة ممتازة!';
    } else {
      trend = 'Fair Price';
      trendAr = 'سعر عادل';
      insight =
          'This property is fairly priced relative to similar properties in the area.';
      insightAr =
          'هذا العقار مسعّر بشكل عادل مقارنة بالعقارات المماثلة في المنطقة.';
    }

    final comparables = sameType.take(3).map((p) => {
          'title': p.title,
          'price': p.price,
          'area': p.area ?? 0,
          'location': p.location ?? '',
        }).toList();

    return AIPriceAnalysis(
      estimatedPrice: marketAvg,
      pricePerSqm: pricePerSqm,
      marketAverage: marketAvg,
      priceVariance: variance,
      trend: trend,
      trendAr: trendAr,
      insight: insight,
      insightAr: insightAr,
      comparables: comparables,
    );
  }

  AISearchResult smartSearch(String query) {
    final allProperties = _cachedProperties.isNotEmpty ? _cachedProperties : MockDataService.getProperties();
    final queryLower = query.toLowerCase();
    final filtered = <Property>[];

    for (final property in allProperties) {
      bool match = false;

      if (property.title.toLowerCase().contains(queryLower) ||
          (property.description.toLowerCase().contains(queryLower)) ||
          (property.location?.toLowerCase().contains(queryLower) == true)) {
        match = true;
      }

      if (queryLower.contains('فيلا') || queryLower.contains('villa')) {
        if (property.propertyType == 'villa') match = true;
      }
      if (queryLower.contains('شقة') || queryLower.contains('apartment')) {
        if (property.propertyType == 'apartment') match = true;
      }
      if (queryLower.contains('أرض') || queryLower.contains('land')) {
        if (property.propertyType == 'land') match = true;
      }
      if (queryLower.contains('رياض') || queryLower.contains('riyadh')) {
        if (property.location?.contains('الرياض') == true) match = true;
      }
      if (queryLower.contains('جدة') || queryLower.contains('jeddah')) {
        if (property.location?.contains('جدة') == true) match = true;
      }

      if (queryLower.contains('رخيص') ||
          queryLower.contains('cheap') ||
          queryLower.contains('اقتصادي')) {
        if (property.price < 500000) match = true;
      }
      if (queryLower.contains('فاخر') || queryLower.contains('luxury')) {
        if (property.price > 2000000) match = true;
      }

      if (match) filtered.add(property);
    }

    final suggestions = [
      'Villas with pool in Riyadh',
      'Apartments under 1M SAR',
      'Commercial spaces in Jeddah',
    ];
    final suggestionsAr = [
      'فلل مع مسبح في الرياض',
      'شقق بأقل من مليون ريال',
      'مساحات تجارية في جدة',
    ];

    return AISearchResult(
      properties: filtered.isEmpty ? allProperties.take(4).toList() : filtered,
      summary: filtered.isEmpty
          ? 'Showing all properties'
          : 'Found ${filtered.length} properties matching "$query"',
      summaryAr: filtered.isEmpty
          ? 'عرض جميع العقارات'
          : 'وجدنا ${filtered.length} عقارات تطابق "$query"',
      filters: {},
      suggestions: suggestions,
      suggestionsAr: suggestionsAr,
    );
  }

  List<Map<String, dynamic>> getMarketInsights() {
    return [
      {
        'titleAr': 'نمو السوق',
        'titleEn': 'Market Growth',
        'valueAr': '+12.5% هذا العام',
        'valueEn': '+12.5% This Year',
        'icon': 'trending_up',
        'color': 0xFF27AE60,
      },
      {
        'titleAr': 'متوسط سعر الفيلا',
        'titleEn': 'Avg Villa Price',
        'valueAr': '2.8M ريال',
        'valueEn': '2.8M SAR',
        'icon': 'villa',
        'color': 0xFF1A3A5C,
      },
      {
        'titleAr': 'أعلى طلب',
        'titleEn': 'Highest Demand',
        'valueAr': 'الرياض - الملقا',
        'valueEn': 'Riyadh - Malqa',
        'icon': 'location_on',
        'color': 0xFFE8963E,
      },
      {
        'titleAr': 'متوسط الإيجار',
        'titleEn': 'Avg Rental',
        'valueAr': '45K ريال/سنة',
        'valueEn': '45K SAR/yr',
        'icon': 'home',
        'color': 0xFF8E44AD,
      },
    ];
  }
}
