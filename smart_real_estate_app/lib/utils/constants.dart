import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'عقاري';
  static const String appNameEn = 'Aqari';
  static const String appTagline = 'منصتك الذكية للعقارات';
  static const String appTaglineEn = 'Your Smart Real Estate Platform';
  static const String googleMapsApiKey = 'AIzaSyBZYzYb56y3eETSYzNQ-YmKhgAxNCNrgGU';
  static const String logoUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRclVEzIWpKWrsIfUigT0PvLTA_xJWsMp5Frw&s';

  static const List<String> propertyTypes = [
    'villa',
    'apartment',
    'commercial',
    'land',
    'office',
    'chalet',
    'farm',
    'building',
  ];

  static const Map<String, String> propertyTypeLabels = {
    'villa': 'فيلا',
    'apartment': 'شقة',
    'commercial': 'تجاري',
    'land': 'أرض',
    'office': 'مكتب',
    'chalet': 'شاليه',
    'farm': 'مزرعة',
    'building': 'عمارة',
  };

  static const Map<String, String> propertyTypeLabelsEn = {
    'villa': 'Villa',
    'apartment': 'Apartment',
    'commercial': 'Commercial',
    'land': 'Land',
    'office': 'Office',
    'chalet': 'Chalet',
    'farm': 'Farm',
    'building': 'Building',
  };

  static const Map<String, IconData> propertyTypeIcons = {
    'villa': Icons.villa,
    'apartment': Icons.apartment,
    'commercial': Icons.store,
    'land': Icons.landscape,
    'office': Icons.business,
    'chalet': Icons.cabin,
    'farm': Icons.agriculture,
    'building': Icons.domain,
  };

  static const List<String> saudiCities = [
    'الرياض',
    'جدة',
    'الدمام',
    'الخبر',
    'مكة المكرمة',
    'المدينة المنورة',
    'الطائف',
    'تبوك',
    'أبها',
    'جازان',
    'نجران',
    'حائل',
    'القصيم',
    'الجوف',
    'ينبع',
    'الأحساء',
  ];

  static const Map<String, double> cityLatitudes = {
    'الرياض': 24.7136,
    'جدة': 21.5433,
    'الدمام': 26.3927,
    'الخبر': 26.2172,
    'مكة المكرمة': 21.3891,
    'المدينة المنورة': 24.5247,
    'الطائف': 21.2854,
    'تبوك': 28.3835,
    'أبها': 18.2164,
    'جازان': 16.8892,
  };

  static const Map<String, double> cityLongitudes = {
    'الرياض': 46.6753,
    'جدة': 39.1728,
    'الدمام': 49.9777,
    'الخبر': 50.1971,
    'مكة المكرمة': 39.8579,
    'المدينة المنورة': 39.5692,
    'الطائف': 40.4145,
    'تبوك': 36.5662,
    'أبها': 42.5053,
    'جازان': 42.5511,
  };

  static const List<String> roles = [
    'tenant',
    'buyer',
    'seller',
    'owner',
    'agency',
  ];

  static const Map<String, String> roleLabels = {
    'tenant': 'مستأجر',
    'buyer': 'مشتري',
    'seller': 'بائع',
    'owner': 'مالك',
    'agency': 'وكالة عقارية',
    'admin': 'مدير النظام',
  };

  static const Map<String, String> roleLabelsEn = {
    'tenant': 'Tenant',
    'buyer': 'Buyer',
    'seller': 'Seller',
    'owner': 'Owner',
    'agency': 'Agency',
    'admin': 'Admin',
  };

  static const Map<String, IconData> roleIcons = {
    'tenant': Icons.person,
    'buyer': Icons.shopping_cart,
    'seller': Icons.sell,
    'owner': Icons.home_work,
    'agency': Icons.business,
    'admin': Icons.admin_panel_settings,
  };

  static const Map<String, String> amenitiesAr = {
    'pool': 'مسبح',
    'gym': 'صالة رياضية',
    'parking': 'موقف سيارات',
    'elevator': 'مصعد',
    'security': 'أمن وحراسة',
    'garden': 'حديقة',
    'balcony': 'شرفة',
    'smart_home': 'منزل ذكي',
    'central_ac': 'تكييف مركزي',
    'storage': 'مستودع',
    'maid_room': 'غرفة خادمة',
    'driver_room': 'غرفة سائق',
    'mosque': 'مسجد',
    'kids_area': 'منطقة أطفال',
    'jacuzzi': 'جاكوزي',
    'bbq': 'منطقة شواء',
  };

  static const Map<String, String> amenitiesEn = {
    'pool': 'Swimming Pool',
    'gym': 'Gym',
    'parking': 'Parking',
    'elevator': 'Elevator',
    'security': 'Security',
    'garden': 'Garden',
    'balcony': 'Balcony',
    'smart_home': 'Smart Home',
    'central_ac': 'Central A/C',
    'storage': 'Storage',
    'maid_room': 'Maid Room',
    'driver_room': 'Driver Room',
    'mosque': 'Mosque',
    'kids_area': 'Kids Area',
    'jacuzzi': 'Jacuzzi',
    'bbq': 'BBQ Area',
  };

  static const Map<String, IconData> amenitiesIcons = {
    'pool': Icons.pool,
    'gym': Icons.fitness_center,
    'parking': Icons.local_parking,
    'elevator': Icons.elevator,
    'security': Icons.security,
    'garden': Icons.park,
    'balcony': Icons.balcony,
    'smart_home': Icons.home_filled,
    'central_ac': Icons.ac_unit,
    'storage': Icons.inventory,
    'maid_room': Icons.bedroom_parent,
    'driver_room': Icons.directions_car,
    'mosque': Icons.mosque,
    'kids_area': Icons.child_care,
    'jacuzzi': Icons.hot_tub,
    'bbq': Icons.outdoor_grill,
  };
}
