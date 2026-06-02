import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  // App
  String get appName => isArabic ? 'عقاري' : 'Aqari';
  String get appTagline =>
      isArabic ? 'منصتك الذكية للعقارات' : 'Your Smart Real Estate Platform';
  String get appVersion => isArabic ? 'الإصدار 2.0.0' : 'Version 2.0.0';

  // Auth
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get register => isArabic ? 'إنشاء حساب' : 'Create Account';
  String get welcomeBack => isArabic ? 'مرحباً بعودتك' : 'Welcome Back';
  String get loginSubtitle =>
      isArabic ? 'سجل دخولك للمتابعة' : 'Sign in to continue';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get confirmPassword =>
      isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get forgotPassword =>
      isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get noAccount =>
      isArabic ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get haveAccount =>
      isArabic ? 'لديك حساب بالفعل؟' : 'Already have an account?';
  String get registerNow => isArabic ? 'سجل الآن' : 'Register Now';
  String get loginNow => isArabic ? 'سجل الدخول' : 'Login Now';
  String get quickDemo => isArabic ? 'تجربة سريعة' : 'Quick Demo';
  String get fullName => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get phone => isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get accountType => isArabic ? 'نوع الحساب' : 'Account Type';
  String get acceptTerms =>
      isArabic
          ? 'أوافق على الشروط والأحكام وسياسة الخصوصية'
          : 'I agree to Terms & Conditions and Privacy Policy';
  String get createAccount => isArabic ? 'إنشاء الحساب' : 'Create Account';
  String get orLoginWith => isArabic ? 'أو سجل باستخدام' : 'Or login with';
  String get guest => isArabic ? 'تصفح كزائر' : 'Browse as Guest';
  String get continueWithGoogle =>
      isArabic ? 'متابعة مع Google' : 'Continue with Google';
  String get continueWithApple =>
      isArabic ? 'متابعة مع Apple' : 'Continue with Apple';
  String get signIn => isArabic ? 'دخول' : 'Sign In';
  String get signUp => isArabic ? 'إنشاء حساب' : 'Sign Up';
  String get biometricLogin =>
      isArabic ? 'تسجيل بالبصمة' : 'Use Touch ID / Face ID';
  String get rememberMe => isArabic ? 'تذكرني' : 'Remember me';
  String get termsAndConditions =>
      isArabic ? 'الشروط والأحكام' : 'Terms & Conditions';
  String get allowTerms =>
      isArabic ? 'السماح بالشروط والأحكام' : 'Allow Terms & Conditions';

  // Navigation
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get search => isArabic ? 'البحث' : 'Search';
  String get favorites => isArabic ? 'المفضلة' : 'Favorites';
  String get chat => isArabic ? 'المحادثات' : 'Chat';
  String get profile => isArabic ? 'حسابي' : 'My Account';

  // Home
  String get marketplace => isArabic ? 'سوق العقارات' : 'Real Estate Market';
  String get featuredProperties =>
      isArabic ? 'عقارات مميزة' : 'Featured Properties';
  String get latestProperties =>
      isArabic ? 'أحدث العقارات' : 'Latest Properties';
  String get aiRecommendations =>
      isArabic ? 'توصيات الذكاء الاصطناعي' : 'AI Recommendations';
  String get viewAll => isArabic ? 'عرض الكل' : 'View All';
  String get searchHint =>
      isArabic ? 'ابحث عن عقار، مدينة، حي...' : 'Search property, city...';
  String get findDreamHome =>
      isArabic ? 'اعثر على منزل أحلامك' : 'Find Your Dream Home';
  String helloUser(String name) =>
      isArabic ? 'مرحباً، $name' : 'Hello, $name';
  String get exploreMap => isArabic ? 'استكشف على الخريطة' : 'Explore on Map';
  String get quickFilters => isArabic ? 'فلاتر سريعة' : 'Quick Filters';
  String get allProperties => isArabic ? 'جميع العقارات' : 'All Properties';
  String get newListings => isArabic ? 'قوائم جديدة' : 'New Listings';
  String get nearMe => isArabic ? 'قريب مني' : 'Near Me';
  String get forSale => isArabic ? 'للبيع' : 'For Sale';
  String get forRent => isArabic ? 'للإيجار' : 'For Rent';
  String get marketInsights => isArabic ? 'رؤى السوق' : 'Market Insights';
  String get aiPowered => isArabic ? 'بتقنية الذكاء الاصطناعي' : 'AI Powered';

  // Search
  String get searchProperty =>
      isArabic ? 'البحث عن عقار' : 'Search Properties';
  String get filterResults => isArabic ? 'تصفية النتائج' : 'Filter Results';
  String get propertyType => isArabic ? 'نوع العقار' : 'Property Type';
  String get city => isArabic ? 'المدينة' : 'City';
  String get priceRange => isArabic ? 'نطاق السعر' : 'Price Range';
  String get applyFilter => isArabic ? 'تطبيق الفلتر' : 'Apply Filter';
  String get reset => isArabic ? 'إعادة تعيين' : 'Reset';
  String get noResults => isArabic ? 'لا توجد نتائج' : 'No Results';
  String get tryDifferent =>
      isArabic ? 'جرب تغيير معايير البحث' : 'Try different search criteria';
  String get aiSearch =>
      isArabic ? 'بحث بالذكاء الاصطناعي' : 'AI-Powered Search';
  String get aiSearchHint =>
      isArabic
          ? 'اكتب ما تبحث عنه بلغة طبيعية...'
          : 'Describe what you\'re looking for...';
  String get smartFilter => isArabic ? 'فلتر ذكي' : 'Smart Filter';
  String get sortBy => isArabic ? 'ترتيب حسب' : 'Sort By';
  String get priceLowHigh => isArabic ? 'السعر: من الأرخص' : 'Price: Low to High';
  String get priceHighLow => isArabic ? 'السعر: من الأعلى' : 'Price: High to Low';
  String get newest => isArabic ? 'الأحدث' : 'Newest';
  String get mostPopular => isArabic ? 'الأكثر شعبية' : 'Most Popular';
  String get minBedrooms => isArabic ? 'الحد الأدنى للغرف' : 'Min Bedrooms';
  String get maxPrice => isArabic ? 'أقصى سعر' : 'Max Price';
  String get minPrice => isArabic ? 'أدنى سعر' : 'Min Price';
  String get areaRange => isArabic ? 'نطاق المساحة' : 'Area Range';
  String get amenities => isArabic ? 'المرافق' : 'Amenities';

  // Favorites
  String get noFavorites =>
      isArabic ? 'لا توجد عقارات مفضلة' : 'No Favorite Properties';
  String get addFavorites =>
      isArabic
          ? 'أضف عقارات لقائمة المفضلة'
          : 'Add properties to favorites list';
  String get savedProperties =>
      isArabic ? 'العقارات المحفوظة' : 'Saved Properties';

  // Chat
  String get conversations => isArabic ? 'المحادثات' : 'Conversations';
  String get messages => isArabic ? 'الرسائل' : 'Messages';
  String get noConversations =>
      isArabic ? 'لا توجد محادثات' : 'No Conversations';
  String get typeMessage => isArabic ? 'اكتب رسالتك...' : 'Type a message...';
  String get online => isArabic ? 'متصل' : 'Online';
  String get offline => isArabic ? 'غير متصل' : 'Offline';
  String get typing => isArabic ? 'يكتب...' : 'Typing...';
  String get sendMessage => isArabic ? 'إرسال' : 'Send';
  String get attachMedia => isArabic ? 'إرفاق وسائط' : 'Attach Media';
  String get sendImage => isArabic ? 'إرسال صورة' : 'Send Image';
  String get sendVideo => isArabic ? 'إرسال فيديو' : 'Send Video';
  String get sendAudio => isArabic ? 'رسالة صوتية' : 'Voice Message';
  String get sendFile => isArabic ? 'إرسال ملف' : 'Send File';
  String get shareProperty => isArabic ? 'مشاركة عقار' : 'Share Property';
  String get shareLocation => isArabic ? 'مشاركة الموقع' : 'Share Location';
  String get replyTo => isArabic ? 'رد على' : 'Reply to';
  String get react => isArabic ? 'تفاعل' : 'React';
  String get deleteMessage => isArabic ? 'حذف الرسالة' : 'Delete Message';
  String get copyMessage => isArabic ? 'نسخ الرسالة' : 'Copy Message';
  String get holdToRecord =>
      isArabic ? 'اضغط مطولاً للتسجيل' : 'Hold to record';
  String get recording => isArabic ? 'جارٍ التسجيل...' : 'Recording...';
  String get photo => isArabic ? 'صورة' : 'Photo';
  String get video => isArabic ? 'فيديو' : 'Video';
  String get camera => isArabic ? 'الكاميرا' : 'Camera';
  String get gallery => isArabic ? 'المعرض' : 'Gallery';
  String get today => isArabic ? 'اليوم' : 'Today';
  String get yesterday => isArabic ? 'أمس' : 'Yesterday';
  String get newMessage => isArabic ? 'رسالة جديدة' : 'New Message';
  String get startChat => isArabic ? 'بدء محادثة' : 'Start Chat';
  String get delivered => isArabic ? 'تم التسليم' : 'Delivered';
  String get seen => isArabic ? 'تمت القراءة' : 'Seen';
  String get voice => isArabic ? 'صوتية' : 'Voice';

  // Settings
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get preferences => isArabic ? 'التفضيلات' : 'Preferences';
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get notificationsDesc =>
      isArabic
          ? 'تلقي إشعارات حول العقارات الجديدة'
          : 'Receive notifications about new properties';
  String get darkMode => isArabic ? 'الوضع الداكن' : 'Dark Mode';
  String get darkModeDesc =>
      isArabic ? 'تفعيل المظهر الداكن' : 'Enable dark appearance';
  String get biometric => isArabic ? 'تسجيل دخول بالبصمة' : 'Biometric Login';
  String get biometricDesc =>
      isArabic ? 'تأمين الحساب بالبصمة' : 'Secure account with fingerprint';
  String get general => isArabic ? 'عام' : 'General';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get currency => isArabic ? 'العملة' : 'Currency';
  String get sarCurrency =>
      isArabic ? 'ريال سعودي (SAR)' : 'Saudi Riyal (SAR)';
  String get clearCache => isArabic ? 'مسح ذاكرة التخزين' : 'Clear Cache';
  String get cacheCleared =>
      isArabic ? 'تم مسح ذاكرة التخزين' : 'Cache cleared';
  String get about => isArabic ? 'حول' : 'About';
  String get aboutApp => isArabic ? 'عن التطبيق' : 'About App';
  String get version => isArabic ? 'الإصدار 2.0.0' : 'Version 2.0.0';
  String get privacy => isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get terms => isArabic ? 'الشروط والأحكام' : 'Terms & Conditions';
  String get contactUs => isArabic ? 'تواصل معنا' : 'Contact Us';
  String get themeSettings =>
      isArabic ? 'تخصيص المظهر' : 'Theme Customization';
  String get themeSettingsDesc =>
      isArabic ? 'تغيير ألوان التطبيق' : 'Change app colors';
  String get chooseLanguage => isArabic ? 'اختر اللغة' : 'Choose Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';

  // Admin
  String get adminDashboard => isArabic ? 'لوحة الإدارة' : 'Admin Dashboard';
  String get manageUsers => isArabic ? 'إدارة المستخدمين' : 'Manage Users';
  String get manageProperties =>
      isArabic ? 'إدارة العقارات' : 'Manage Properties';
  String get addUser => isArabic ? 'إضافة مستخدم' : 'Add User';
  String get editUser => isArabic ? 'تعديل المستخدم' : 'Edit User';
  String get deleteUser => isArabic ? 'حذف المستخدم' : 'Delete User';
  String get userDeleted => isArabic ? 'تم حذف المستخدم' : 'User Deleted';
  String get userAdded => isArabic ? 'تم إضافة المستخدم' : 'User Added';
  String get userUpdated => isArabic ? 'تم تحديث المستخدم' : 'User Updated';
  String get confirmDelete =>
      isArabic ? 'هل أنت متأكد من الحذف؟' : 'Are you sure you want to delete?';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get add => isArabic ? 'إضافة' : 'Add';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get view => isArabic ? 'عرض' : 'View';
  String get publish => isArabic ? 'نشر' : 'Publish';
  String get unpublish => isArabic ? 'إلغاء النشر' : 'Unpublish';
  String get published => isArabic ? 'منشور' : 'Published';
  String get draft => isArabic ? 'مسودة' : 'Draft';
  String get active => isArabic ? 'نشط' : 'Active';
  String get inactive => isArabic ? 'غير نشط' : 'Inactive';
  String get addProperty => isArabic ? 'إضافة عقار' : 'Add Property';
  String get editProperty => isArabic ? 'تعديل العقار' : 'Edit Property';
  String get propertyAdded => isArabic ? 'تم إضافة العقار' : 'Property Added';
  String get propertyUpdated =>
      isArabic ? 'تم تحديث العقار' : 'Property Updated';
  String get propertyDeleted => isArabic ? 'تم حذف العقار' : 'Property Deleted';
  String get title => isArabic ? 'العنوان' : 'Title';
  String get description => isArabic ? 'الوصف' : 'Description';
  String get price => isArabic ? 'السعر' : 'Price';
  String get location => isArabic ? 'الموقع' : 'Location';
  String get bedrooms => isArabic ? 'غرف النوم' : 'Bedrooms';
  String get bathrooms => isArabic ? 'الحمامات' : 'Bathrooms';
  String get area => isArabic ? 'المساحة' : 'Area';
  String get sqm => isArabic ? 'م²' : 'sqm';
  String get status => isArabic ? 'الحالة' : 'Status';
  String get available => isArabic ? 'متاح' : 'Available';
  String get sold => isArabic ? 'مباع' : 'Sold';
  String get rented => isArabic ? 'مؤجر' : 'Rented';
  String get manageReviews => isArabic ? 'إدارة التقييمات' : 'Manage Reviews';
  String get reports => isArabic ? 'التقارير' : 'Reports';
  String get analytics => isArabic ? 'الإحصائيات' : 'Analytics';
  String get totalProperties =>
      isArabic ? 'إجمالي العقارات' : 'Total Properties';
  String get totalUsers => isArabic ? 'إجمالي المستخدمين' : 'Total Users';
  String get monthlyRevenue => isArabic ? 'الإيرادات الشهرية' : 'Monthly Revenue';
  String get activeListings => isArabic ? 'إعلانات نشطة' : 'Active Listings';

  // Property Types
  String get villa => isArabic ? 'فيلا' : 'Villa';
  String get apartment => isArabic ? 'شقة' : 'Apartment';
  String get commercial => isArabic ? 'تجاري' : 'Commercial';
  String get land => isArabic ? 'أرض' : 'Land';
  String get office => isArabic ? 'مكتب' : 'Office';
  String get chalet => isArabic ? 'شاليه' : 'Chalet';
  String get farm => isArabic ? 'مزرعة' : 'Farm';
  String get building => isArabic ? 'عمارة' : 'Building';

  // Roles
  String get tenant => isArabic ? 'مستأجر' : 'Tenant';
  String get buyer => isArabic ? 'مشتري' : 'Buyer';
  String get seller => isArabic ? 'بائع' : 'Seller';
  String get owner => isArabic ? 'مالك' : 'Owner';
  String get agency => isArabic ? 'وكالة عقارية' : 'Agency';
  String get admin => isArabic ? 'مدير النظام' : 'Admin';

  // Profile
  String get editProfile => isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile';
  String get myProperties => isArabic ? 'عقاراتي' : 'My Properties';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get myContracts => isArabic ? 'عقودي' : 'My Contracts';
  String get myPayments => isArabic ? 'مدفوعاتي' : 'My Payments';
  String get credibilityScore => isArabic ? 'نقاط الموثوقية' : 'Credibility Score';
  String get verifiedAccount => isArabic ? 'حساب موثق' : 'Verified Account';
  String get memberSince => isArabic ? 'عضو منذ' : 'Member since';
  String get propertiesCount =>
      isArabic ? 'عدد العقارات' : 'Properties Count';
  String get reviewsCount => isArabic ? 'عدد التقييمات' : 'Reviews Count';
  String get responseRate => isArabic ? 'معدل الاستجابة' : 'Response Rate';

  // Property Details
  String get contactOwner => isArabic ? 'تواصل مع المالك' : 'Contact Owner';
  String get ownerInfo => isArabic ? 'معلومات المالك' : 'Owner Info';
  String get propertyOwner => isArabic ? 'مالك العقار' : 'Property Owner';
  String get virtualTour =>
      isArabic ? 'جولة افتراضية 360°' : '360° Virtual Tour';
  String get startTour =>
      isArabic
          ? 'اضغط لبدء الجولة الافتراضية'
          : 'Tap to start virtual tour';
  String get mortgageCalc =>
      isArabic ? 'حاسبة التمويل العقاري' : 'Mortgage Calculator';
  String get reviews => isArabic ? 'التقييمات' : 'Reviews';
  String get addReview => isArabic ? 'إضافة تقييم' : 'Add Review';
  String get noDescription => isArabic ? 'لا يوجد وصف' : 'No description';
  String get propertyDetails =>
      isArabic ? 'تفاصيل العقار' : 'Property Details';
  String get propertyFeatures =>
      isArabic ? 'مميزات العقار' : 'Property Features';
  String get viewOnMap => isArabic ? 'عرض على الخريطة' : 'View on Map';
  String get requestVisit => isArabic ? 'طلب زيارة' : 'Request Visit';
  String get makeOffer => isArabic ? 'تقديم عرض' : 'Make an Offer';
  String get priceNegotiable => isArabic ? 'السعر قابل للتفاوض' : 'Price Negotiable';
  String get addedFavorites => isArabic ? 'تمت الإضافة للمفضلة' : 'Added to Favorites';
  String get removedFavorites =>
      isArabic ? 'تم الحذف من المفضلة' : 'Removed from Favorites';
  String get similarProperties =>
      isArabic ? 'عقارات مشابهة' : 'Similar Properties';

  // AI
  String get aiAssistant => isArabic ? 'مساعد الذكاء الاصطناعي' : 'AI Assistant';
  String get aiAssistantDesc =>
      isArabic
          ? 'اسأل عن أي شيء يخص العقارات'
          : 'Ask anything about real estate';
  String get aiChat => isArabic ? 'محادثة الذكاء الاصطناعي' : 'AI Chat';
  String get aiInsights => isArabic ? 'رؤى الذكاء الاصطناعي' : 'AI Insights';
  String get aiPriceAnalysis =>
      isArabic ? 'تحليل السعر بالذكاء الاصطناعي' : 'AI Price Analysis';
  String get matchScore => isArabic ? 'نسبة التطابق' : 'Match Score';
  String get whyMatch => isArabic ? 'لماذا هذا مناسب لك؟' : 'Why this matches you?';
  String get aiSuggestedQuestions =>
      isArabic ? 'أسئلة مقترحة' : 'Suggested Questions';
  String get askAi => isArabic ? 'اسأل الذكاء الاصطناعي' : 'Ask AI';
  String get priceAnalysis => isArabic ? 'تحليل الأسعار' : 'Price Analysis';
  String get marketTrend => isArabic ? 'اتجاه السوق' : 'Market Trend';
  String get fairPrice => isArabic ? 'سعر عادل' : 'Fair Price';
  String get greatDeal => isArabic ? 'صفقة ممتازة' : 'Great Deal';
  String get overpriced => isArabic ? 'مرتفع السعر' : 'Overpriced';
  String get comparables => isArabic ? 'عقارات مقارنة' : 'Comparable Properties';

  // Map
  String get propertyMap => isArabic ? 'خريطة العقارات' : 'Properties Map';
  String get mapView => isArabic ? 'عرض الخريطة' : 'Map View';
  String get listView => isArabic ? 'عرض القائمة' : 'List View';
  String get nearbyProperties =>
      isArabic ? 'عقارات قريبة' : 'Nearby Properties';
  String get currentLocation => isArabic ? 'موقعي الحالي' : 'My Location';
  String get viewDetails => isArabic ? 'عرض التفاصيل' : 'View Details';
  String get propertiesFound =>
      isArabic ? 'عقارات موجودة' : 'Properties Found';

  // Virtual Tour
  String get virtualTour360 =>
      isArabic ? 'جولة 360° افتراضية' : '360° Virtual Tour';
  String get startVirtualTour =>
      isArabic ? 'ابدأ الجولة الافتراضية' : 'Start Virtual Tour';
  String get tourRooms => isArabic ? 'غرف الجولة' : 'Tour Rooms';
  String get livingRoom => isArabic ? 'الصالة الرئيسية' : 'Living Room';
  String get bedroom => isArabic ? 'غرفة النوم' : 'Bedroom';
  String get kitchen => isArabic ? 'المطبخ' : 'Kitchen';
  String get garden => isArabic ? 'الحديقة' : 'Garden';
  String get autoRotate => isArabic ? 'تدوير تلقائي' : 'Auto Rotate';
  String get fullscreen => isArabic ? 'ملء الشاشة' : 'Fullscreen';
  String get loadingTour => isArabic ? 'تحميل الجولة...' : 'Loading tour...';

  // Contracts
  String get contracts => isArabic ? 'العقود' : 'Contracts';
  String get myContracts_ => isArabic ? 'عقودي' : 'My Contracts';
  String get contractDetails =>
      isArabic ? 'تفاصيل العقد' : 'Contract Details';
  String get signContract => isArabic ? 'توقيع العقد' : 'Sign Contract';
  String get contractSigned => isArabic ? 'تم توقيع العقد' : 'Contract Signed';
  String get contractStatus => isArabic ? 'حالة العقد' : 'Contract Status';
  String get pendingSignature =>
      isArabic ? 'قيد التوقيع' : 'Pending Signature';
  String get bothSigned => isArabic ? 'موقّع من الطرفين' : 'Both Parties Signed';
  String get saleContract => isArabic ? 'عقد بيع' : 'Sale Contract';
  String get rentContract => isArabic ? 'عقد إيجار' : 'Rent Contract';
  String get agencyContract => isArabic ? 'عقد وكالة' : 'Agency Contract';
  String get expired => isArabic ? 'منتهي' : 'Expired';
  String get expiryDate => isArabic ? 'تاريخ الانتهاء' : 'Expiry Date';
  String get signedDate => isArabic ? 'تاريخ التوقيع' : 'Signed Date';
  String get contractNumber =>
      isArabic ? 'رقم العقد' : 'Contract Number';
  String get buyer_ => isArabic ? 'المشتري' : 'Buyer';
  String get seller_ => isArabic ? 'البائع' : 'Seller';
  String get noContracts => isArabic ? 'لا توجد عقود' : 'No Contracts';
  String get downloadContract => isArabic ? 'تحميل العقد' : 'Download Contract';
  String get shareContract => isArabic ? 'مشاركة العقد' : 'Share Contract';
  String get rejectContract => isArabic ? 'رفض العقد' : 'Reject Contract';

  String get securePayments => isArabic ? 'مدفوعات آمنة' : 'Secure Payments';

  // Payment
  String get payment => isArabic ? 'الدفع' : 'Payment';
  String get payments => isArabic ? 'المدفوعات' : 'Payments';
  String get payNow => isArabic ? 'ادفع الآن' : 'Pay Now';
  String get paymentMethod => isArabic ? 'طريقة الدفع' : 'Payment Method';
  String get creditCard => isArabic ? 'بطاقة ائتمانية' : 'Credit Card';
  String get bankTransfer => isArabic ? 'تحويل بنكي' : 'Bank Transfer';
  String get stcPay => isArabic ? 'STC Pay' : 'STC Pay';
  String get applePay => isArabic ? 'Apple Pay' : 'Apple Pay';
  String get googlePay => isArabic ? 'Google Pay' : 'Google Pay';
  String get cardNumber => isArabic ? 'رقم البطاقة' : 'Card Number';
  String get cardHolder => isArabic ? 'اسم حامل البطاقة' : 'Card Holder Name';
  String get expiryDate_ => isArabic ? 'تاريخ الانتهاء' : 'Expiry Date';
  String get cvv => isArabic ? 'رمز الأمان CVV' : 'CVV Security Code';
  String get totalAmount => isArabic ? 'المبلغ الإجمالي' : 'Total Amount';
  String get paymentSuccess => isArabic ? 'تمت عملية الدفع بنجاح' : 'Payment Successful';
  String get transactionId => isArabic ? 'رقم المعاملة' : 'Transaction ID';
  String get processingPayment =>
      isArabic ? 'جارٍ معالجة الدفع...' : 'Processing payment...';
  String get securePayment => isArabic ? 'دفع آمن ومشفر' : 'Secure & Encrypted Payment';
  String get noPayments => isArabic ? 'لا توجد مدفوعات' : 'No Payments';
  String get paymentHistory => isArabic ? 'سجل المدفوعات' : 'Payment History';
  String get fees => isArabic ? 'الرسوم' : 'Fees';
  String get vatIncluded => isArabic ? 'شامل ضريبة القيمة المضافة' : 'VAT Included';
  String get backToHome => isArabic ? 'العودة للرئيسية' : 'Back to Home';
  String get viewReceipt => isArabic ? 'عرض الفاتورة' : 'View Receipt';

  // Agency & Owner Profile
  String get agencyProfile => isArabic ? 'ملف الوكالة' : 'Agency Profile';
  String get ownerProfile => isArabic ? 'ملف المالك' : 'Owner Profile';
  String get contactAgency => isArabic ? 'تواصل مع الوكالة' : 'Contact Agency';
  String get verifiedAgency => isArabic ? 'وكالة موثقة' : 'Verified Agency';
  String get yearsExperience => isArabic ? 'سنوات الخبرة' : 'Years Experience';
  String get listedProperties =>
      isArabic ? 'عقارات معروضة' : 'Listed Properties';
  String get successfulDeals => isArabic ? 'صفقات ناجحة' : 'Successful Deals';
  String get avgResponseTime =>
      isArabic ? 'متوسط وقت الرد' : 'Avg Response Time';
  String get writeReview => isArabic ? 'كتابة تقييم' : 'Write a Review';
  String get ratingScore => isArabic ? 'التقييم' : 'Rating';
  String get noReviews => isArabic ? 'لا توجد تقييمات' : 'No Reviews';
  String get agencyListings =>
      isArabic ? 'قوائم الوكالة' : 'Agency Listings';

  // Theme
  String get chooseTheme =>
      isArabic ? 'اختر ثيم التطبيق' : 'Choose App Theme';
  String get colorPalette => isArabic ? 'لوحة الألوان' : 'Color Palette';
  String get appearance => isArabic ? 'المظهر' : 'Appearance';
  String get lightMode => isArabic ? 'الوضع النهاري' : 'Light Mode';
  String get previewText => isArabic ? 'معاينة' : 'Preview';
  String get themeApplied =>
      isArabic ? 'تم تطبيق الثيم بنجاح' : 'Theme applied successfully';

  // General
  String get sar => 'SAR';
  String get riyal => isArabic ? 'ريال' : 'SAR';
  String get loginFailed =>
      isArabic ? 'فشل تسجيل الدخول' : 'Login failed';
  String get registerFailed =>
      isArabic ? 'فشل إنشاء الحساب' : 'Registration failed';
  String get registerSuccess =>
      isArabic
          ? 'تم إنشاء الحساب بنجاح! سجل دخولك الآن'
          : 'Account created! Please login now';
  String get enterEmail =>
      isArabic ? 'الرجاء إدخال البريد الإلكتروني' : 'Please enter email';
  String get invalidEmail =>
      isArabic ? 'بريد إلكتروني غير صحيح' : 'Invalid email';
  String get enterPassword =>
      isArabic ? 'الرجاء إدخال كلمة المرور' : 'Please enter password';
  String get shortPassword =>
      isArabic ? 'كلمة المرور قصيرة جداً' : 'Password too short';
  String get enterName =>
      isArabic ? 'الرجاء إدخال الاسم' : 'Please enter name';
  String get passwordMismatch =>
      isArabic ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match';
  String get mustAcceptTerms =>
      isArabic
          ? 'يجب الموافقة على الشروط والأحكام'
          : 'Must accept terms & conditions';
  String get min6Chars =>
      isArabic
          ? 'يجب أن تكون 6 أحرف على الأقل'
          : 'Must be at least 6 characters';

  // Time
  String minutesAgo(int mins) => isArabic ? 'منذ $mins د' : '${mins}m ago';
  String hoursAgo(int hours) => isArabic ? 'منذ $hours س' : '${hours}h ago';
  String daysAgo(int days) => isArabic ? 'منذ $days يوم' : '${days}d ago';

  // Onboarding
  String get startNow => isArabic ? 'ابدأ الآن' : 'Get Started';
  String get next => isArabic ? 'التالي' : 'Next';
  String get skip => isArabic ? 'تخطي' : 'Skip';
  String get onboard1Title => isArabic ? 'ابحث بذكاء' : 'Smart Search';
  String get onboard1Desc =>
      isArabic
          ? 'اعثر على العقار المثالي باستخدام محرك البحث الذكي مع فلاتر متقدمة'
          : 'Find the perfect property with smart search and advanced filters';
  String get onboard2Title =>
      isArabic ? 'جولات افتراضية 360°' : '360° Virtual Tours';
  String get onboard2Desc =>
      isArabic
          ? 'استكشف العقارات من منزلك مع جولات افتراضية تفاعلية'
          : 'Explore properties from home with interactive virtual tours';
  String get onboard3Title =>
      isArabic ? 'توصيات ذكية' : 'Smart Recommendations';
  String get onboard3Desc =>
      isArabic
          ? 'احصل على توصيات عقارية مخصصة باستخدام الذكاء الاصطناعي'
          : 'Get personalized recommendations powered by AI';
  String get onboard4Title =>
      isArabic ? 'تعاملات موثوقة' : 'Trusted Transactions';
  String get onboard4Desc =>
      isArabic
          ? 'منصة آمنة وموثوقة مع نظام تقييمات شفاف وعقود رقمية'
          : 'Secure platform with transparent ratings and digital contracts';

  // Misc
  String get loading => isArabic ? 'جارٍ التحميل...' : 'Loading...';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get error => isArabic ? 'خطأ' : 'Error';
  String get success => isArabic ? 'نجح' : 'Success';
  String get warning => isArabic ? 'تحذير' : 'Warning';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get done => isArabic ? 'تم' : 'Done';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get back => isArabic ? 'رجوع' : 'Back';
  String get submit => isArabic ? 'إرسال' : 'Submit';
  String get update => isArabic ? 'تحديث' : 'Update';
  String get share => isArabic ? 'مشاركة' : 'Share';
  String get copy => isArabic ? 'نسخ' : 'Copy';
  String get call => isArabic ? 'اتصال' : 'Call';
  String get whatsapp => isArabic ? 'واتساب' : 'WhatsApp';
  String get report => isArabic ? 'إبلاغ' : 'Report';
  String get block => isArabic ? 'حظر' : 'Block';
  String get noData => isArabic ? 'لا توجد بيانات' : 'No Data';
  String get networkError =>
      isArabic ? 'خطأ في الاتصال بالإنترنت' : 'Network connection error';
  String get tryAgain => isArabic ? 'حاول مجدداً' : 'Try Again';
  String get optional => isArabic ? 'اختياري' : 'Optional';
  String get required_ => isArabic ? 'مطلوب' : 'Required';
  String get chooseRole => isArabic ? 'اختر نوع الحساب' : 'Choose Account Type';
  String get chooseCity => isArabic ? 'اختر المدينة' : 'Choose City';

  // Notifications
  String get markAllRead =>
      isArabic ? 'تحديد الكل كمقروء' : 'Mark All as Read';
  String get clearAll => isArabic ? 'مسح الكل' : 'Clear All';
  String get noNotifications =>
      isArabic ? 'لا توجد إشعارات' : 'No Notifications';

  String getRoleName(String role) {
    switch (role) {
      case 'tenant':
        return tenant;
      case 'buyer':
        return buyer;
      case 'seller':
        return seller;
      case 'owner':
        return owner;
      case 'agency':
        return agency;
      case 'admin':
        return admin;
      default:
        return role;
    }
  }

  String getPropertyType(String type) {
    switch (type) {
      case 'villa':
        return villa;
      case 'apartment':
        return apartment;
      case 'commercial':
        return commercial;
      case 'land':
        return land;
      case 'office':
        return office;
      case 'chalet':
        return chalet;
      case 'farm':
        return farm;
      case 'building':
        return building;
      default:
        return type;
    }
  }

  // ── Neighborhood Insights ────────────────────────────────────────────────
  String get neighborhoodInsights =>
      isArabic ? 'مؤشرات الحي' : 'Neighborhood Insights';
  String get livabilityScore =>
      isArabic ? 'مؤشر الجودة المعيشية' : 'Livability Score';
  String get safetyScore => isArabic ? 'الأمان' : 'Safety';
  String get schoolsScore => isArabic ? 'المدارس' : 'Schools';
  String get transportScore => isArabic ? 'المواصلات' : 'Transport';
  String get healthcareScore => isArabic ? 'الرعاية الصحية' : 'Healthcare';
  String get shoppingScore => isArabic ? 'التسوق' : 'Shopping';
  String get mosqueScore =>
      isArabic ? 'قرب المساجد' : 'Mosque Proximity';
  String get nearbyPlaces => isArabic ? 'أماكن قريبة' : 'Nearby Places';
  String get excellent => isArabic ? 'ممتاز' : 'Excellent';
  String get veryGood => isArabic ? 'جيد جداً' : 'Very Good';
  String get good => isArabic ? 'جيد' : 'Good';
  String get averageScore => isArabic ? 'متوسط' : 'Average';
  String get belowAverage => isArabic ? 'دون المتوسط' : 'Below Average';
  String get areaAnalysis => isArabic ? 'تحليل المنطقة' : 'Area Analysis';

  // ── Investment ROI Calculator ────────────────────────────────────────────
  String get investmentCalculator =>
      isArabic ? 'حاسبة العائد الاستثماري' : 'Investment ROI Calculator';
  String get investmentSubtitle =>
      isArabic
          ? 'حلل عائدك الاستثماري بدقة'
          : 'Accurately analyze your investment return';
  String get investmentData =>
      isArabic ? 'بيانات الاستثمار' : 'Investment Data';
  String get annualRent =>
      isArabic ? 'الإيجار السنوي المتوقع' : 'Expected Annual Rent';
  String get costsAndExpenses =>
      isArabic ? 'التكاليف والنفقات' : 'Costs & Expenses';
  String get maintenanceCost =>
      isArabic ? 'تكلفة الصيانة السنوية' : 'Annual Maintenance Cost';
  String get managementFee =>
      isArabic ? 'رسوم الإدارة' : 'Management Fee';
  String get vacancyRate => isArabic ? 'معدل الشغور' : 'Vacancy Rate';
  String get grossRentalYield =>
      isArabic ? 'العائد الإيجاري الإجمالي' : 'Gross Rental Yield';
  String get netRentalYield =>
      isArabic ? 'صافي العائد الإيجاري' : 'Net Rental Yield';
  String get annualNetIncome =>
      isArabic ? 'صافي الدخل السنوي' : 'Annual Net Income';
  String get paybackPeriod =>
      isArabic ? 'فترة الاسترداد' : 'Payback Period';
  String get years => isArabic ? 'سنوات' : 'Years';
  String get calculateRoi => isArabic ? 'احسب العائد' : 'Calculate ROI';
  String get roiResults =>
      isArabic ? 'نتائج التحليل الاستثماري' : 'Investment Analysis Results';
  String get goodInvestment =>
      isArabic ? 'استثمار ممتاز' : 'Excellent Investment';
  String get fairInvestment =>
      isArabic ? 'استثمار معقول' : 'Fair Investment';
  String get poorInvestment => isArabic ? 'عائد منخفض' : 'Low Return';
  String get maintenanceCostLabel =>
      isArabic ? 'تكلفة الصيانة' : 'Maintenance Cost';
  String get mgmtAndVacancy =>
      isArabic ? 'رسوم الإدارة + الشغور' : 'Mgmt + Vacancy';

  // ── Market Trends ────────────────────────────────────────────────────────
  String get marketTrends =>
      isArabic ? 'اتجاهات السوق' : 'Market Trends';
  String get avgPricePerSqm =>
      isArabic ? 'متوسط السعر/م²' : 'Avg Price/sqm';
  String get priceChange => isArabic ? 'تغير السعر' : 'Price Change';
  String get activeMarket => isArabic ? 'سوق نشط' : 'Active Market';
  String get yearOverYear => isArabic ? 'سنوياً' : 'YoY';
  String get sarUnit => isArabic ? 'ريال' : 'SAR';
  String get sarPerYear => isArabic ? 'ريال/سنة' : 'SAR/yr';

  // ── Price Alert ──────────────────────────────────────────────────────────
  String get priceAlert => isArabic ? 'تنبيه السعر' : 'Price Alert';
  String get setPriceAlert =>
      isArabic ? 'تفعيل تنبيه السعر' : 'Set Price Alert';
  String get alertEnabled =>
      isArabic ? 'تم تفعيل التنبيه ✓' : 'Alert Enabled ✓';
  String get alertDisabled =>
      isArabic ? 'تم إيقاف التنبيه' : 'Alert Disabled';
  String get notifyPriceDrop =>
      isArabic
          ? 'أشعرني عند انخفاض السعر'
          : 'Notify me when price drops';
  String get priceAlertDesc =>
      isArabic
          ? 'سنخطرك فوراً عند أي تغيير في سعر هذا العقار'
          : 'We\'ll notify you immediately on any price change for this property';

  // ── Digital Signature ─────────────────────────────────────────────────────
  String get electronicSignature =>
      isArabic ? 'التوقيع الإلكتروني' : 'Electronic Signature';
  String get drawSignature =>
      isArabic ? 'ارسم توقيعك هنا' : 'Draw your signature here';
  String get clearSignature => isArabic ? 'مسح' : 'Clear';
  String get confirmSignature => isArabic ? 'تأكيد التوقيع' : 'Confirm Signature';
  String get signatureConfirmed =>
      isArabic ? '✓ تم تأكيد توقيعك' : '✓ Signature Confirmed';
  String get signatureRequired =>
      isArabic ? 'يرجى رسم توقيعك أولاً' : 'Please draw your signature first';
  String get signatureDisclaimer =>
      isArabic
          ? 'بتوقيعك فإنك توافق على جميع بنود وشروط هذا العقد وفقاً لأنظمة المملكة العربية السعودية.'
          : 'By signing you agree to all terms and conditions of this contract in accordance with Saudi Arabian regulations.';
  String get signedAt => isArabic ? 'وقت التوقيع' : 'Signed At';
  String get auditTrail => isArabic ? 'سجل التدقيق' : 'Audit Trail';

  // ── QR Receipt ────────────────────────────────────────────────────────────
  String get paymentReceipt => isArabic ? 'إيصال الدفع' : 'Payment Receipt';
  String get scanToVerify =>
      isArabic ? 'امسح الرمز للتحقق من الدفع' : 'Scan QR to verify payment';
  String get verificationCode =>
      isArabic ? 'رمز التحقق' : 'Verification Code';
  String get paymentVerified =>
      isArabic ? 'تم التحقق من الدفع ✓' : 'Payment Verified ✓';
  String get amountPaid => isArabic ? 'المبلغ المدفوع' : 'Amount Paid';
  String get paymentDate => isArabic ? 'تاريخ الدفع' : 'Payment Date';
  String get downloadReceipt =>
      isArabic ? 'تحميل الإيصال' : 'Download Receipt';
  String get shareReceipt => isArabic ? 'مشاركة الإيصال' : 'Share Receipt';

  // ── Auth Guard ────────────────────────────────────────────────────────────
  String get loginRequired =>
      isArabic ? 'يتطلب تسجيل الدخول' : 'Login Required';
  String get loginToAccessFeature =>
      isArabic
          ? 'سجّل دخولك للوصول إلى هذه الميزة'
          : 'Please login to access this feature';
  String get createAccountOrLogin =>
      isArabic ? 'إنشاء حساب أو تسجيل الدخول' : 'Create Account or Login';
  String get continueAsGuest =>
      isArabic ? 'متابعة كزائر' : 'Continue as Guest';
  String get alreadyHaveAccount =>
      isArabic ? 'لديك حساب بالفعل؟' : 'Already have an account?';
  String get dontHaveAccount =>
      isArabic ? 'ليس لديك حساب؟' : 'Don\'t have an account?';
  String get guestMode =>
      isArabic ? 'وضع الزائر — ميزات محدودة' : 'Guest Mode — Limited Features';

  // ── Role-based labels ─────────────────────────────────────────────────────
  String get myListings => isArabic ? 'إعلاناتي' : 'My Listings';
  String get dashboard => isArabic ? 'لوحة التحكم' : 'Dashboard';
  String get tools => isArabic ? 'الأدوات' : 'Tools';
  String get explore => isArabic ? 'استكشاف' : 'Explore';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
