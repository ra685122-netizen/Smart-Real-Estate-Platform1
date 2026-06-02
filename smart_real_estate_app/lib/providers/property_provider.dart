import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/property_model.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../services/ai_service.dart';

class PropertyProvider extends ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _recommendedProperties = [];
  List<Property> _myProperties = [];
  List<Property> _favoriteProperties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = false;
  String? _error;
  bool _usingMockData = false;

  bool get usingMockData => _usingMockData;
  String _searchQuery = '';
  String? _selectedType;
  String? _selectedLocation;
  double? _minPrice;
  double? _maxPrice;

  List<Property> get properties =>
      _filteredProperties.isNotEmpty || _searchQuery.isNotEmpty || _selectedType != null
          ? _filteredProperties
          : _properties;
  List<Property> get allProperties => _properties;
  List<Property> get recommendedProperties => _recommendedProperties;
  List<Property> get myProperties => _myProperties;
  List<Property> get favoriteProperties => _favoriteProperties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.getProperties(),
        ApiService.getRecommendedProperties(),
      ]);
      final apiProperties = results[0];
      final apiRecommended = results[1];

      if (apiProperties.isNotEmpty) {
        _properties = apiProperties;
        _recommendedProperties = apiRecommended.isNotEmpty
            ? apiRecommended
            : apiProperties.where((p) => p.images.isNotEmpty).take(5).toList();
        _usingMockData = false;
        AIService().updateCachedProperties(_properties);
        developer.log('Loaded ${_properties.length} properties from API', name: 'PropertyProvider');
      } else {
        _properties = MockDataService.getProperties();
        _recommendedProperties = _properties.take(4).toList();
        _usingMockData = true;
        AIService().updateCachedProperties(_properties);
        developer.log('API unavailable - using mock data (${_properties.length} properties)', name: 'PropertyProvider');
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _properties = MockDataService.getProperties();
      _recommendedProperties = _properties.take(4).toList();
      _usingMockData = true;
      _error = null;
      _isLoading = false;
      developer.log('Error loading properties, using mock data: $e', name: 'PropertyProvider');
      notifyListeners();
    }
  }

  Future<void> loadMyProperties(int ownerId) async {
    final apiProps = await ApiService.getMyProperties(ownerId);
    if (apiProps.isNotEmpty) {
      _myProperties = apiProps;
    } else {
      _myProperties = _properties.where((p) => p.ownerId == ownerId).toList();
    }
    notifyListeners();
  }

  Future<void> loadFavorites(int userId) async {
    final apiProps = await ApiService.getFavorites(userId);
    if (apiProps.isNotEmpty) {
      for (final p in _properties) {
        p.isFavorite = apiProps.any((f) => f.id == p.id);
      }
      _favoriteProperties = apiProps;
      notifyListeners();
    }
  }

  void toggleFavorite(Property property, {int? userId}) {
    property.isFavorite = !property.isFavorite;
    if (property.isFavorite) {
      if (!_favoriteProperties.any((p) => p.id == property.id)) {
        _favoriteProperties.add(property);
      }
    } else {
      _favoriteProperties.removeWhere((p) => p.id == property.id);
    }
    notifyListeners();
    if (userId != null) {
      ApiService.toggleFavorite(userId, property.id);
    }
  }

  void searchProperties(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByType(String? type) {
    _selectedType = type;
    _applyFilters();
  }

  void filterByPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
  }

  void filterByLocation(String? location) {
    _selectedLocation = location;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedLocation = null;
    _minPrice = null;
    _maxPrice = null;
    _filteredProperties = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProperties = _properties.where((p) {
      bool matches = true;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        matches = matches &&
            (p.title.toLowerCase().contains(q) ||
                (p.location?.toLowerCase().contains(q) ?? false) ||
                (p.propertyType?.toLowerCase().contains(q) ?? false) ||
                p.description.toLowerCase().contains(q));
      }

      if (_selectedType != null) {
        matches = matches && p.propertyType == _selectedType;
      }

      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        matches = matches &&
            (p.location
                    ?.toLowerCase()
                    .contains(_selectedLocation!.toLowerCase()) ??
                false);
      }

      if (_minPrice != null) {
        matches = matches && p.price >= _minPrice!;
      }

      if (_maxPrice != null) {
        matches = matches && p.price <= _maxPrice!;
      }

      return matches;
    }).toList();

    notifyListeners();
  }

  Future<bool> addPropertyApi(Map<String, dynamic> data) async {
    final result = await ApiService.addProperty(data);
    if (result['success'] == true) {
      final ownerId = data['owner_id'] as int?;
      if (ownerId != null) await loadMyProperties(ownerId);
      await loadProperties();
      return true;
    }
    return false;
  }

  Future<bool> updatePropertyApi(int id, Map<String, dynamic> data, {int? ownerId}) async {
    final ok = await ApiService.updateProperty(id, data);
    if (ok) {
      if (ownerId != null) await loadMyProperties(ownerId);
      await loadProperties();
    }
    return ok;
  }

  Future<bool> deletePropertyApi(int id, {int? ownerId}) async {
    final ok = await ApiService.deleteMyProperty(id);
    if (ok) {
      _properties.removeWhere((p) => p.id == id);
      _myProperties.removeWhere((p) => p.id == id);
      notifyListeners();
    }
    return ok;
  }

  void addProperty(Property property) {
    _properties.insert(0, property);
    _myProperties.insert(0, property);
    notifyListeners();
  }

  void updateProperty(Property property) {
    final idx = _properties.indexWhere((p) => p.id == property.id);
    if (idx != -1) _properties[idx] = property;
    final myIdx = _myProperties.indexWhere((p) => p.id == property.id);
    if (myIdx != -1) _myProperties[myIdx] = property;
    notifyListeners();
  }

  void deleteProperty(int id) {
    _properties.removeWhere((p) => p.id == id);
    _myProperties.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
