import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../models/chat_message_model.dart';
import '../models/review_model.dart';
import '../models/contract_model.dart';
import '../models/payment_model.dart';

class ApiService {
  static const String _apiPath =
      '/Smart%20Real%20Estate%20Platform1/php_backend/api';

  static String _serverHost = '';

  static String get _baseUrl => 'http://$_serverHost$_apiPath';

  static const Duration _timeout = Duration(seconds: 15);

  static bool _isConnected = false;
  static bool get isConnected => _isConnected;

  static String get _defaultHost {
    if (kIsWeb) return 'localhost:8888';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2:8888';
    return '10.0.2.2:8888';
  }

  static Future<void> checkConnection() async {
    if (_serverHost.isEmpty) _serverHost = _defaultHost;
    try {
      final response = await http
          .get(Uri.parse('http://$_serverHost$_apiPath/users/index.php?id=1'))
          .timeout(const Duration(seconds: 8));
      _isConnected = response.statusCode == 200;
      developer.log('Connection check: ${_isConnected ? "OK" : "FAIL"} ($response.statusCode)', name: 'ApiService');
    } catch (e) {
      _isConnected = false;
      developer.log('Connection check failed: $e', name: 'ApiService');
    }
  }

  static void setServerHost(String host) {
    _serverHost = host;
  }

  static final List<Map<String, dynamic>> _mockUsers = [
    {'id': 1, 'name': 'Admin User', 'email': 'admin@aqari.com', 'role': 'admin', 'password': 'password', 'password_alt': 'password123'},
    {'id': 2, 'name': 'Ahmed Al-Malki', 'email': 'ahmed@aqari.com', 'role': 'owner', 'password': 'password', 'password_alt': 'password123'},
    {'id': 3, 'name': 'Sara Al-Zahrani', 'email': 'sara@aqari.com', 'role': 'buyer', 'password': 'password', 'password_alt': 'password123'},
    {'id': 4, 'name': 'Fatima Al-Otaibi', 'email': 'fatima@aqari.com', 'role': 'tenant', 'password': 'password', 'password_alt': 'password123'},
    {'id': 5, 'name': 'Mohammed Seller', 'email': 'seller@aqari.com', 'role': 'seller', 'password': 'password', 'password_alt': 'password123'},
  ];

  // ─── Auth ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String email, String password) async {
    if (_serverHost.isEmpty) _serverHost = _defaultHost;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final user = User.fromJson(data['user']);
        final token = data['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', jsonEncode(user.toJson()));
        _isConnected = true;
        developer.log('Login success via API: ${user.email}', name: 'ApiService');
        return {'success': true, 'user': user};
      } else {
        _isConnected = false;
        return {'success': false, 'message': data['message'] ?? 'فشل تسجيل الدخول'};
      }
    } catch (e) {
      _isConnected = false;
      developer.log('API login failed (server unreachable): $e', name: 'ApiService');
      return {'success': false, 'message': 'تعذّر الاتصال بالخادم. تحقق من:\n• تشغيل MAMP\n• عنوان الخادم: $_serverHost'};
    }
  }

  static Future<Map<String, dynamic>> _offlineLogin(String email, String password) async {
    final mockUser = _mockUsers.firstWhere(
      (u) => u['email'] == email &&
             (u['password'] == password || u['password_alt'] == password),
      orElse: () => {},
    );
    if (mockUser.isEmpty) {
      return {'success': false, 'message': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'};
    }
    final user = User(
      id: mockUser['id'] as int,
      name: mockUser['name'] as String,
      email: mockUser['email'] as String,
      role: mockUser['role'] as String,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'offline_token_${user.id}');
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    developer.log('Offline login success: ${user.email}', name: 'ApiService');
    return {'success': true, 'user': user, 'offline': true};
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    if (_serverHost.isEmpty) _serverHost = _defaultHost;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email.trim(), 'password': password, 'role': role}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        _isConnected = true;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'فشل إنشاء الحساب'};
      }
    } catch (e) {
      return {'success': false, 'message': 'لا يوجد اتصال بالخادم. تحقق من الاتصال بالشبكة.'};
    }
  }

  // ─── Users ───────────────────────────────────────────────────────────────

  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/index.php')).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getAllUsers failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<User?> getUser(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/index.php?id=$id')).timeout(_timeout);
      if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log('getUser failed: $e', name: 'ApiService');
    }
    return null;
  }

  static Future<Map<String, dynamic>> updateUser(
    Map<String, dynamic> fields, {
    bool saveToSession = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fields),
      ).timeout(_timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['user'] != null) {
          final user = User.fromJson(data['user']);
          if (saveToSession) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_data', jsonEncode(user.toJson()));
          }
          return {'success': true, 'user': user};
        }
        return {'success': true};
      }
      return {'success': false, 'message': data['message'] ?? 'فشل التحديث'};
    } catch (e) {
      developer.log('updateUser failed: $e', name: 'ApiService');
      return {'success': false, 'message': 'لا يوجد اتصال بالخادم'};
    }
  }

  static Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/users/index.php?id=$id')).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ─── Properties ──────────────────────────────────────────────────────────

  static Future<List<Property>> getProperties({String? type, String? location}) async {
    try {
      final params = <String, String>{};
      if (type != null && type.isNotEmpty) params['type'] = type;
      if (location != null && location.isNotEmpty) params['location'] = location;
      final uri = Uri.parse('$_baseUrl/properties/index.php')
          .replace(queryParameters: params.isNotEmpty ? params : null);
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _isConnected = true;
        return list.map((e) => Property.fromJson(e)).toList();
      }
    } catch (e) {
      _isConnected = false;
      developer.log('getProperties failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<List<Property>> getRecommendedProperties() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/properties/recommend.php')).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Property.fromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getRecommended failed: $e', name: 'ApiService');
    }
    return getProperties();
  }

  static Future<Property?> getProperty(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/properties/single.php?id=$id')).timeout(_timeout);
      if (response.statusCode == 200) return Property.fromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log('getProperty failed: $e', name: 'ApiService');
    }
    return null;
  }

  static Future<List<Property>> getMyProperties(int ownerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/properties/index.php?owner_id=$ownerId'),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Property.fromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getMyProperties failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<Map<String, dynamic>> addProperty(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/properties/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(_timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode == 201) return {'success': true, 'id': body['id']};
      return {'success': false, 'message': body['message'] ?? 'فشل إضافة العقار'};
    } catch (e) {
      return {'success': false, 'message': 'لا يوجد اتصال بالخادم'};
    }
  }

  static Future<bool> updateProperty(int id, Map<String, dynamic> data) async {
    try {
      final payload = Map<String, dynamic>.from(data)..['id'] = id;
      final response = await http.put(
        Uri.parse('$_baseUrl/properties/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      developer.log('updateProperty failed: $e', name: 'ApiService');
      return false;
    }
  }

  static Future<bool> deleteMyProperty(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/properties/index.php?id=$id'),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      developer.log('deleteMyProperty failed: $e', name: 'ApiService');
      return false;
    }
  }

  static Future<List<Property>> getAdminProperties() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/properties.php')).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Property.fromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getAdminProperties failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<bool> updatePropertyAdmin(int id, Map<String, dynamic> fields) async {
    try {
      final payload = Map<String, dynamic>.from(fields)..['id'] = id;
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/properties.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteProperty(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/admin/properties.php?id=$id')).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ─── Reviews ─────────────────────────────────────────────────────────────

  static Future<List<Review>> getReviews({int? propertyId, int? agencyId}) async {
    try {
      String url = '$_baseUrl/reviews/index.php?';
      if (propertyId != null) url += 'property_id=$propertyId';
      if (agencyId != null) url += 'agency_id=$agencyId';
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Review.fromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getReviews failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<Map<String, dynamic>> addReview({
    required int userId,
    required int rating,
    String? comment,
    int? propertyId,
    int? agencyId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reviews/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'rating': rating,
          'comment': comment ?? '',
          if (propertyId != null) 'property_id': propertyId,
          if (agencyId != null) 'agency_id': agencyId,
        }),
      ).timeout(_timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) return {'success': true, 'review': Review.fromJson(data)};
      return {'success': false, 'message': data['message'] ?? 'فشل إضافة التقييم'};
    } catch (e) {
      return {'success': false, 'message': 'لا يوجد اتصال بالخادم'};
    }
  }

  static Future<bool> deleteReview(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/reviews/index.php?id=$id')).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ─── Chat ────────────────────────────────────────────────────────────────

  static Future<List<ChatConversation>> getConversations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/conversations.php?user_id=$userId'),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => ChatMessage.conversationFromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getConversations failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<int?> getOrCreateConversation(int userId, int otherUserId, {int? propertyId}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/conversations.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'other_user_id': otherUserId,
          if (propertyId != null) 'property_id': propertyId,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['conversation_id'] as int?;
      }
    } catch (e) {
      developer.log('getOrCreateConversation failed: $e', name: 'ApiService');
    }
    return null;
  }

  static Future<List<ChatMessage>> getMessages(int conversationId, int currentUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/messages.php?conversation_id=$conversationId&user_id=$currentUserId'),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => ChatMessage.fromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getMessages failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<ChatMessage?> sendMessage(int conversationId, int senderId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conversation_id': conversationId,
          'sender_id': senderId,
          'message': message,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 201) {
        return ChatMessage.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      developer.log('sendMessage failed: $e', name: 'ApiService');
    }
    return null;
  }

  // ─── Favorites ───────────────────────────────────────────────────────────

  static Future<List<Property>> getFavorites(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/favorites/index.php?user_id=$userId'),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Property.fromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getFavorites failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<bool> toggleFavorite(int userId, int propertyId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/favorites/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'property_id': propertyId}),
      ).timeout(_timeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ─── Notifications ───────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/index.php?user_id=$userId'),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      developer.log('getNotifications failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<void> markNotificationsRead(int userId) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/notifications/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      ).timeout(_timeout);
    } catch (_) {}
  }

  static Future<void> sendPaymentNotifications({
    required int buyerId,
    required int sellerId,
    required double amount,
    required String propertyTitle,
    required String transactionId,
    String buyerName = '',
    String sellerName = '',
  }) async {
    final amountStr = amount.toStringAsFixed(0);
    final buyerDisplay = buyerName.isNotEmpty ? buyerName : 'المستخدم #$buyerId';
    final notifications = [
      {
        'user_id': buyerId,
        'title': 'تم خصم المبلغ | Amount Deducted',
        'body': 'تم خصم $amountStr ريال من رصيدك مقابل شراء: $propertyTitle\nرقم المعاملة: $transactionId',
        'type': 'payment',
        'ref_id': transactionId,
      },
      {
        'user_id': sellerId,
        'title': 'تم استلام دفعة | Payment Received',
        'body': 'تم إيداع $amountStr ريال من $buyerDisplay مقابل بيع: $propertyTitle\nرقم المعاملة: $transactionId',
        'type': 'payment',
        'ref_id': transactionId,
      },
      {
        'user_id': 1,
        'title': 'دفعة جديدة | New Payment',
        'body': 'قام $buyerDisplay بدفع $amountStr ريال مقابل: $propertyTitle\nرقم المعاملة: $transactionId',
        'type': 'payment',
        'ref_id': transactionId,
      },
    ];
    for (final notif in notifications) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/notifications/index.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(notif),
        ).timeout(_timeout);
      } catch (_) {}
    }
  }

  static Future<List<Payment>> getAllPayments() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/index.php'),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => _paymentFromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getAllPayments failed: $e', name: 'ApiService');
    }
    return _mockPayments();
  }

  static List<Payment> _mockPayments() {
    return [
      Payment(id: 1, userId: 2, propertyTitle: 'فيلا للإيجار في جدة', amount: 180000, status: PaymentStatus.completed, method: PaymentMethod.creditCard, createdAt: DateTime.now().subtract(const Duration(days: 2)), transactionId: 'TXN-100001'),
      Payment(id: 2, userId: 3, propertyTitle: 'شقة فندقية فاخرة', amount: 1200000, status: PaymentStatus.completed, method: PaymentMethod.bankTransfer, createdAt: DateTime.now().subtract(const Duration(days: 5)), transactionId: 'TXN-100002'),
      Payment(id: 3, userId: 2, propertyTitle: 'أرض تجارية الرياض', amount: 500000, status: PaymentStatus.pending, method: PaymentMethod.stcPay, createdAt: DateTime.now().subtract(const Duration(days: 1)), transactionId: 'TXN-100003'),
      Payment(id: 4, userId: 4, propertyTitle: 'شقة عصرية جدة', amount: 350000, status: PaymentStatus.completed, method: PaymentMethod.creditCard, createdAt: DateTime.now().subtract(const Duration(days: 10)), transactionId: 'TXN-100004'),
      Payment(id: 5, userId: 5, propertyTitle: 'فيلا الدرعية', amount: 2500000, status: PaymentStatus.refunded, method: PaymentMethod.bankTransfer, createdAt: DateTime.now().subtract(const Duration(days: 15)), transactionId: 'TXN-100005'),
    ];
  }

  // ─── Admin ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/stats.php')).timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      developer.log('getAdminStats failed: $e', name: 'ApiService');
    }
    return {
      'totalProperties': 0, 'activeListings': 0, 'totalUsers': 0,
      'totalReviews': 0, 'soldProperties': 0, 'monthlyViews': 0,
      'monthlyInquiries': 0, 'revenue': 0,
    };
  }

  // ─── Contracts ───────────────────────────────────────────────────────────

  static Future<List<Contract>> getContracts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/contracts/index.php?user_id=$userId'),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => _contractFromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getContracts failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<Contract?> getContractById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/contracts/index.php?id=$id'),
      ).timeout(_timeout);
      if (response.statusCode == 200) return _contractFromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log('getContractById failed: $e', name: 'ApiService');
    }
    return null;
  }

  static Future<Map<String, dynamic>> createContract(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/contracts/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(_timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode == 201) return {'success': true, 'contract': _contractFromJson(body)};
      return {'success': false, 'message': body['message'] ?? 'فشل إنشاء العقد'};
    } catch (e) {
      return {'success': false, 'message': 'لا يوجد اتصال بالخادم'};
    }
  }

  static Future<bool> signContract(int contractId, int userId, String role, String signatureB64) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/contracts/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': contractId,
          'sign': true,
          'user_id': userId,
          'role': role,
          'signature_b64': signatureB64,
        }),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      developer.log('signContract failed: $e', name: 'ApiService');
      return false;
    }
  }

  static Future<bool> deleteContract(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/contracts/index.php?id=$id'),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Contract _contractFromJson(Map<String, dynamic> j) {
    ContractType type;
    switch (j['type']) {
      case 'rent':
        type = ContractType.rent;
        break;
      case 'agency':
        type = ContractType.agency;
        break;
      default:
        type = ContractType.sale;
    }
    ContractStatus status;
    switch (j['status']) {
      case 'signed':
        status = ContractStatus.signed;
        break;
      case 'expired':
        status = ContractStatus.expired;
        break;
      case 'cancelled':
        status = ContractStatus.cancelled;
        break;
      case 'under_review':
        status = ContractStatus.underReview;
        break;
      default:
        status = ContractStatus.pending;
    }
    return Contract(
      id: j['id'] as int,
      propertyId: j['property_id'] as int,
      propertyTitle: j['property_title'] ?? '',
      propertyImage: j['property_image'] ?? '',
      buyerId: j['buyer_id'] as int,
      buyerName: j['buyer_name'] ?? '',
      sellerId: j['seller_id'] as int,
      sellerName: j['seller_name'] ?? '',
      amount: (j['amount'] as num).toDouble(),
      type: type,
      status: status,
      contractNumber: j['contract_number'] ?? '',
      buyerSigned: j['buyer_signed'] == true || j['buyer_signed'] == 1,
      sellerSigned: j['seller_signed'] == true || j['seller_signed'] == 1,
      notes: j['notes'],
      signedAt: j['signed_at'] != null ? DateTime.tryParse(j['signed_at']) : null,
      expiryDate: j['expiry_date'] != null ? DateTime.tryParse(j['expiry_date']) : null,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // ─── Payments ────────────────────────────────────────────────────────────

  static Future<List<Payment>> getPayments(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/index.php?user_id=$userId'),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => _paymentFromJson(e)).toList();
      }
    } catch (e) {
      developer.log('getPayments failed: $e', name: 'ApiService');
    }
    return [];
  }

  static Future<Map<String, dynamic>> processPayment({
    required int payerId,
    required int payeeId,
    required double amount,
    required String method,
    int? propertyId,
    int? contractId,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/index.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payer_id': payerId,
          'payee_id': payeeId,
          'amount': amount,
          'method': method,
          if (propertyId != null) 'property_id': propertyId,
          if (contractId != null) 'contract_id': contractId,
          if (notes != null) 'notes': notes,
        }),
      ).timeout(_timeout);
      final body = jsonDecode(response.body);
      if (response.statusCode == 201) return {'success': true, 'payment': _paymentFromJson(body)};
      return {'success': false, 'message': body['message'] ?? 'فشلت عملية الدفع'};
    } catch (e) {
      developer.log('processPayment failed: $e', name: 'ApiService');
      return {'success': false, 'message': 'لا يوجد اتصال بالخادم'};
    }
  }

  static Payment _paymentFromJson(Map<String, dynamic> j) {
    PaymentStatus status;
    switch (j['status']) {
      case 'completed':
        status = PaymentStatus.completed;
        break;
      case 'failed':
        status = PaymentStatus.failed;
        break;
      case 'refunded':
        status = PaymentStatus.refunded;
        break;
      default:
        status = PaymentStatus.pending;
    }
    PaymentMethod method;
    switch (j['method']) {
      case 'bank_transfer':
        method = PaymentMethod.bankTransfer;
        break;
      case 'stc_pay':
        method = PaymentMethod.stcPay;
        break;
      case 'apple_pay':
        method = PaymentMethod.applePay;
        break;
      case 'qr_code':
        method = PaymentMethod.qrCode;
        break;
      default:
        method = PaymentMethod.creditCard;
    }
    return Payment(
      id: j['id'] as int,
      userId: j['payer_id'] as int,
      contractId: j['contract_id'] as int?,
      propertyId: j['property_id'] as int?,
      propertyTitle: j['property_title'] ?? '',
      amount: (j['amount'] as num).toDouble(),
      status: status,
      method: method,
      transactionId: j['transaction_id'] ?? '',
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
