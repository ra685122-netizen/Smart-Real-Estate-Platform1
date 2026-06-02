class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? avatar;
  final String? bio;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    this.bio,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'tenant',
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? avatar,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      createdAt: createdAt,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case 'tenant':
        return 'مستأجر';
      case 'buyer':
        return 'مشتري';
      case 'seller':
        return 'بائع';
      case 'owner':
        return 'مالك';
      case 'agency':
        return 'وكالة عقارية';
      case 'admin':
        return 'مدير النظام';
      default:
        return role;
    }
  }
}
