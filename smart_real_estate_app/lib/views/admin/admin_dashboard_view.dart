import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_real_estate_app/providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  Map<String, dynamic> _stats = {
    'totalProperties': 0, 'totalUsers': 0, 'activeListings': 0,
    'totalReviews': 0, 'monthlyViews': 0, 'monthlyInquiries': 0,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ApiService.getAdminStats();
    if (mounted) setState(() { _stats = stats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    final cards = [
      _StatCardData(
        title: 'إجمالي العقارات',
        value: '${stats['totalProperties']}',
        icon: Icons.home_work_rounded,
        gradientColors: const [Color(0xFF1A3A5C), Color(0xFF2E5FA3)],
        trend: '+12%',
      ),
      _StatCardData(
        title: 'المستخدمون',
        value: '${stats['totalUsers']}',
        icon: Icons.people_rounded,
        gradientColors: const [Color(0xFF2E86AB), Color(0xFF54C6E8)],
        trend: '+8%',
      ),
      _StatCardData(
        title: 'الإعلانات النشطة',
        value: '${stats['activeListings']}',
        icon: Icons.check_circle_rounded,
        gradientColors: const [Color(0xFF27AE60), Color(0xFF2ECC71)],
        trend: '+5%',
      ),
      _StatCardData(
        title: 'التقييمات',
        value: '${stats['totalReviews']}',
        icon: Icons.star_rounded,
        gradientColors: const [Color(0xFFD4A853), Color(0xFFF4C842)],
        trend: '+21%',
      ),
      _StatCardData(
        title: 'الزيارات الشهرية',
        value: '${stats['monthlyViews']}',
        icon: Icons.visibility_rounded,
        gradientColors: const [Color(0xFFE8963E), Color(0xFFFF7043)],
        trend: '+18%',
      ),
      _StatCardData(
        title: 'الاستفسارات',
        value: '${stats['monthlyInquiries']}',
        icon: Icons.question_answer_rounded,
        gradientColors: const [Color(0xFF8E44AD), Color(0xFFBB6BD9)],
        trend: '+34%',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { setState(() => _loading = true); _loadStats(); },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRevenueHeader(stats),
            const SizedBox(height: 24),
            Builder(
              builder: (context) => Text(
                'نظرة عامة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.3,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) => _buildStatCard(cards[index]),
            ),
            const SizedBox(height: 32),
            Builder(
              builder: (context) => Text(
                'الإجراءات السريعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              context,
              Icons.people_outlined,
              'إدارة المستخدمين',
              'عرض وإدارة حسابات المستخدمين',
              const [Color(0xFF1A3A5C), Color(0xFF2E5FA3)],
              () => context.push('/admin/users'),
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              Icons.home_work_outlined,
              'إدارة العقارات',
              'مراجعة وإدارة العقارات المنشورة',
              const [Color(0xFF2E86AB), Color(0xFF54C6E8)],
              () => context.push('/admin/properties'),
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              Icons.reviews_outlined,
              'إدارة التقييمات',
              'مراقبة ومراجعة التقييمات',
              const [Color(0xFFD4A853), Color(0xFFF4C842)],
              () => context.push('/admin/reviews'),
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              Icons.analytics_outlined,
              'التقارير والإحصائيات',
              'عرض تقارير تفصيلية عن أداء المنصة',
              const [Color(0xFF8E44AD), Color(0xFFBB6BD9)],
              () => context.push('/admin/reports'),
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              Icons.account_balance_wallet_outlined,
              'إدارة المدفوعات',
              'عرض وإدارة جميع المعاملات المالية',
              const [Color(0xFF0F9B58), Color(0xFF00BFA5)],
              () => context.push('/admin/payments'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueHeader(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A5C), Color(0xFF2E86AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3A5C).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإيرادات الشهرية',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up,
                        color: AppTheme.successColor, size: 14),
                    const SizedBox(width: 4),
                    const Text(
                      '+23% هذا الشهر',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(stats['revenue'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} SAR',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'مارس 2026',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(_StatCardData data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, color: Colors.white.withValues(alpha: 0.9), size: 26),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward,
                        color: Colors.white, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      data.trend,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final String trend;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.trend,
  });
}
