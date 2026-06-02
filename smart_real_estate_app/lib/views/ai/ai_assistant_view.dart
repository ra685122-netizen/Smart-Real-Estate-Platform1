import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/gemini_service.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class AIAssistantView extends StatefulWidget {
  const AIAssistantView({Key? key}) : super(key: key);

  @override
  State<AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends State<AIAssistantView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? message]) async {
    final text = message ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (message == null) _controller.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      await _geminiService.sendMessage(text);
    } catch (e) {
      // Error handling is managed by the service and history
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _clearConversation() {
    setState(() {
      _geminiService.clearHistory();
    });
  }

  void _shareResponse(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final messages = _geminiService.history;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.currentScheme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isArabic ? 'مساعد عقاري الذكي' : 'AI Assistant',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear') _clearConversation();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(isArabic ? 'مسح المحادثة' : 'Clear conversation'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty ? _buildWelcomeScreen(isArabic) : _buildChatList(messages, isArabic),
          ),
          if (_isLoading) _buildTypingIndicator(isArabic),
          _buildInputBar(isArabic, themeProvider),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(bool isArabic) {
    final suggestions = _geminiService.getSuggestedQuestions(isArabic);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'كيف يمكنني مساعدتك اليوم؟' : 'How can I help you today?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'أنا مساعدك الذكي في منصة عقاري، يمكنني مساعدتك في البحث عن عقارات، تحليل الأسعار، وتقديم نصائح استثمارية.'
                  : 'I am your smart assistant in Aqari platform. I can help you find properties, analyze prices, and provide investment tips.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: suggestions.map((q) => _buildSuggestionChip(q)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String question) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final primary = themeProvider.currentScheme.primary;
    return GestureDetector(
      onTap: () => _handleSendMessage(question),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          border: Border.all(color: primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          question,
          style: TextStyle(
            fontSize: 12,
            color: primary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChatList(List<GeminiMessage> messages, bool isArabic) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isUser = msg.role == 'user';
        final showFollowUps = !isUser && index == messages.length - 1 && !_isLoading;

        return Column(
          children: [
            _buildChatBubble(msg, isUser, isArabic),
            if (showFollowUps) _buildFollowUpChips(isArabic),
          ],
        );
      },
    );
  }

  Widget _buildChatBubble(GeminiMessage msg, bool isUser, bool isArabic) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(right: 8.0, top: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.smart_toy, size: 20, color: Colors.white),
                ),
              ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? LinearGradient(colors: themeProvider.currentScheme.gradient)
                      : null,
                  color: isUser ? null : (theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormattedText(msg.content, isUser ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(msg.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isUser ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        if (!isUser) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _shareResponse(msg.content),
                            child: const Icon(Icons.share, size: 14, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text, Color color) {
    // Simple bold text support with **
    final parts = text.split('**');
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ));
      } else {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(color: color),
        ));
      }
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 15, height: 1.4),
      ),
    );
  }

  Widget _buildFollowUpChips(bool isArabic) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final primary = themeProvider.currentScheme.primary;
    final suggestions = isArabic
        ? ['عرض التفاصيل', 'مقارنة الأسعار', 'نصيحة قانونية']
        : ['Show details', 'Compare prices', 'Legal advice'];

    return Container(
      margin: const EdgeInsets.only(left: 40, bottom: 16),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: suggestions
            .map((q) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => _handleSendMessage(q),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        border: Border.all(color: primary.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        q,
                        style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: Icon(Icons.smart_toy, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const _BouncingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isArabic, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: isArabic ? 'اسأل عن أي شيء عقاري...' : 'Ask anything real estate...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: themeProvider.currentScheme.gradient),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _handleSendMessage(),
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots({Key? key}) : super(key: key);

  @override
  _BouncingDotsState createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double offset = (index * 0.2);
            final double value = (_controller.value + offset) % 1.0;
            final double translateY = -5 * (1 - (value - 0.5).abs() * 2);
            return Transform.translate(
              offset: Offset(0, translateY),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
