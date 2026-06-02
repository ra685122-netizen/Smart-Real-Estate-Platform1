import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message_model.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';

class ChatView extends StatefulWidget {
  final int otherUserId;

  const ChatView({Key? key, required this.otherUserId}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  int _currentUserId = 1;
  int _conversationId = 0;
  bool _isTyping = false;
  bool _loadingMessages = true;
  Timer? _typingTimer;
  late AnimationController _dotController;
  late AnimationController _recordPulseController;

  ChatMessage? _replyingTo;
  bool _isRecording = false;
  double _recordDuration = 0.0;
  Timer? _recordTimer;
  bool _showStickerPicker = false;

  static const List<List<String>> _stickerCategories = [
    ['😀', '😂', '🤣', '😊', '😍', '🥰', '😎', '🤩', '😜', '🤪', '😏', '🥳'],
    ['👍', '👎', '👋', '🤝', '🙏', '💪', '✌️', '🤞', '👌', '🤙', '💯', '🔥'],
    ['❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '💔', '💕', '💞', '💓', '💗'],
    ['🏠', '🏡', '🏢', '🔑', '💰', '💎', '🌟', '⭐', '✨', '🎉', '🎊', '🎁'],
    ['😢', '😭', '😤', '😡', '🤬', '😱', '😨', '😰', '😓', '🤔', '🤷', '🤦'],
  ];

  static const List<String> _categoryLabels = ['😀', '👍', '❤️', '🏠', '😢'];

  int _selectedStickerCat = 0;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _recordPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConversation());
  }

  Future<void> _loadConversation() async {
    final userId = context.read<AuthProvider>().currentUser?.id ?? 1;
    _currentUserId = userId;
    final convId = await ApiService.getOrCreateConversation(userId, widget.otherUserId);
    if (convId != null) {
      _conversationId = convId;
      final msgs = await ApiService.getMessages(convId, userId);
      if (mounted) setState(() { _messages = msgs; _loadingMessages = false; });
    } else {
      if (mounted) setState(() => _loadingMessages = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _dotController.dispose();
    _recordPulseController.dispose();
    _typingTimer?.cancel();
    _recordTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage({
    String? text,
    MessageType type = MessageType.text,
    String? mediaPath,
    int? propertyId,
  }) async {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty && type == MessageType.text) return;
    if (_conversationId == 0) return;

    if (type == MessageType.text) _messageController.clear();

    if (type == MessageType.image && mediaPath != null) {
      final localMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        senderId: _currentUserId,
        receiverId: widget.otherUserId,
        message: 'Photo',
        senderName: 'Me',
        createdAt: DateTime.now(),
        type: MessageType.image,
        mediaUrl: mediaPath,
        isLocalFile: true,
        status: MessageStatus.sent,
      );
      setState(() {
        _messages.add(localMsg);
        _replyingTo = null;
      });
      _scrollToBottom();
      return;
    }

    if (type == MessageType.audio) {
      final localMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        senderId: _currentUserId,
        receiverId: widget.otherUserId,
        message: 'Voice Message',
        senderName: 'Me',
        createdAt: DateTime.now(),
        type: MessageType.audio,
        mediaDuration: _recordDuration,
        status: MessageStatus.sent,
      );
      setState(() {
        _messages.add(localMsg);
        _replyingTo = null;
      });
      _scrollToBottom();
      return;
    }

    final sent = await ApiService.sendMessage(_conversationId, _currentUserId, messageText);
    if (sent != null && mounted) {
      setState(() {
        _messages.add(sent);
        _replyingTo = null;
      });
      _scrollToBottom();
    }
  }

  Future<void> _pickImage(bool isCamera) async {
    final picker = ImagePicker();
    XFile? image;
    try {
      if (isCamera && !kIsWeb) {
        image = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
      } else {
        image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
      }
    } catch (_) {
      image = null;
    }
    if (image != null) {
      _sendMessage(type: MessageType.image, text: 'Photo', mediaPath: image.path);
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordDuration = 0;
      _showStickerPicker = false;
    });
    _recordPulseController.repeat(reverse: true);
    _recordTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) setState(() => _recordDuration += 0.1);
    });
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    _recordPulseController.stop();
    _recordPulseController.reset();
    if (_recordDuration > 0.5) {
      _sendMessage(type: MessageType.audio, text: 'Voice Message');
    }
    if (mounted) setState(() => _isRecording = false);
  }

  String _formatRecordDuration(double secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs.toInt() % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showAttachmentSheet() {
    setState(() => _showStickerPicker = false);
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _attachmentItem(Icons.camera_alt, Colors.pink, loc.camera, () {
              Navigator.pop(context);
              _pickImage(true);
            }),
            _attachmentItem(Icons.image, Colors.purple, loc.gallery, () {
              Navigator.pop(context);
              _pickImage(false);
            }),
            _attachmentItem(Icons.insert_drive_file, Colors.blue, 'Document', () => Navigator.pop(context)),
            _attachmentItem(Icons.location_on, Colors.green, loc.location, () => Navigator.pop(context)),
            _attachmentItem(Icons.home, Colors.orange, 'Property', () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _attachmentItem(IconData icon, Color color, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 30, backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 30)),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.cairo(fontSize: 12)),
        ],
      ),
    );
  }

  void _onMessageLongPress(ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['❤️', '👍', '😂', '😮', '😢', '🙏'].map((e) => TextButton(
                  onPressed: () {
                    setState(() => msg.reactions.add(e));
                    Navigator.pop(context);
                  },
                  child: Text(e, style: const TextStyle(fontSize: 24)),
                )).toList(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                setState(() => _replyingTo = msg);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateLabel(DateTime date, AppLocalizations loc) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return loc.today;
    } else if (date.day == now.day - 1 && date.month == now.month && date.year == now.year) {
      return loc.yesterday;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = themeProvider.isDark;
    final primary = themeProvider.currentScheme.primary;
    final secondary = themeProvider.currentScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundColor: primary.withValues(alpha: 0.1), child: const Icon(Icons.person)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.isArabic ? 'مالك العقار' : 'Property Owner', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(_isTyping ? loc.typing : loc.online, style: GoogleFonts.cairo(fontSize: 12, color: _isTyping ? primary : Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_showStickerPicker) setState(() => _showStickerPicker = false);
        },
        child: Container(
          decoration: BoxDecoration(
            image: isDark ? null : const DecorationImage(
              image: NetworkImage('https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png'),
              opacity: 0.05,
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: _loadingMessages
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) return _buildTypingIndicator(primary);

                    final msg = _messages[index];
                    bool showDate = false;
                    if (index == 0) {
                      showDate = true;
                    } else {
                      final prevMsg = _messages[index - 1];
                      if (msg.createdAt.day != prevMsg.createdAt.day) {
                        showDate = true;
                      }
                    }

                    return Column(
                      children: [
                        if (showDate) _buildDateSeparator(msg.createdAt, loc, isDark),
                        _buildMessageBubble(msg, msg.senderId == _currentUserId, primary, secondary, isDark),
                      ],
                    );
                  },
                ),
              ),
              if (_replyingTo != null) _buildReplyPreview(primary, secondary, isDark),
              if (_isRecording) _buildRecordingBar(primary, isDark),
              if (_showStickerPicker) _buildStickerPicker(primary, isDark),
              if (!_isRecording) _buildInputBar(loc, primary, secondary, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date, AppLocalizations loc, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
      child: Text(_getDateLabel(date, loc), style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
    );
  }

  Widget _buildReplyPreview(Color primary, Color secondary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: isDark ? Colors.grey[900] : Colors.grey[200],
      child: Row(
        children: [
          Container(width: 4, height: 40, color: primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_replyingTo!.senderName, style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                Text(_replyingTo!.message, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _replyingTo = null)),
        ],
      ),
    );
  }

  Widget _buildRecordingBar(Color primary, bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isDark ? Colors.grey[900] : Colors.white,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _recordPulseController,
              builder: (_, __) => Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.6 + 0.4 * _recordPulseController.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatRecordDuration(_recordDuration),
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildAnimatedRecordWaveform(),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                _recordTimer?.cancel();
                _recordPulseController.stop();
                _recordPulseController.reset();
                setState(() { _isRecording = false; _recordDuration = 0; });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 12)],
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedRecordWaveform() {
    return AnimatedBuilder(
      animation: _recordPulseController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (i) {
            final phase = (i / 20 + _recordPulseController.value) % 1.0;
            final height = 8.0 + 16.0 * (0.5 + 0.5 * (1 - (phase * 2 - 1).abs()));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 2.5,
              height: height,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.5 + 0.5 * (1 - (phase * 2 - 1).abs())),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStickerPicker(Color primary, bool isDark) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Column(
        children: [
          Container(
            height: 44,
            color: isDark ? const Color(0xFF15151F) : Colors.grey[50],
            child: Row(
              children: List.generate(_categoryLabels.length, (i) {
                final selected = _selectedStickerCat == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStickerCat = i),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: selected ? primary.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: selected ? Border.all(color: primary.withValues(alpha: 0.4)) : null,
                      ),
                      child: Center(
                        child: Text(_categoryLabels[i], style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 6,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: _stickerCategories[_selectedStickerCat].map((sticker) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _showStickerPicker = false);
                    _sendStickerMessage(sticker);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                    ),
                    child: Center(
                      child: Text(sticker, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _sendStickerMessage(String sticker) {
    final localMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: _currentUserId,
      receiverId: widget.otherUserId,
      message: sticker,
      senderName: 'Me',
      createdAt: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.sent,
    );
    setState(() {
      _messages.add(localMsg);
      _replyingTo = null;
    });
    _scrollToBottom();
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe, Color primary, Color secondary, bool isDark) {
    return GestureDetector(
      onLongPress: () => _onMessageLongPress(msg),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                gradient: isMe ? LinearGradient(colors: [primary, secondary]) : null,
                color: isMe ? null : (isDark ? Colors.grey[800] : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: Radius.circular(isMe ? 15 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 15),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.replyToText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(5)),
                      child: Text(msg.replyToText!, style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54)),
                    ),
                    const SizedBox(height: 5),
                  ],
                  _buildMessageContent(msg, isMe),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 5),
                        Icon(Icons.done_all, size: 14, color: msg.status == MessageStatus.read ? Colors.blue : Colors.white70),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (msg.reactions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                child: Text(msg.reactions.join(' ')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage msg, bool isMe) {
    switch (msg.type) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: msg.isLocalFile && !kIsWeb
              ? Image.file(
                  File(msg.mediaUrl ?? ''),
                  width: 220,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 220,
                    height: 180,
                    color: Colors.black12,
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.white54),
                  ),
                )
              : msg.mediaUrl != null
                  ? Image.network(
                      msg.mediaUrl!,
                      width: 220,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                    )
                  : const Icon(Icons.image, size: 50),
        );
      case MessageType.audio:
        return _buildAudioBubble(isMe, msg.mediaDuration ?? 0);
      case MessageType.propertyCard:
        return Container(
          width: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(msg.propertyImage!, height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              Text(msg.propertyTitle!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              Text('${msg.propertyPrice} SAR', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      default:
        final isSticker = msg.message.length <= 2 && msg.message.isNotEmpty && msg.message.codeUnits.any((c) => c > 127);
        if (isSticker) {
          return Text(msg.message, style: const TextStyle(fontSize: 40));
        }
        return Text(msg.message, style: TextStyle(color: isMe ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)));
    }
  }

  Widget _buildAudioBubble(bool isMe, double duration) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.play_arrow, color: isMe ? Colors.white : Colors.black, size: 28),
        const SizedBox(width: 8),
        _buildWaveform(isMe),
        const SizedBox(width: 8),
        Text(
          _formatRecordDuration(duration > 0 ? duration : 12),
          style: TextStyle(fontSize: 12, color: isMe ? Colors.white : Colors.black54, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildWaveform(bool isMe) {
    return Row(
      children: List.generate(18, (i) => Container(
        margin: const EdgeInsets.only(right: 2),
        width: 2.5,
        height: (8 + (i % 5) * 5).toDouble(),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withValues(alpha: 0.7) : Colors.grey.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(2),
        ),
      )),
    );
  }

  Widget _buildTypingIndicator(Color primary) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: AnimatedBuilder(
          animation: _dotController,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final val = (_dotController.value + i * 0.3) % 1.0;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6, height: 6,
                decoration: BoxDecoration(color: primary.withValues(alpha: val), shape: BoxShape.circle),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(AppLocalizations loc, Color primary, Color secondary, bool isDark) {
    final hasText = _messageController.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: isDark ? Colors.grey[900] : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _showAttachmentSheet,
              padding: const EdgeInsets.all(8),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        _showStickerPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                        color: _showStickerPicker ? primary : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _showStickerPicker = !_showStickerPicker);
                        if (_showStickerPicker) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                      padding: const EdgeInsets.all(8),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: loc.typeMessage,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (val) => setState(() {}),
                        onTap: () {
                          if (_showStickerPicker) setState(() => _showStickerPicker = false);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () => _pickImage(true),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              onTap: hasText ? () => _sendMessage() : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Icon(
                  hasText ? Icons.send : Icons.mic,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
