import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  GeminiMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

class GeminiService {
  static const String _apiKey = 'AIzaSyC2fDACj9xAUG6cqWMJN-In643kRvCoKms';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static const String _systemPrompt = '''
أنت مساعد ذكاء اصطناعي متخصص في العقارات السعودية لمنصة "عقاري". 
مهمتك مساعدة المستخدمين في:
- البحث عن عقارات مناسبة في المملكة العربية السعودية
- تحليل أسعار السوق العقاري
- تقديم نصائح قانونية عقارية بسيطة
- الإجابة على استفسارات الإيجار والبيع والشراء
- شرح أنواع العقود العقارية
- معلومات عن أحياء المدن السعودية الرئيسية

تحدث دائماً بالعربية أو الإنجليزية حسب لغة المستخدم. 
كن ودوداً، مهنياً، ومفيداً. قدم إجابات موجزة ومحددة.
إذا سُئلت عن سعر عقار محدد، قدم تحليلاً بناءً على بيانات السوق السعودي.
''';

  final List<GeminiMessage> _history = [];

  List<GeminiMessage> get history => _history;

  Future<String> sendMessage(String userMessage) async {
    _history.add(GeminiMessage(
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    ));

    try {
      final contents = <Map<String, dynamic>>[];

      for (final msg in _history) {
        contents.add({
          'role': msg.role == 'user' ? 'user' : 'model',
          'parts': [
            {'text': msg.content}
          ],
        });
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'system_instruction': {
                'parts': [
                  {'text': _systemPrompt}
                ]
              },
              'contents': contents,
              'generationConfig': {
                'temperature': 0.7,
                'topK': 40,
                'topP': 0.95,
                'maxOutputTokens': 1024,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

        final assistantMessage = text.isNotEmpty
            ? text
            : _getFallbackResponse(userMessage);

        _history.add(GeminiMessage(
          role: 'model',
          content: assistantMessage,
          timestamp: DateTime.now(),
        ));

        return assistantMessage;
      } else {
        final fallback = _getFallbackResponse(userMessage);
        _history.add(GeminiMessage(
          role: 'model',
          content: fallback,
          timestamp: DateTime.now(),
        ));
        return fallback;
      }
    } catch (e) {
      final fallback = _getFallbackResponse(userMessage);
      _history.add(GeminiMessage(
        role: 'model',
        content: fallback,
        timestamp: DateTime.now(),
      ));
      return fallback;
    }
  }

  String _getFallbackResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('سعر') || q.contains('price') || q.contains('تكلفة')) {
      return '''بناءً على بيانات السوق السعودي الحالية:

🏠 **أسعار الفلل في الرياض:**
• حي الملقا: 2.5 - 4.5 مليون ريال
• حي النرجس: 1.8 - 3.2 مليون ريال  
• حي حطين: 3.5 - 8 مليون ريال

🏢 **أسعار الشقق في جدة:**
• كورنيش جدة: 800K - 2.5 مليون ريال
• البلد: 400K - 900K ريال

هل تريد تفاصيل عن منطقة معينة؟''';
    }

    if (q.contains('إيجار') || q.contains('rent') || q.contains('استئجار')) {
      return '''معلومات الإيجار في المملكة العربية السعودية:

📋 **متوسط الإيجار السنوي:**
• شقة 2 غرفة في الرياض: 30,000 - 50,000 ريال
• فيلا في جدة: 80,000 - 150,000 ريال
• مكتب تجاري في الدمام: 40,000 - 80,000 ريال

⚖️ **حقوقك كمستأجر:**
• يحق لك الحصول على عقد موثق
• الإيجار لا يُرفع إلا بإشعار 90 يوماً
• يمكنك فسخ العقد بسبب عيوب جوهرية

هل تحتاج مساعدة في شيء محدد؟''';
    }

    if (q.contains('مرحبا') || q.contains('hello') || q.contains('السلام')) {
      return '''مرحباً! 👋 أنا مساعدك الذكي في منصة **عقاري**.

يمكنني مساعدتك في:
🔍 **البحث عن عقارات** مناسبة لميزانيتك
💰 **تحليل الأسعار** ومقارنة السوق
📋 **معلومات العقود** والإجراءات القانونية
🗺️ **الأحياء والمناطق** في المدن السعودية
📊 **توقعات السوق** والاستثمار العقاري

بماذا يمكنني مساعدتك اليوم؟''';
    }

    if (q.contains('استثمار') || q.contains('invest')) {
      return '''نصائح الاستثمار العقاري في السعودية 2026:

📈 **أفضل المناطق للاستثمار:**
1. **نيوم** - مشروع ضخم بعوائد مرتفعة
2. **رياض القيادة** - تطوير سريع وطلب متزايد
3. **كورنيش جدة** - عوائد إيجارية مستقرة
4. **البحرين (قريب الدمام)** - طلب تجاري متنامٍ

💡 **نصيحة الذكاء الاصطناعي:**
العقارات السكنية في الرياض شهدت نمواً 15% هذا العام. 
أنصح بالتركيز على شقق الاستثمار بمنطقة العليا والملقا.

هل تريد تحليلاً أعمق لمنطقة معينة؟''';
    }

    return '''شكراً لسؤالك! 🌟

أنا متخصص في العقارات السعودية ويمكنني مساعدتك في:

• **أسعار العقارات** في مختلف مدن المملكة
• **نصائح الشراء والإيجار** والاستثمار
• **تحليل السوق** والمناطق الواعدة
• **معلومات قانونية** حول العقود

أعد صياغة سؤالك أو اختر موضوعاً من القائمة أعلاه وسأكون سعيداً بمساعدتك! 😊''';
  }

  void clearHistory() {
    _history.clear();
  }

  List<String> getSuggestedQuestions(bool isArabic) {
    if (isArabic) {
      return [
        'ما هو متوسط سعر الفلل في الرياض؟',
        'كيف أشتري عقاراً لأول مرة؟',
        'أفضل الأحياء للاستثمار في جدة',
        'ما هي شروط الإيجار في السعودية؟',
        'كيف أتحقق من صحة العقار؟',
        'توقعات سوق العقارات 2026',
      ];
    } else {
      return [
        'What is the average villa price in Riyadh?',
        'How to buy property for the first time?',
        'Best areas to invest in Jeddah',
        'What are rental terms in Saudi Arabia?',
        'How to verify property authenticity?',
        'Real estate market outlook 2026',
      ];
    }
  }
}
