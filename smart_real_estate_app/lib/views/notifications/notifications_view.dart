import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<_NotifItem> _notifications = [];
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    final data = await ApiService.getNotifications(userId);
    if (data.isNotEmpty && mounted) {
      setState(() {
        _notifications = data.map((n) => _NotifItem(
          icon: _iconForType(n['type'] ?? 'system'),
          color: _colorForType(n['type'] ?? 'system'),
          title: n['title'] ?? '',
          body: n['body'] ?? '',
          time: _formatTime(n['created_at']),
          isRead: n['is_read'] == 1 || n['is_read'] == true,
          category: n['type'] ?? 'system',
          id: n['id'] is int ? n['id'] : int.tryParse(n['id'].toString()) ?? 0,
        )).toList();
      });
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'message':     return Icons.chat_bubble_outline;
      case 'property':    return Icons.home_work;
      case 'review':      return Icons.star_outline;
      case 'appointment': return Icons.calendar_today;
      case 'promotion':   return Icons.local_offer_outlined;
      default:            return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'message':     return Colors.blue;
      case 'property':    return Colors.teal;
      case 'review':      return Colors.amber;
      case 'appointment': return Colors.purple;
      case 'promotion':   return Colors.green;
      default:            return Colors.grey;
    }
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      return 'منذ ${diff.inDays} يوم';
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initNotifications(AppLocalizations l) {
    if (_notifications.isNotEmpty) return;
    _notifications = [
      _NotifItem(
        icon: Icons.home_work,
        color: Colors.teal,
        title: l.isArabic ? 'عقار جديد يطابق بحثك' : 'New property matches your search',
        body: l.isArabic ? 'فيلا فاخرة في حي الملقا تطابق معايير بحثك' : 'Luxury villa in Al-Malqa matches your criteria',
        time: l.minutesAgo(10),
        isRead: false,
        category: 'property',
      ),
      _NotifItem(
        icon: Icons.trending_down,
        color: Colors.green,
        title: l.isArabic ? 'انخفاض في السعر!' : 'Price Drop!',
        body: l.isArabic ? 'العقار المفضل لديك انخفض بنسبة 15%' : 'Your favorite property dropped by 15%',
        time: l.minutesAgo(25),
        isRead: false,
        category: 'property',
      ),
      _NotifItem(
        icon: Icons.star,
        color: const Color(0xFFD4A853),
        title: l.isArabic ? 'تقييم جديد' : 'New Review',
        body: l.isArabic ? 'حصل عقارك على تقييم 5 نجوم' : 'Your property got a 5-star review',
        time: l.hoursAgo(1),
        isRead: false,
        category: 'activity',
      ),
      _NotifItem(
        icon: Icons.chat_bubble,
        color: Colors.blue,
        title: l.isArabic ? 'رسالة جديدة' : 'New Message',
        body: l.isArabic ? 'لديك رسالة جديدة من أحمد العمري' : 'New message from Ahmed Al-Omari',
        time: l.hoursAgo(3),
        isRead: true,
        category: 'messages',
      ),
      _NotifItem(
        icon: Icons.favorite,
        color: const Color(0xFFE74C3C),
        title: l.isArabic ? 'تم حفظ العقار' : 'Property Saved',
        body: l.isArabic ? 'تم إضافة بنتهاوس الكورنيش إلى مفضلتك' : 'Corniche penthouse added to favorites',
        time: l.daysAgo(1),
        isRead: true,
        category: 'activity',
      ),
      _NotifItem(
        icon: Icons.auto_awesome,
        color: const Color(0xFFE8963E),
        title: l.isArabic ? 'توصيات جديدة' : 'New Recommendations',
        body: l.isArabic ? 'لدينا 3 عقارات جديدة مقترحة لك' : '3 new properties recommended for you',
        time: l.daysAgo(2),
        isRead: true,
        category: 'property',
      ),
      _NotifItem(
        icon: Icons.description,
        color: Colors.indigo,
        title: l.isArabic ? 'تحديث العقد' : 'Contract Update',
        body: l.isArabic ? 'تم تحديث عقد الإيجار الخاص بك' : 'Your rental contract has been updated',
        time: l.daysAgo(3),
        isRead: true,
        category: 'system',
      ),
      _NotifItem(
        icon: Icons.payment,
        color: Colors.green,
        title: l.isArabic ? 'تأكيد الدفع' : 'Payment Confirmed',
        body: l.isArabic ? 'تم تأكيد دفعة بقيمة 5,000 ريال' : 'Payment of 5,000 SAR confirmed',
        time: l.daysAgo(5),
        isRead: true,
        category: 'system',
      ),
    ];
  }

  List<_NotifItem> get _filtered {
    if (_selectedCategory == 'all') return _notifications;
    return _notifications.where((n) => n.category == _selectedCategory).toList();
  }

  void _markAllRead() async {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await ApiService.markNotificationsRead(userId);
    }
  }

  void _removeNotification(int index) {
    final items = _filtered;
    final item = items[index];
    setState(() {
      _notifications.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).isArabic ? 'تم الحذف' : 'Deleted'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: AppLocalizations.of(context).isArabic ? 'تراجع' : 'Undo',
          onPressed: () {
            setState(() => _notifications.insert(index, item));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final primary = themeProvider.currentScheme.primary;
    final secondary = themeProvider.currentScheme.secondary;
    _initNotifications(l);

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.notifications, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, secondary]),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30, bottom: 30),
                    child: Icon(Icons.notifications_active, size: 80, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                ),
              ),
            ),
            actions: [
              if (unreadCount > 0)
                TextButton.icon(
                  onPressed: _markAllRead,
                  icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
                  label: Text(l.isArabic ? 'قراءة الكل' : 'Read All',
                      style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
          // Category filters
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('all', l.isArabic ? 'الكل' : 'All', Icons.notifications, primary, isDark),
                  _buildCategoryChip('property', l.isArabic ? 'العقارات' : 'Properties', Icons.home, Colors.teal, isDark),
                  _buildCategoryChip('messages', l.isArabic ? 'الرسائل' : 'Messages', Icons.chat, Colors.blue, isDark),
                  _buildCategoryChip('activity', l.isArabic ? 'النشاط' : 'Activity', Icons.local_activity, Colors.orange, isDark),
                  _buildCategoryChip('system', l.isArabic ? 'النظام' : 'System', Icons.settings, Colors.purple, isDark),
                ],
              ),
            ),
          ),

          // Notifications list
          _filtered.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 80, color: primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          l.isArabic ? 'لا توجد إشعارات' : 'No notifications',
                          style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notif = _filtered[index];
                      return Dismissible(
                        key: Key('notif_${notif.title}_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) => _removeNotification(index),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => notif.isRead = true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: notif.isRead
                                  ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                                  : primary.withValues(alpha: isDark ? 0.15 : 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: notif.isRead ? null : Border.all(color: primary.withValues(alpha: 0.15)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: notif.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(notif.icon, color: notif.color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif.title,
                                              style: GoogleFonts.cairo(
                                                fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (!notif.isRead)
                                            Container(
                                              width: 8, height: 8,
                                              decoration: BoxDecoration(color: secondary, shape: BoxShape.circle),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.body,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: isDark ? Colors.white60 : Colors.grey[600],
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notif.time,
                                        style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _filtered.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, IconData icon, Color color, bool isDark) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.cairo(
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = category);
        },
        selectedColor: color,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}

class _NotifItem {
  final int id;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  bool isRead;
  final String category;

  _NotifItem({
    this.id = 0,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.category,
  });
}
