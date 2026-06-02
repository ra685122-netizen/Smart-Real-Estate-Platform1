class Property {
  final int id;
  final int ownerId;
  final String title;
  final String description;
  final double price;
  final String? propertyType;
  final String? location;
  final String? virtualTourUrl;
  final List<String> images;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final String? status;
  final double? latitude;
  final double? longitude;
  final String? ownerName;
  final String? ownerPhone;
  final DateTime? createdAt;
  bool isFavorite;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    this.propertyType,
    this.location,
    this.virtualTourUrl,
    this.images = const [],
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.status = 'available',
    this.latitude,
    this.longitude,
    this.ownerName,
    this.ownerPhone,
    this.createdAt,
    this.isFavorite = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    List<String> imageList = [];
    if (json['images'] != null) {
      imageList = List<String>.from(json['images']);
    } else if (json['virtual_tour_url'] != null) {
      imageList = [json['virtual_tour_url']];
    }

    return Property(
      id: int.parse(json['id'].toString()),
      ownerId: int.parse(json['owner_id'].toString()),
      title: json['title'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      propertyType: json['property_type'],
      location: json['location'],
      virtualTourUrl: json['virtual_tour_url'],
      images: imageList,
      bedrooms: json['bedrooms'] != null
          ? int.tryParse(json['bedrooms'].toString())
          : null,
      bathrooms: json['bathrooms'] != null
          ? int.tryParse(json['bathrooms'].toString())
          : null,
      area: json['area'] != null
          ? double.tryParse(json['area'].toString())
          : null,
      status: json['status'] ?? 'available',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      ownerName: json['owner_name'],
      ownerPhone: json['owner_phone'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'property_type': propertyType,
      'location': location,
      'virtual_tour_url': virtualTourUrl,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get priceFormatted {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M SAR';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K SAR';
    }
    return '${price.toStringAsFixed(0)} SAR';
  }

  String get propertyTypeDisplay {
    switch (propertyType) {
      case 'villa':
        return 'فيلا';
      case 'apartment':
        return 'شقة';
      case 'commercial':
        return 'تجاري';
      case 'land':
        return 'أرض';
      case 'office':
        return 'مكتب';
      default:
        return propertyType ?? 'غير محدد';
    }
  }
}
