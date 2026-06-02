import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message_model.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class ConversationsView extends StatefulWidget {
  const ConversationsView({Key? key}) : super(key: key);

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  List<ChatConversation> _conversations = [];
  List<ChatConversation> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) { setState(() => _loading = false); return; }
    final convs = await ApiService.getConversations(userId);
    if (mounted) setState(() { _conversations = convs; _filtered = List.from(convs); _loading = false; });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterConversations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_conversations);
      } else {
        _filtered = _conversations
            .where((c) =>
                c.userName.toLowerCase().contains(query.toLowerCase()) ||
                c.lastMessage.toLowerCase().contains(query.toLowerCase()) ||
                (c.propertyTitle?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  void _removeConversation(int index) {
    setState(() {
      _filtered.removeAt(index);
      _conversations = List.from(_filtered);
    });
  }

  String _formatTime(DateTime time, AppLocalizations loc) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return loc.isArabic ? '${diff.inMinutes} دقيقة' : '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return loc.isArabic ? '${diff.inHours} ساعة' : '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return loc.isArabic ? '${diff.inDays} يوم' : '${diff.inDays}d';
    } else {
      return '${time.day}/${time.month}';
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
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(loc, primary, secondary),
              Expanded(
                child: _buildConversationsList(loc, theme, isDark, primary, secondary),
              ),
            ],
          ),
          _buildBottomNav(primary, secondary),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc, Color primary, Color secondary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.messages,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterConversations,
                decoration: InputDecoration(
                  hintText: loc.searchHint,
                  hintStyle: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 40,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(AppLocalizations loc, ThemeData theme, bool isDark, Color primary, Color secondary) {
    return Container(
      color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.isArabic ? 'الأخيرة' : 'Recent',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Icon(Icons.more_horiz, color: isDark ? Colors.white70 : Colors.black54),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmptyState(loc, primary, secondary)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                    itemCount: _filtered.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 85),
                    itemBuilder: (context, index) {
                      final conv = _filtered[index];
                      return Dismissible(
                        key: Key('conv_${conv.userId}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _removeConversation(index),
                        child: _buildConversationTile(conv, loc, isDark, primary, secondary),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ChatConversation conv, AppLocalizations loc, bool isDark, Color primary, Color secondary) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Stack(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary.withValues(alpha: 0.7), secondary.withValues(alpha: 0.7)],
              ),
            ),
            child: conv.userAvatar != null
                ? CircleAvatar(backgroundImage: NetworkImage(conv.userAvatar!))
                : Center(
                    child: Text(
                      conv.userName[0],
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
          if (conv.isOnline)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conv.userName,
        style: GoogleFonts.cairo(
          fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        conv.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.cairo(
          fontSize: 13,
          color: conv.unreadCount > 0 ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conv.lastMessageTime, loc),
            style: TextStyle(fontSize: 11, color: conv.unreadCount > 0 ? primary : Colors.grey),
          ),
          const SizedBox(height: 5),
          if (conv.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
              child: Text(
                conv.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      onTap: () => context.push('/chat/${conv.userId}'),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc, Color primary, Color secondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: primary.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text(
            loc.noConversations,
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color primary, Color secondary) {
    return Positioned(
      bottom: 25,
      left: 60,
      right: 60,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary, secondary]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.chat_bubble, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 30), onPressed: () {}),
            IconButton(icon: const Icon(Icons.phone, color: Colors.white), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 20);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2.25, 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 3.25), 65);
    var secondEndPoint = Offset(size.width, 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
