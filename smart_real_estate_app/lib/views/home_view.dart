import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';
import '../widgets/property_card.dart';
import '../widgets/market_trends_card.dart';
import '../widgets/map_preview_card.dart';

const double _kWebBreakpoint = 800.0;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final propertyProvider = context.watch<PropertyProvider>();
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= _kWebBreakpoint;

    if (propertyProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isWide) {
      return _buildWebDashboard(auth, propertyProvider, loc, theme);
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => propertyProvider.loadProperties(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(auth, loc, theme)),
              SliverToBoxAdapter(child: _buildCategoryChips(loc, theme)),
              if (propertyProvider.recommendedProperties.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: theme.colorScheme.tertiary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          loc.aiRecommendations,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildRecommendedList(
                      propertyProvider.recommendedProperties, theme),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Row(
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        loc.marketTrends,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MarketTrendsCard(
                  city: propertyProvider.allProperties.isNotEmpty
                      ? (propertyProvider.allProperties.first.location ??
                          (loc.isArabic ? 'الرياض' : 'Riyadh'))
                      : (loc.isArabic ? 'الرياض' : 'Riyadh'),
                ),
              ),
              const SliverToBoxAdapter(
                child: MapPreviewCard(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.latestProperties,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        loc.viewAll,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property =
                          propertyProvider.allProperties[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PropertyCard(
                          property: property,
                          onTap: () => context.push('/property',
                              extra: property),
                          onFavorite: () => propertyProvider
                              .toggleFavorite(property, userId: auth.currentUser?.id),
                        ),
                      );
                    },
                    childCount: propertyProvider.allProperties.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebDashboard(
    AuthProvider auth,
    PropertyProvider propertyProvider,
    AppLocalizations loc,
    ThemeData theme,
  ) {
    final themeProvider = context.watch<ThemeProvider>();
    final gradient = themeProvider.currentScheme.gradient;
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF12121E) : const Color(0xFFF4F6FB);
    final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final all = propertyProvider.allProperties;

    final totalCount = all.length;
    final availableCount = all.where((p) => p.status == 'available' || p.status == null).length;
    final soldCount = all.where((p) => p.status == 'sold').length;
    final cities = all.map((p) => p.location).whereType<String>().toSet().length;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () => propertyProvider.loadProperties(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                child: _buildWebGreeting(auth, loc, theme, gradient, isDark, cardBg),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                child: _buildStatsRow(totalCount, availableCount, soldCount, cities, gradient, theme, isDark, cardBg, loc),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: _buildWebQuickActions(theme, gradient, isDark, cardBg, loc),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildWebPropertiesPanel(propertyProvider, auth, theme, gradient, isDark, cardBg, loc),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 300,
                      child: _buildWebSidePanel(propertyProvider, theme, gradient, isDark, cardBg, loc),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildWebGreeting(
    AuthProvider auth,
    AppLocalizations loc,
    ThemeData theme,
    List<Color> gradient,
    bool isDark,
    Color cardBg,
  ) {
    final name = auth.currentUser?.name ?? (loc.isArabic ? 'زائر' : 'Guest');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.helloUser(name),
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.findDreamHome,
                  style: GoogleFonts.cairo(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _webSearchBar(theme, gradient),
                    const SizedBox(width: 12),
                    _webHeaderAction(
                      Icons.notifications_outlined,
                      loc.isArabic ? 'الإشعارات' : 'Notifications',
                      () => context.push('/notifications'),
                    ),
                    const SizedBox(width: 8),
                    _webHeaderAction(
                      Icons.map_rounded,
                      loc.isArabic ? 'الخريطة' : 'Map',
                      () => context.push('/map'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home_work_rounded, size: 64, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _webSearchBar(ThemeData theme, List<Color> gradient) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              Text(
                'ابحث عن عقار...',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _webHeaderAction(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    int total,
    int available,
    int sold,
    int cities,
    List<Color> gradient,
    ThemeData theme,
    bool isDark,
    Color cardBg,
    AppLocalizations loc,
  ) {
    return Row(
      children: [
        _statCard(
          icon: Icons.home_work_rounded,
          label: loc.isArabic ? 'إجمالي العقارات' : 'Total Properties',
          value: total.toString(),
          gradient: [gradient.first, gradient.last],
          cardBg: cardBg,
          isDark: isDark,
          theme: theme,
        ),
        const SizedBox(width: 14),
        _statCard(
          icon: Icons.check_circle_outline_rounded,
          label: loc.isArabic ? 'متاح للبيع' : 'Available',
          value: available.toString(),
          gradient: [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
          cardBg: cardBg,
          isDark: isDark,
          theme: theme,
        ),
        const SizedBox(width: 14),
        _statCard(
          icon: Icons.handshake_outlined,
          label: loc.isArabic ? 'تم البيع' : 'Sold',
          value: sold.toString(),
          gradient: [const Color(0xFF3498DB), const Color(0xFF2980B9)],
          cardBg: cardBg,
          isDark: isDark,
          theme: theme,
        ),
        const SizedBox(width: 14),
        _statCard(
          icon: Icons.location_city_rounded,
          label: loc.isArabic ? 'المدن' : 'Cities',
          value: cities.toString(),
          gradient: [const Color(0xFFE67E22), const Color(0xFFD35400)],
          cardBg: cardBg,
          isDark: isDark,
          theme: theme,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
    required Color cardBg,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebQuickActions(
    ThemeData theme,
    List<Color> gradient,
    bool isDark,
    Color cardBg,
    AppLocalizations loc,
  ) {
    final actions = [
      _QuickAction(Icons.calculate_rounded, loc.isArabic ? 'حاسبة الرهن' : 'Mortgage Calc', '/mortgage-calculator', gradient),
      _QuickAction(Icons.trending_up_rounded, loc.isArabic ? 'حاسبة الاستثمار' : 'Investment', '/investment-calculator', [const Color(0xFF2ECC71), const Color(0xFF27AE60)]),
      _QuickAction(Icons.compare_arrows_rounded, loc.isArabic ? 'مقارنة عقارات' : 'Compare', '/compare-properties', [const Color(0xFF3498DB), const Color(0xFF2980B9)]),
      _QuickAction(Icons.smart_toy_rounded, loc.isArabic ? 'مساعد الذكاء' : 'AI Assistant', '/ai-assistant', [const Color(0xFF9B59B6), const Color(0xFF8E44AD)]),
      _QuickAction(Icons.description_rounded, loc.isArabic ? 'عقودي' : 'Contracts', '/contracts', [const Color(0xFFE67E22), const Color(0xFFD35400)]),
      _QuickAction(Icons.location_on_rounded, loc.isArabic ? 'الخريطة' : 'Map', '/map', [const Color(0xFF1ABC9C), const Color(0xFF16A085)]),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                loc.isArabic ? 'إجراءات سريعة' : 'Quick Actions',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: actions.map((action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _quickActionBtn(action, theme, isDark),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _quickActionBtn(_QuickAction action, ThemeData theme, bool isDark) {
    return InkWell(
      onTap: () => context.push(action.route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF3A3A50) : const Color(0xFFE8EAF6),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: action.gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPropertiesPanel(
    PropertyProvider propertyProvider,
    AuthProvider auth,
    ThemeData theme,
    List<Color> gradient,
    bool isDark,
    Color cardBg,
    AppLocalizations loc,
  ) {
    final all = propertyProvider.allProperties;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  loc.latestProperties,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Flexible(child: _buildFilterChips(loc, theme, gradient)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: all.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        loc.isArabic ? 'لا توجد عقارات' : 'No properties found',
                        style: GoogleFonts.cairo(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: all.length,
                    itemBuilder: (context, index) {
                      final property = all[index];
                      return PropertyCard(
                        property: property,
                        onTap: () => context.push('/property', extra: property),
                        onFavorite: () => propertyProvider.toggleFavorite(property, userId: auth.currentUser?.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations loc, ThemeData theme, List<Color> gradient) {
    final types = ['all', ...AppConstants.propertyTypes.take(4)];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((type) {
          final isAll = type == 'all';
          final isSelected = isAll ? _selectedType == null : _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = isAll ? null : (isSelected ? null : type);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(colors: gradient) : null,
                  color: isSelected ? null : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isAll ? (loc.isArabic ? 'الكل' : 'All') : loc.getPropertyType(type),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWebSidePanel(
    PropertyProvider propertyProvider,
    ThemeData theme,
    List<Color> gradient,
    bool isDark,
    Color cardBg,
    AppLocalizations loc,
  ) {
    final recommended = propertyProvider.recommendedProperties;
    final city = propertyProvider.allProperties.isNotEmpty
        ? (propertyProvider.allProperties.first.location ?? (loc.isArabic ? 'الرياض' : 'Riyadh'))
        : (loc.isArabic ? 'الرياض' : 'Riyadh');

    return Column(
      children: [
        if (recommended.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: theme.colorScheme.tertiary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        loc.aiRecommendations,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                ...recommended.take(3).map((p) => _recommendedListItem(p, theme, isDark, gradient)),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, color: theme.colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      loc.marketTrends,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                child: MarketTrendsCard(city: city),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recommendedListItem(Property property, ThemeData theme, bool isDark, List<Color> gradient) {
    return InkWell(
      onTap: () => context.push('/property', extra: property),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: property.images.isNotEmpty
                  ? Image.network(
                      property.images.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.home, color: Colors.white, size: 28),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.home, color: Colors.white, size: 28),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    property.priceFormatted,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  if (property.location != null)
                    Text(
                      property.location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth, AppLocalizations loc, ThemeData theme) {
    final themeProvider = context.watch<ThemeProvider>();
    final gradientColors = themeProvider.currentScheme.gradient;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
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
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.helloUser(auth.currentUser?.name ?? (loc.isArabic ? 'زائر' : 'Guest')),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.findDreamHome,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () => context.push('/notifications'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.searchHint,
                      style: GoogleFonts.cairo(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(Icons.tune, color: theme.colorScheme.secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(AppLocalizations loc, ThemeData theme) {
    final themeProvider = context.watch<ThemeProvider>();
    final gradientColors = themeProvider.currentScheme.gradient;

    return SizedBox(
      height: 132,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: AppConstants.propertyTypes.map((type) {
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = isSelected ? null : type;
                });
                context.read<PropertyProvider>().filterByType(isSelected ? null : type);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      gradient: isSelected
                          ? LinearGradient(colors: gradientColors)
                          : null,
                    ),
                    child: Icon(
                      AppConstants.propertyTypeIcons[type],
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.getPropertyType(type),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendedList(List<Property> recommended, ThemeData theme) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recommended.length,
        itemBuilder: (context, index) {
          final property = recommended[index];
          return GestureDetector(
            onTap: () => context.push('/property', extra: property),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: property.images.isNotEmpty
                          ? Image.network(
                              property.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                child: Icon(Icons.image,
                                    size: 48,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4)),
                              ),
                            )
                          : Container(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              child: Icon(Icons.image,
                                  size: 48,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4)),
                            ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('AI',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            property.priceFormatted,
                            style: GoogleFonts.cairo(
                              color: theme.colorScheme.tertiary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  property.location ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;
  final List<Color> gradient;
  const _QuickAction(this.icon, this.label, this.route, this.gradient);
}
