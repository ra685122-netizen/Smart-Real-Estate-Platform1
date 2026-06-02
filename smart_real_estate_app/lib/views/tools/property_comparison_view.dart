import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class PropertyComparisonView extends StatefulWidget {
  const PropertyComparisonView({super.key});

  @override
  State<PropertyComparisonView> createState() => _PropertyComparisonViewState();
}

class _PropertyComparisonViewState extends State<PropertyComparisonView> {
  List<Property> _allProperties = [];
  Property? _property1;
  Property? _property2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      setState(() {
        _allProperties = propertyProvider.allProperties.isNotEmpty
            ? propertyProvider.allProperties
            : propertyProvider.properties;
        if (_allProperties.length >= 2) {
          _property1 = _allProperties[0];
          _property2 = _allProperties[1];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primary = themeProvider.currentScheme.primary;
    final secondary = themeProvider.currentScheme.secondary;
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isArabic ? 'مقارنة العقارات' : 'Compare Properties',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, secondary]),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30, bottom: 20),
                    child: Icon(Icons.compare_arrows_rounded, size: 80, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Property selectors
                  Row(
                    children: [
                      Expanded(child: _buildSelector(1, _property1, primary, isArabic, isDark)),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.compare_arrows, color: primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSelector(2, _property2, secondary, isArabic, isDark)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_property1 != null && _property2 != null) ...[
                    // Images comparison
                    Row(
                      children: [
                        Expanded(child: _buildPropertyImage(_property1!, primary)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPropertyImage(_property2!, secondary)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Comparison table
                    _buildComparisonRow(
                      isArabic ? 'السعر' : 'Price',
                      _property1!.priceFormatted,
                      _property2!.priceFormatted,
                      Icons.attach_money,
                      primary, secondary, isDark,
                    ),
                    _buildComparisonRow(
                      isArabic ? 'المساحة' : 'Area',
                      '${_property1!.area?.toInt() ?? 0} ${l10n.sqm}',
                      '${_property2!.area?.toInt() ?? 0} ${l10n.sqm}',
                      Icons.square_foot,
                      primary, secondary, isDark,
                    ),
                    _buildComparisonRow(
                      isArabic ? 'غرف النوم' : 'Bedrooms',
                      '${_property1!.bedrooms ?? 0}',
                      '${_property2!.bedrooms ?? 0}',
                      Icons.bed,
                      primary, secondary, isDark,
                    ),
                    _buildComparisonRow(
                      isArabic ? 'دورات المياه' : 'Bathrooms',
                      '${_property1!.bathrooms ?? 0}',
                      '${_property2!.bathrooms ?? 0}',
                      Icons.bathtub,
                      primary, secondary, isDark,
                    ),
                    _buildComparisonRow(
                      isArabic ? 'النوع' : 'Type',
                      _property1!.propertyType ?? '-',
                      _property2!.propertyType ?? '-',
                      Icons.category,
                      primary, secondary, isDark,
                    ),
                    _buildComparisonRow(
                      isArabic ? 'الموقع' : 'Location',
                      _property1!.location ?? '-',
                      _property2!.location ?? '-',
                      Icons.location_on,
                      primary, secondary, isDark,
                    ),
                    _buildComparisonRow(
                      isArabic ? 'التقييم' : 'Rating',
                      '4.5 ⭐',
                      '4.2 ⭐',
                      Icons.star,
                      primary, secondary, isDark,
                    ),
                    const SizedBox(height: 20),

                    // AI Recommendation
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primary.withValues(alpha: 0.1), secondary.withValues(alpha: 0.1)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isArabic ? 'توصية الذكاء الاصطناعي' : 'AI Recommendation',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isArabic
                                ? 'بناءً على المقارنة، العقار الأول يقدم قيمة أفضل مقابل المال مع مساحة أكبر وموقع متميز.'
                                : 'Based on the comparison, the first property offers better value for money with more area and a premium location.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[600], height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector(int index, Property? property, Color color, bool isArabic, bool isDark) {
    return GestureDetector(
      onTap: () => _showPropertyPicker(index, color),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.touch_app, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              property?.title ?? (isArabic ? 'اختر عقار' : 'Select'),
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showPropertyPicker(int index, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _allProperties.length,
                itemBuilder: (context, i) {
                  final p = _allProperties[i];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: p.images.isNotEmpty
                          ? Image.network(p.images[0], width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.home)))
                          : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.home)),
                    ),
                    title: Text(p.title, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text(p.priceFormatted, style: GoogleFonts.cairo(color: color, fontSize: 12)),
                    onTap: () {
                      setState(() {
                        if (index == 1) _property1 = p;
                        else _property2 = p;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage(Property p, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: p.images.isNotEmpty
          ? Image.network(
              p.images[0],
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 140,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.home, size: 40, color: color),
              ),
            )
          : Container(
              height: 140,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.home, size: 40, color: color),
            ),
    );
  }

  Widget _buildComparisonRow(String label, String val1, String val2, IconData icon, Color c1, Color c2, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(val1, textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 12, color: c1)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(label, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          Expanded(
            child: Text(val2, textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 12, color: c2)),
          ),
        ],
      ),
    );
  }
}
