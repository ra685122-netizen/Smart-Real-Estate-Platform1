class Review {
  final int id;
  final int userId;
  final int? propertyId;
  final int? agencyId;
  final int rating;
  final String? comment;
  final String? userName;
  final String? userAvatar;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.userId,
    this.propertyId,
    this.agencyId,
    required this.rating,
    this.comment,
    this.userName,
    this.userAvatar,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      propertyId: json['property_id'] != null
          ? int.tryParse(json['property_id'].toString())
          : null,
      agencyId: json['agency_id'] != null
          ? int.tryParse(json['agency_id'].toString())
          : null,
      rating: int.parse(json['rating'].toString()),
      comment: json['comment'],
      userName: json['user_name'],
      userAvatar: json['user_avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'property_id': propertyId,
      'agency_id': agencyId,
      'rating': rating,
      'comment': comment,
    };
  }
}
