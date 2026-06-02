import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/mock_data_service.dart';

class AdminReportsView extends StatefulWidget {
  const AdminReportsView({Key? key}) : super(key: key);

  @override
  State<AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<AdminReportsView> {
  String _selectedPeriod = 'This Month';
  Map<String, dynamic> _apiStats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ApiService.getAdminStats();
    if (mounted) setState(() => _apiStats = stats);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = themeProvider.currentScheme;
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(l10n, colorScheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(l10n, colorScheme, isDark),
                  const SizedBox(height: 20),
                  _buildSummaryGrid(l10n, colorScheme, isDark),
                  const SizedBox(height: 24),
                  _buildRevenueChart(l10n, colorScheme, isDark),
                  const SizedBox(height: 24),
                  _buildPropertyTypesChart(l10n, colorScheme, isDark),
                  const SizedBox(height: 24),
                  _buildTopCitiesTable(l10n, colorScheme, isDark),
                  const SizedBox(height: 24),
                  _buildRecentActivity(l10n, colorScheme, isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l10n, ThemeColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          l10n.isArabic ? 'التقارير والإحصائيات' : 'Reports & Analytics',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colorScheme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n, ThemeColorScheme colorScheme, bool isDark) {
    final periods = [
      {'key': 'This Month', 'ar': 'هذا الشهر', 'en': 'This Month'},
      {'key': 'Last 3 Months', 'ar': 'آخر 3 أشهر', 'en': 'Last 3 Months'},
      {'key': 'This Year', 'ar': 'هذه السنة', 'en': 'This Year'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.isArabic ? period['ar']! : period['en']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryGrid(AppLocalizations l10n, ThemeColorScheme colorScheme, bool isDark) {
    final mockStats = MockDataService.getDashboardStats();
    final stats = _apiStats.isNotEmpty ? {
      'revenue': _apiStats['revenue'] ?? mockStats['revenue'],
      'totalProperties': _apiStats['totalProperties'] ?? mockStats['totalProperties'],
      'totalUsers': _apiStats['totalUsers'] ?? mockStats['totalUsers'],
      'monthlyViews': _apiStats['monthlyViews'] ?? mockStats['monthlyViews'],
      'monthlyInquiries': _apiStats['monthlyInquiries'] ?? mockStats['monthlyInquiries'],
      'soldProperties': _apiStats['soldProperties'] ?? mockStats['soldProperties'],
    } : mockStats;
    final items = [
      {
        'label': l10n.isArabic ? 'إجمالي الإيرادات' : 'Total Revenue',
        'value': '${stats['revenue']} ${l10n.sar}',
        'icon': Icons.account_balance_wallet,
        'color': Colors.green
      },
      {
        'label': l10n.isArabic ? 'العقارات' : 'Properties',
        'value': stats['totalProperties'].toString(),
        'icon': Icons.home,
        'color': Colors.blue
      },
      {
        'label': l10n.isArabic ? 'المستخدمين' : 'Users',
        'value': stats['totalUsers'].toString(),
        'icon': Icons.people,
        'color': Colors.orange
      },
      {
        'label': l10n.isArabic ? 'المشاهدات' : 'Views',
        'value': stats['monthlyViews'].toString(),
        'icon': Icons.visibility,
        'color': Colors.purple
      },
      {
        'label': l10n.isArabic ? 'الاستفسارات' : 'Inquiries',
        'value': stats['monthlyInquiries'].toString(),
        'icon': Icons.question_answer,
        'color': Colors.amber
      },
      {
        'label': l10n.isArabic ? 'الصفقات' : 'Deals',
        'value': stats['soldProperties'].toString(),
        'icon': Icons.handshake,
        'color': Colors.teal
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                  const Icon(Icons.trending_up, color: Colors.green, size: 16),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['value'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    item['label'] as String,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart(AppLocalizations l10n, ThemeColorScheme colorScheme, bool isDark) {
    final months = l10n.isArabic 
        ? ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final values = [45000, 62000, 58000, 85000, 72000, 95000];
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isArabic ? 'الإيرادات الشهرية' : 'Monthly Revenue',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = (constraints.maxWidth - (months.length - 1) * 12) / months.length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(months.length, (index) {
                    final heightFactor = values[index] / maxValue;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(values[index] / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: barWidth,
                          height: 150 * heightFactor,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorScheme.primary, colorScheme.secondary],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[index],
                          style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypesChart(AppLocalizations l10n, ThemeColorScheme colorScheme, bool isDark) {
    final types = [
      {'label': l10n.villa, 'count': 45, 'color': Colors.blue},
      {'label': l10n.apartment, 'count': 35, 'color': Colors.orange},
      {'label': l10n.commercial, 'count': 12, 'color': Colors.green},
      {'label': l10n.land, 'count': 8, 'color': Colors.red},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isArabic ? 'توزيع أنواع العقارات' : 'Property Types Distribution',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ...types.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(type['label'] as String, style: const TextStyle(fontSize: 13)),
                      Text('${type['count']}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (type['count'] as int) / 100,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: type['color'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopCitiesTable(AppLocalizations l10n, ThemeColorScheme colorScheme, bool isDark) {
    final cities = [
      {'name': l10n.isArabic ? 'الرياض' : 'Riyadh', 'count': 124, 'price': '2.1M', 'trend': 'up'},
      {'name': l10n.isArabic ? 'جدة' : 'Jeddah', 'count': 89, 'price': '1.8M', 'trend': 'up'},
      {'name': l10n.isArabic ? 'الدمام' : 'Dammam', 'count': 56, 'price': '1.2M', 'trend': 'down'},
      {'name': l10n.isArabic ? 'الخبر' : 'Khobar', 'count': 42, 'price': '1.5M', 'trend': 'up'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isArabic ? 'أكثر المدن نشاطاً' : 'Top Active Cities',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(0.5),
            },
            children: [
              TableRow(
                children: [
                  _buildTableCell(l10n.isArabic ? 'المدينة' : 'City', isHeader: true),
                  _buildTableCell(l10n.isArabic ? 'العقارات' : 'Props', isHeader: true),
                  _buildTableCell(l10n.isArabic ? 'متوسط السعر' : 'Avg Price', isHeader: true),
                  const SizedBox(),
                ],
              ),
              ...cities.map((city) {
                return TableRow(
                  children: [
                    _buildTableCell(city['name'] as String),
                    _buildTableCell(city['count'].toString()),
                    _buildTableCell(city['price'] as String),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Icon(
                        city['trend'] == 'up' ? Icons.trending_up : Icons.trending_down,
                        color: city['trend'] == 'up' ? Colors.green : Colors.red,
                        size: 16,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 12 : 13,
          color: isHeader ? Colors.grey : null,
        ),
      ),
    );
  }

  Widget _buildRecentActivity(AppLocalizations l10n, ThemeColorScheme colorScheme, bool isDark) {
    final activities = [
      {'title': 'New user registered', 'time': '5 mins ago', 'icon': Icons.person_add, 'color': Colors.blue},
      {'title': 'Property sold in Riyadh', 'time': '1 hour ago', 'icon': Icons.sell, 'color': Colors.green},
      {'title': 'New review flagged', 'time': '3 hours ago', 'icon': Icons.flag, 'color': Colors.red},
      {'title': 'Payment received #4521', 'time': '5 hours ago', 'icon': Icons.payment, 'color': Colors.orange},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isArabic ? 'آخر النشاطات' : 'Recent Activity',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (activity['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(activity['time'] as String, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
