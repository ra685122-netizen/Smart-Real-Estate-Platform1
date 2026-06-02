import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/property_model.dart';
import '../models/review_model.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class PropertyDetailsView extends StatefulWidget {
  final Property property;

  const PropertyDetailsView({Key? key, required this.property})
      : super(key: key);

  @override
  State<PropertyDetailsView> createState() => _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends State<PropertyDetailsView> {
  int _currentImageIndex = 0;
  List<Review> _reviews = [];
  bool _loadingReviews = true;
  final PageController _imagePageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await ApiService.getReviews(propertyId: widget.property.id);
    if (mounted) setState(() { _reviews = reviews; _loadingReviews = false; });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final primary = themeProvider.currentScheme.primary;
    final secondary = themeProvider.currentScheme.secondary;
    final textColor = theme.colorScheme.onSurface;
    final subtextColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: cardBg,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: cardBg,
                  child: IconButton(
                    icon: Icon(
                      property.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 20,
                      color: property.isFavorite
                          ? AppTheme.errorColor
                          : textColor,
                    ),
                    onPressed: () {
                      final userId = context.read<AuthProvider>().currentUser?.id;
                      context.read<PropertyProvider>().toggleFavorite(property, userId: userId);
                      setState(() {});
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  backgroundColor: cardBg,
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: property.images.isEmpty ? 1 : property.images.length,
                    onPageChanged: (i) => setState(() => _currentImageIndex = i),
                    itemBuilder: (context, index) {
                      if (property.images.isEmpty) {
                        return Container(
                          color: primary.withValues(alpha: 0.1),
                          child: Center(
                            child: Icon(Icons.home_work_outlined,
                                size: 80, color: subtextColor),
                          ),
                        );
                      }
                      return Image.network(
                        property.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                          child: Icon(Icons.image, size: 64, color: subtextColor),
                        ),
                      );
                    },
                  ),
                  if (property.images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          property.images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${property.images.isEmpty ? 1 : property.images.length}',
                        style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (property.propertyType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l.getPropertyType(property.propertyType!),
                            style: GoogleFonts.cairo(
                              color: primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${property.price.toStringAsFixed(0)} ${l.sar}',
                    style: GoogleFonts.cairo(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (property.location != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.accentColor, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          property.location!,
                          style: GoogleFonts.cairo(fontSize: 15, color: subtextColor),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (property.bedrooms != null)
                          _buildDetailItem(Icons.bed, '${property.bedrooms}',
                              l.bedrooms, primary, textColor, subtextColor),
                        if (property.bathrooms != null)
                          _buildDetailItem(Icons.bathtub, '${property.bathrooms}',
                              l.bathrooms, primary, textColor, subtextColor),
                        if (property.area != null)
                          _buildDetailItem(Icons.square_foot,
                              '${property.area!.toStringAsFixed(0)}',
                              l.sqm, primary, textColor, subtextColor),
                        _buildDetailItem(
                            Icons.check_circle,
                            property.status == 'available' ? l.available : l.sold,
                            l.status, primary, textColor, subtextColor),
                      ],
                    ),
                  ),
                  if (property.area != null && property.area! > 0) ...[
                    const SizedBox(height: 12),
                    _buildAiPriceAnalysis(property, l, subtextColor),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    l.description,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description.isNotEmpty
                        ? property.description
                        : l.noDescription,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: subtextColor,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.virtualTour,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.push('/virtual-tour', extra: {
                      'title': property.title,
                      'id': property.id,
                    }),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: secondary.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: property.images.isNotEmpty
                                  ? Image.network(
                                      property.images.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]),
                                    )
                                  : Container(color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.2),
                                      Colors.black.withValues(alpha: 0.5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [primary, secondary]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.threesixty, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('360° VR', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    l.startTour,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/map'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [primary, secondary]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.map, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.viewOnMap, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
                                Text(property.location ?? '', style: GoogleFonts.cairo(fontSize: 12, color: subtextColor)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: subtextColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (property.ownerName != null) ...[
                    Text(
                      l.ownerInfo,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: primary.withValues(alpha: 0.1),
                            child: Text(
                              property.ownerName![0],
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.ownerName!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l.propertyOwner,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.phone, color: secondary),
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/chat/2'),
                            icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.chat_bubble, color: primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildReviewsSection(l, textColor, subtextColor, secondary, primary, cardBg),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: cardBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showMortgageCalculator(widget.property.price, l, primary, secondary, textColor, subtextColor, isDark),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calculate_outlined, color: AppTheme.accentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l.mortgageCalc,
                        style: GoogleFonts.cairo(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/chat/2'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        l.contactOwner,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Icon(Icons.phone, color: primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiPriceAnalysis(Property property, AppLocalizations l, Color subtextColor) {
    final pricePerM2 = property.price / property.area!;
    final avgMarket = _getMarketAvg(property.propertyType ?? 'apartment');
    final diff = ((pricePerM2 - avgMarket) / avgMarket * 100);
    final isBelow = diff < -5;
    final isAbove = diff > 10;
    final color = isBelow
        ? AppTheme.successColor
        : isAbove
            ? AppTheme.errorColor
            : AppTheme.accentColor;
    final label = isBelow
        ? (l.isArabic
            ? 'أقل من السوق بـ ${diff.abs().toStringAsFixed(0)}%'
            : '${diff.abs().toStringAsFixed(0)}% below market')
        : isAbove
            ? (l.isArabic
                ? 'أعلى من السوق بـ ${diff.toStringAsFixed(0)}%'
                : '${diff.toStringAsFixed(0)}% above market')
            : (l.isArabic ? 'سعر مناسب للسوق' : 'Fair market price');
    final icon = isBelow
        ? Icons.trending_down
        : isAbove
            ? Icons.trending_up
            : Icons.check_circle_outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: GoogleFonts.cairo(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l.isArabic
                      ? 'سعر المتر: ${pricePerM2.toStringAsFixed(0)} SAR/م²  •  متوسط المنطقة: ${avgMarket.toStringAsFixed(0)} SAR/م²'
                      : 'Price/sqm: ${pricePerM2.toStringAsFixed(0)} SAR  •  Avg: ${avgMarket.toStringAsFixed(0)} SAR',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: subtextColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getMarketAvg(String type) {
    switch (type) {
      case 'villa':
        return 4500;
      case 'apartment':
        return 5500;
      case 'commercial':
        return 800;
      case 'land':
        return 1200;
      case 'office':
        return 2000;
      default:
        return 4000;
    }
  }

  Widget _buildDetailItem(IconData icon, String value, String label,
      Color primary, Color textColor, Color subtextColor) {
    return Column(
      children: [
        Icon(icon, color: primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: subtextColor),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(AppLocalizations l, Color textColor,
      Color subtextColor, Color secondary, Color primary, Color cardBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.reviews,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddReviewSheet(l, textColor, cardBg),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.addReview),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '4.7',
              style: GoogleFonts.cairo(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < 4 ? Icons.star : Icons.star_half,
                      color: AppTheme.goldColor,
                      size: 20,
                    ),
                  ),
                ),
                Text(
                  '${_reviews.length} ${l.reviews}',
                  style: GoogleFonts.cairo(fontSize: 13, color: subtextColor),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loadingReviews)
          const Center(child: CircularProgressIndicator())
        else
          ..._reviews.map((review) => _buildReviewCard(
              review, l, textColor, subtextColor, secondary, cardBg)),
      ],
    );
  }

  Widget _buildReviewCard(Review review, AppLocalizations l, Color textColor,
      Color subtextColor, Color secondary, Color cardBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: secondary.withValues(alpha: 0.1),
                child: Text(
                  review.userName?[0] ?? '?',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    color: secondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? (l.isArabic ? 'مجهول' : 'Anonymous'),
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_outline,
                          color: AppTheme.goldColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (review.createdAt != null)
                Text(
                  _timeAgo(review.createdAt!, l),
                  style: GoogleFonts.cairo(fontSize: 12, color: subtextColor),
                ),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: subtextColor,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime date, AppLocalizations l) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) {
      final months = diff.inDays ~/ 30;
      return l.isArabic ? 'منذ $months شهر' : '${months}mo ago';
    }
    if (diff.inDays > 0) return l.daysAgo(diff.inDays);
    if (diff.inHours > 0) return l.hoursAgo(diff.inHours);
    return l.isArabic ? 'الآن' : 'Just now';
  }

  void _showMortgageCalculator(double propertyPrice, AppLocalizations l,
      Color primary, Color secondary, Color textColor, Color subtextColor, bool isDark) {
    double downPaymentPct = 20;
    double interestRate = 4.5;
    int loanYears = 20;

    double calcMonthly(double dp, double rate, int years) {
      final principal = propertyPrice * (1 - dp / 100);
      if (principal <= 0) return 0;
      final monthlyRate = rate / 100 / 12;
      final n = years * 12;
      if (monthlyRate == 0) return principal / n;
      return principal *
          monthlyRate *
          _pow(1 + monthlyRate, n) /
          (_pow(1 + monthlyRate, n) - 1);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final monthly = calcMonthly(downPaymentPct, interestRate, loanYears);
            final downAmount = propertyPrice * downPaymentPct / 100;
            final loanAmount = propertyPrice - downAmount;
            final totalPaid = monthly * loanYears * 12;

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: subtextColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calculate_outlined,
                                color: AppTheme.accentColor),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l.mortgageCalc,
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primary, secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l.isArabic ? 'القسط الشهري التقديري' : 'Estimated Monthly Payment',
                              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${monthly.toStringAsFixed(0)} ${l.sar}',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _calcStat(l.isArabic ? 'مبلغ القرض' : 'Loan',
                                    '${(loanAmount / 1000).toStringAsFixed(0)}K'),
                                Container(width: 1, height: 36, color: Colors.white24),
                                _calcStat(l.isArabic ? 'الدفعة الأولى' : 'Down',
                                    '${downPaymentPct.toInt()}%'),
                                Container(width: 1, height: 36, color: Colors.white24),
                                _calcStat(l.isArabic ? 'إجمالي السداد' : 'Total',
                                    '${(totalPaid / 1000).toStringAsFixed(0)}K'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l.isArabic
                            ? 'الدفعة الأولى: ${downPaymentPct.toInt()}% (${downAmount.toStringAsFixed(0)} SAR)'
                            : 'Down Payment: ${downPaymentPct.toInt()}% (${downAmount.toStringAsFixed(0)} SAR)',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                      ),
                      Slider(
                        value: downPaymentPct,
                        min: 10,
                        max: 50,
                        divisions: 8,
                        activeColor: AppTheme.accentColor,
                        label: '${downPaymentPct.toInt()}%',
                        onChanged: (v) => setModalState(() => downPaymentPct = v),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.isArabic
                            ? 'معدل الفائدة: ${interestRate.toStringAsFixed(1)}% سنوياً'
                            : 'Interest Rate: ${interestRate.toStringAsFixed(1)}% per year',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                      ),
                      Slider(
                        value: interestRate,
                        min: 2,
                        max: 10,
                        divisions: 16,
                        activeColor: primary,
                        label: '${interestRate.toStringAsFixed(1)}%',
                        onChanged: (v) => setModalState(() => interestRate = v),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.isArabic
                            ? 'مدة القرض: $loanYears سنة'
                            : 'Loan Term: $loanYears years',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                      ),
                      Slider(
                        value: loanYears.toDouble(),
                        min: 5,
                        max: 30,
                        divisions: 5,
                        activeColor: secondary,
                        label: '$loanYears',
                        onChanged: (v) => setModalState(() => loanYears = v.toInt()),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: subtextColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l.isArabic
                                    ? 'هذه الأرقام تقديرية وقد تختلف حسب البنك وشروط التمويل.'
                                    : 'These are estimates and may vary by bank and terms.',
                                style: GoogleFonts.cairo(fontSize: 12, color: subtextColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _calcStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.cairo(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  void _showAddReviewSheet(AppLocalizations l, Color textColor, Color cardBg) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.addReview,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l.isArabic ? 'التقييم' : 'Rating',
                      style: GoogleFonts.cairo(color: textColor)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () =>
                            setModalState(() => selectedRating = i + 1),
                        icon: Icon(
                          i < selectedRating ? Icons.star : Icons.star_outline,
                          color: AppTheme.goldColor,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l.isArabic ? 'اكتب تعليقك هنا...' : 'Write your comment...',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        final userId = authProvider.currentUser?.id ?? 1;
                        Navigator.pop(context);
                        final result = await ApiService.addReview(
                          userId: userId,
                          rating: selectedRating,
                          comment: commentController.text,
                          propertyId: widget.property.id,
                        );
                        if (result['success'] == true && mounted) {
                          setState(() {
                            if (result['review'] != null) {
                              _reviews.insert(0, result['review'] as Review);
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.isArabic
                                  ? 'تم إضافة التقييم بنجاح'
                                  : 'Review added successfully'),
                              backgroundColor: AppTheme.successColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      child: Text(l.isArabic ? 'إرسال التقييم' : 'Submit Review'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
