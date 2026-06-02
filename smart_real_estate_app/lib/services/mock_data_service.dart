import '../models/property_model.dart';
import '../models/review_model.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/contract_model.dart';

class MockDataService {
  static List<Property> getProperties() {
    return [
      Property(
        id: 1,
        ownerId: 2,
        title: 'فيلا فاخرة مع مسبح خاص',
        description:
            'فيلا مذهلة من 5 غرف نوم مع مسبح خاص وحديقة ونظام منزل ذكي. مثالية للعائلات الباحثة عن الفخامة والراحة. تتميز بتصميم معماري حديث وتشطيبات عالية الجودة.',
        price: 2500000,
        propertyType: 'villa',
        location: 'الرياض، الملقا',
        virtualTourUrl:
            'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop',
        images: [
          'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=600&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?q=80&w=600&auto=format&fit=crop',
        ],
        bedrooms: 5,
        bathrooms: 4,
        area: 450,
        status: 'available',
        ownerName: 'أحمد العمري',
        ownerPhone: '+966501234567',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Property(
        id: 2,
        ownerId: 2,
        title: 'شقة عصرية وسط المدينة',
        description:
            'شقة أنيقة وعصرية من غرفتين نوم في قلب المدينة. على مسافة قريبة من المراكز التجارية ووسائل النقل العام. مؤثثة بالكامل بأحدث التصاميم.',
        price: 850000,
        propertyType: 'apartment',
        location: 'جدة، البلد',
        virtualTourUrl:
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop',
        images: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=600&auto=format&fit=crop',
        ],
        bedrooms: 2,
        bathrooms: 2,
        area: 120,
        status: 'available',
        ownerName: 'محمد السعيد',
        ownerPhone: '+966507654321',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Property(
        id: 3,
        ownerId: 2,
        title: 'مكتب تجاري واسع',
        description:
            'مساحة مكتبية واسعة ومفتوحة مناسبة للشركات الناشئة أو الشركات القائمة. تتميز بإنترنت عالي السرعة ومواقف سيارات مخصصة وقاعة اجتماعات.',
        price: 120000,
        propertyType: 'commercial',
        location: 'الدمام، طريق الملك فهد',
        virtualTourUrl:
            'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=600&auto=format&fit=crop',
        images: [
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=600&auto=format&fit=crop',
        ],
        bedrooms: 0,
        bathrooms: 2,
        area: 200,
        status: 'available',
        ownerName: 'شركة النخبة العقارية',
        ownerPhone: '+966509876543',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Property(
        id: 4,
        ownerId: 2,
        title: 'تاون هاوس مريح في حي هادئ',
        description:
            'حي هادئ، 3 غرف نوم، 2.5 حمام، مطبخ مجدد بالكامل وفناء خلفي خاص. مثالي للعائلات الصغيرة مع مساحات خضراء محيطة.',
        price: 1150000,
        propertyType: 'villa',
        location: 'الرياض، الياسمين',
        virtualTourUrl:
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&auto=format&fit=crop',
        images: [
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600047509807-ba8f99d2cdde?q=80&w=600&auto=format&fit=crop',
        ],
        bedrooms: 3,
        bathrooms: 3,
        area: 280,
        status: 'available',
        ownerName: 'فهد الحربي',
        ownerPhone: '+966505551234',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Property(
        id: 5,
        ownerId: 2,
        title: 'بنتهاوس بإطلالة بحرية',
        description:
            'بنتهاوس حصري مع إطلالات بانورامية على البحر. يشمل مصعد خاص وشرفة على السطح مع جاكوزي. تشطيبات فاخرة من الرخام والخشب الطبيعي.',
        price: 4200000,
        propertyType: 'apartment',
        location: 'جدة، الكورنيش',
        virtualTourUrl:
            'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=600&auto=format&fit=crop',
        images: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=600&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=600&auto=format&fit=crop',
        ],
        bedrooms: 4,
        bathrooms: 3,
        area: 350,
        status: 'available',
        ownerName: 'عبدالله الراشد',
        ownerPhone: '+966508887654',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Property(
        id: 6,
        ownerId: 3,
        title: 'أرض سكنية في موقع مميز',
        description:
            'أرض سكنية بمساحة 600 متر مربع في موقع استراتيجي قريب من جميع الخدمات. مناسبة لبناء فيلا أو عمارة سكنية.',
        price: 750000,
        propertyType: 'land',
        location: 'الرياض، النرجس',
        virtualTourUrl:
            'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop',
        images: [
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=600&auto=format&fit=crop',
        ],
        bedrooms: 0,
        bathrooms: 0,
        area: 600,
        status: 'available',
        ownerName: 'سعد المالكي',
        ownerPhone: '+966503332211',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Property(
        id: 7,
        ownerId: 3,
        title: 'شقة مفروشة للإيجار',
        description:
            'شقة مفروشة بالكامل وجاهزة للسكن. تتميز بموقع ممتاز وقريبة من المواصلات والخدمات. مناسبة للعزاب أو العائلات الصغيرة.',
        price: 45000,
        propertyType: 'apartment',
        location: 'الخبر، الحزام الذهبي',
        virtualTourUrl:
            'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?q=80&w=600&auto=format&fit=crop',
        images: [
          'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?q=80&w=600&auto=format&fit=crop',
        ],
        bedrooms: 1,
        bathrooms: 1,
        area: 75,
        status: 'available',
        ownerName: 'خالد الدوسري',
        ownerPhone: '+966504445566',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Property(
        id: 8,
        ownerId: 3,
        title: 'قصر ملكي بتصميم فريد',
        description:
            'قصر ملكي بتصميم معماري فريد من نوعه. يضم 8 غرف نوم وصالة سينما خاصة وحمام سباحة داخلي وخارجي. محاط بحدائق واسعة.',
        price: 12000000,
        propertyType: 'villa',
        location: 'الرياض، حطين',
        virtualTourUrl:
            'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=600&auto=format&fit=crop',
        images: [
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?q=80&w=600&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?q=80&w=600&auto=format&fit=crop',
        ],
        bedrooms: 8,
        bathrooms: 6,
        area: 1200,
        status: 'available',
        ownerName: 'مؤسسة الفخامة العقارية',
        ownerPhone: '+966501112233',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  static List<Property> getRecommendedProperties() {
    final all = getProperties();
    return [all[0], all[4], all[3]];
  }

  static List<Review> getReviews(int propertyId) {
    return [
      Review(
        id: 1,
        userId: 1,
        propertyId: propertyId,
        rating: 5,
        comment: 'عقار ممتاز وموقع رائع. أنصح بشدة!',
        userName: 'سارة أحمد',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: 2,
        userId: 3,
        propertyId: propertyId,
        rating: 4,
        comment: 'تصميم جميل وتشطيبات عالية الجودة. السعر مناسب للمنطقة.',
        userName: 'عمر الشهري',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: 3,
        userId: 4,
        propertyId: propertyId,
        rating: 5,
        comment: 'تجربة رائعة في التعامل مع المالك. العقار كما في الوصف تماماً.',
        userName: 'نورة العتيبي',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
  }

  static List<ChatConversation> getConversations() {
    return [
      ChatConversation(
        userId: 2,
        userName: 'أحمد العمري',
        lastMessage: 'مرحباً، هل العقار لا يزال متاحاً؟',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        unreadCount: 2,
        propertyTitle: 'فيلا فاخرة مع مسبح خاص',
      ),
      ChatConversation(
        userId: 3,
        userName: 'محمد السعيد',
        lastMessage: 'شكراً لك، سأزور العقار غداً',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        propertyTitle: 'شقة عصرية وسط المدينة',
      ),
      ChatConversation(
        userId: 4,
        userName: 'فهد الحربي',
        lastMessage: 'هل يمكن التفاوض على السعر؟',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        unreadCount: 1,
        propertyTitle: 'تاون هاوس مريح في حي هادئ',
      ),
    ];
  }

  static List<ChatMessage> getMessages(int otherUserId) {
    return [
      ChatMessage(
        id: 1,
        senderId: otherUserId,
        receiverId: 1,
        message: 'مرحباً، أنا مهتم بالعقار المعروض',
        senderName: 'المستخدم',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 2,
        senderId: 1,
        receiverId: otherUserId,
        message: 'أهلاً وسهلاً! نعم العقار متاح. هل تود زيارته؟',
        senderName: 'أنت',
        createdAt:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      ChatMessage(
        id: 3,
        senderId: otherUserId,
        receiverId: 1,
        message: 'نعم أود ذلك. ما هي الأوقات المتاحة؟',
        senderName: 'المستخدم',
        createdAt:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      ChatMessage(
        id: 4,
        senderId: 1,
        receiverId: otherUserId,
        message: 'يمكنك الزيارة غداً من الساعة 4 إلى 8 مساءً',
        senderName: 'أنت',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatMessage(
        id: 5,
        senderId: otherUserId,
        receiverId: 1,
        message: 'ممتاز! سأكون هناك الساعة 5 مساءً إن شاء الله',
        senderName: 'المستخدم',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  static List<User> getAllUsers() {
    return [
      User(
          id: 1,
          name: 'Admin User',
          email: 'admin@aqari.com',
          role: 'admin',
          phone: '+966500000001'),
      User(
          id: 2,
          name: 'أحمد الملكي',
          email: 'ahmed@aqari.com',
          role: 'owner',
          phone: '+966500000002'),
      User(
          id: 3,
          name: 'سارة الزهراني',
          email: 'sara@aqari.com',
          role: 'buyer',
          phone: '+966500000003'),
      User(
          id: 4,
          name: 'فاطمة العتيبي',
          email: 'fatima@aqari.com',
          role: 'tenant',
          phone: '+966500000005'),
      User(
          id: 5,
          name: 'محمد البائع',
          email: 'seller@aqari.com',
          role: 'seller',
          phone: '+966500000006'),
      User(
          id: 6,
          name: 'شركة النخبة العقارية',
          email: 'agency@aqari.com',
          role: 'agency',
          phone: '+966500000007'),
    ];
  }

  static List<Contract> getContracts() {
    return [
      Contract(
        id: 1,
        propertyId: 1,
        propertyTitle: 'فيلا فاخرة مع مسبح خاص',
        propertyImage:
            'https://images.unsplash.com/photo-1613977257363-707ba9348227?q=80&w=600&auto=format&fit=crop',
        buyerId: 4,
        buyerName: 'فهد الحربي',
        sellerId: 2,
        sellerName: 'أحمد العمري',
        amount: 2500000,
        type: ContractType.sale,
        status: ContractStatus.signed,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        signedAt: DateTime.now().subtract(const Duration(days: 8)),
        contractNumber: 'CON-2024-001',
        buyerSigned: true,
        sellerSigned: true,
      ),
      Contract(
        id: 2,
        propertyId: 2,
        propertyTitle: 'شقة عصرية وسط المدينة',
        propertyImage:
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=600&auto=format&fit=crop',
        buyerId: 5,
        buyerName: 'سارة أحمد',
        sellerId: 3,
        sellerName: 'محمد السعيد',
        amount: 850000,
        type: ContractType.rent,
        status: ContractStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        contractNumber: 'CON-2024-002',
        buyerSigned: true,
        sellerSigned: false,
      ),
      Contract(
        id: 3,
        propertyId: 4,
        propertyTitle: 'تاون هاوس مريح في حي هادئ',
        propertyImage:
            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=600&auto=format&fit=crop',
        buyerId: 4,
        buyerName: 'فهد الحربي',
        sellerId: 2,
        sellerName: 'أحمد العمري',
        amount: 1150000,
        type: ContractType.sale,
        status: ContractStatus.expired,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        expiryDate: DateTime.now().subtract(const Duration(days: 30)),
        contractNumber: 'CON-2024-003',
      ),
    ];
  }

  static Contract getContractById(int id) {
    return getContracts().firstWhere((c) => c.id == id,
        orElse: () => getContracts().first);
  }

  static User getUserById(int id) {
    return getAllUsers().firstWhere((u) => u.id == id,
        orElse: () => getAllUsers().first);
  }

  static List<Review> getAgencyReviews(int agencyId) {
    return [
      Review(
        id: 101,
        userId: 4,
        agencyId: agencyId,
        rating: 5,
        comment: 'احترافية عالية وسرعة في الإنجاز',
        userName: 'فهد الحربي',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Review(
        id: 102,
        userId: 5,
        agencyId: agencyId,
        rating: 4,
        comment: 'خدمة جيدة جداً، طاقم العمل متعاون',
        userName: 'سارة أحمد',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  static List<Review> getOwnerReviews(int ownerId) {
    return [
      Review(
        id: 201,
        userId: 4,
        rating: 5,
        comment: 'مالك محترم جداً وواضح في التعامل',
        userName: 'فهد الحربي',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  static Map<String, dynamic> getDashboardStats() {
    return {
      'totalProperties': 8,
      'totalUsers': 6,
      'totalReviews': 15,
      'activeListings': 7,
      'soldProperties': 1,
      'monthlyViews': 1250,
      'monthlyInquiries': 48,
      'revenue': 350000,
    };
  }

  static List<Payment> getPayments() {
    return [
      Payment(
        id: 1,
        userId: 3,
        contractId: 1,
        propertyId: 1,
        propertyTitle: 'فيلا فاخرة مع مسبح خاص',
        amount: 2500000,
        status: PaymentStatus.completed,
        method: PaymentMethod.bankTransfer,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        transactionId: 'TXN-2024-001',
        description: 'دفعة شراء العقار - فيلا الملقا',
      ),
      Payment(
        id: 2,
        userId: 3,
        contractId: 2,
        propertyId: 2,
        propertyTitle: 'شقة عصرية وسط المدينة',
        amount: 42500,
        status: PaymentStatus.completed,
        method: PaymentMethod.creditCard,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        transactionId: 'TXN-2024-002',
        description: 'دفعة إيجار شهرية - شقة البلد جدة',
      ),
      Payment(
        id: 3,
        userId: 3,
        propertyId: 4,
        propertyTitle: 'فيلا الياسمين الراقية',
        amount: 750000,
        status: PaymentStatus.pending,
        method: PaymentMethod.stcPay,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        transactionId: 'TXN-2024-003',
        description: 'دفعة مقدمة - فيلا الياسمين',
      ),
      Payment(
        id: 4,
        userId: 3,
        propertyId: 5,
        propertyTitle: 'شقة كورنيش جدة',
        amount: 1200000,
        status: PaymentStatus.failed,
        method: PaymentMethod.creditCard,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        transactionId: 'TXN-2024-004',
        description: 'فشلت العملية - برجاء المحاولة مجدداً',
      ),
    ];
  }

  static Payment? getPaymentById(int id) {
    try {
      return getPayments().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}