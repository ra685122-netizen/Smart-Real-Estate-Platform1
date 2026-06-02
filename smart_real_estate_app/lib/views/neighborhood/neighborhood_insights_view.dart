import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/property_model.dart';

class NeighborhoodInsightsView extends StatefulWidget {
  final Property property;

  const NeighborhoodInsightsView({super.key, required this.property});

  @override
  State<NeighborhoodInsightsView> createState() =>
      _NeighborhoodInsightsViewState();
}

class _NeighborhoodInsightsViewState extends State<NeighborhoodInsightsView>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late List<Animation<double>> _scoreAnimations;
  late Map<String, double> _scores;
  late List<Map<String, dynamic>> _nearbyPlaces;

  @override
  void initState() {
    super.initState();
    _generateInsights();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scoreAnimations = List.generate(
      6,
      (i) => CurvedAnimation(
        parent: _mainController,
        curve: Interval(
          i * 0.08,
          0.65 + i * 0.06,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    _mainController.forward();
  }

  void _generateInsights() {
    final seed = (widget.property.location ?? '').hashCode;
    final rng = Random(seed.abs());
    _scores = {
      'safety':     60 + rng.nextInt(38).toDouble(),
      'schools':    55 + rng.nextInt(42).toDouble(),
      'transport':  50 + rng.nextInt(46).toDouble(),
      'healthcare': 58 + rng.nextInt(40).toDouble(),
      'shopping':   54 + rng.nextInt(44).toDouble(),
      'mosque':     72 + rng.nextInt(26).toDouble(),
    };
    _nearbyPlaces = [
      {
        'icon': Icons.mosque,
        'name_ar': 'مسجد الرحمن',
        'name_en': 'Al-Rahman Mosque',
        'dist_ar': '${(rng.nextInt(6) + 1) * 100} م',
        'dist_en': '${(rng.nextInt(6) + 1) * 100} m',
        'color': const Color(0xFF009688),
      },
      {
        'icon': Icons.school,
        'name_ar': 'مدرسة النموذجية',
        'name_en': 'Model School',
        'dist_ar': '${(rng.nextInt(8) + 2) * 100} م',
        'dist_en': '${(rng.nextInt(8) + 2) * 100} m',
        'color': const Color(0xFF1976D2),
      },
      {
        'icon': Icons.local_hospital,
        'name_ar': 'مستشفى الملك فيصل',
        'name_en': 'King Faisal Hospital',
        'dist_ar': '${rng.nextInt(3) + 1}.${rng.nextInt(9)} كم',
        'dist_en': '${rng.nextInt(3) + 1}.${rng.nextInt(9)} km',
        'color': const Color(0xFFD32F2F),
      },
      {
        'icon': Icons.local_mall,
        'name_ar': 'مول سيتي ووك',
        'name_en': 'City Walk Mall',
        'dist_ar': '${rng.nextInt(4) + 1}.${rng.nextInt(9)} كم',
        'dist_en': '${rng.nextInt(4) + 1}.${rng.nextInt(9)} km',
        'color': const Color(0xFFE64A19),
      },
      {
        'icon': Icons.directions_bus,
        'name_ar': 'محطة حافلة',
        'name_en': 'Bus Station',
        'dist_ar': '${(rng.nextInt(5) + 1) * 100} م',
        'dist_en': '${(rng.nextInt(5) + 1) * 100} m',
        'color': const Color(0xFF7B1FA2),
      },
      {
        'icon': Icons.restaurant,
        'name_ar': 'مطاعم متنوعة',
        'name_en': 'Various Restaurants',
        'dist_ar': '${(rng.nextInt(3) + 1) * 100} م',
        'dist_en': '${(rng.nextInt(3) + 1) * 100} m',
        'color': const Color(0xFFF57C00),
      },
      {
        'icon': Icons.park,
        'name_ar': 'حديقة الحي',
        'name_en': 'Neighborhood Park',
        'dist_ar': '${rng.nextInt(2) + 1}.${rng.nextInt(9)} كم',
        'dist_en': '${rng.nextInt(2) + 1}.${rng.nextInt(9)} km',
        'color': const Color(0xFF388E3C),
      },
      {
        'icon': Icons.local_pharmacy,
        'name_ar': 'صيدلية النهدي',
        'name_en': 'Nahdi Pharmacy',
        'dist_ar': '${(rng.nextInt(4) + 1) * 100} م',
        'dist_en': '${(rng.nextInt(4) + 1) * 100} m',
        'color': const Color(0xFF0097A7),
      },
    ];
  }

  double get _overallScore =>
      _scores.values.fold(0.0, (a, b) => a + b) / _scores.length;

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tp = context.watch<ThemeProvider>();
    final grad = tp.currentScheme.gradient;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: grad,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.neighborhoodInsights,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.property.location ?? '',
                          style: GoogleFonts.cairo(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedBuilder(
                          animation: _mainController,
                          builder: (_, __) => Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(_overallScore * _mainController.value).toInt()}',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '/100',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getScoreLabel(loc, _overallScore),
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
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
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverallCard(loc, theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    loc.isArabic ? 'مؤشرات الجودة' : 'Quality Indicators',
                    theme,
                  ),
                  const SizedBox(height: 14),
                  _buildScoresGrid(loc, theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle(loc.nearbyPlaces, theme),
                  const SizedBox(height: 14),
                  _buildNearbyList(loc, theme),
                  const SizedBox(height: 24),
                  _buildInsightTips(loc, theme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildOverallCard(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _mainController,
            builder: (_, __) => SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: _ScoreRingPainter(
                  progress: _overallScore / 100 * _mainController.value,
                  color: _getScoreColor(_overallScore),
                ),
                child: Center(
                  child: Text(
                    '${(_overallScore * _mainController.value).toInt()}',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _getScoreColor(_overallScore),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.livabilityScore,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreLabel(loc, _overallScore),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getScoreColor(_overallScore),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.property.location ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresGrid(AppLocalizations loc, ThemeData theme) {
    final items = [
      {'key': 'safety',    'label': loc.safetyScore,    'icon': Icons.security},
      {'key': 'schools',   'label': loc.schoolsScore,   'icon': Icons.school},
      {'key': 'transport', 'label': loc.transportScore, 'icon': Icons.directions_bus},
      {'key': 'healthcare','label': loc.healthcareScore,'icon': Icons.local_hospital},
      {'key': 'shopping',  'label': loc.shoppingScore,  'icon': Icons.shopping_bag},
      {'key': 'mosque',    'label': loc.mosqueScore,    'icon': Icons.mosque},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        final score = _scores[it['key']]!;
        return AnimatedBuilder(
          animation: _scoreAnimations[i],
          builder: (_, __) => _ScoreCard(
            label: it['label'] as String,
            icon: it['icon'] as IconData,
            score: score,
            progress: _scoreAnimations[i].value,
            theme: theme,
          ),
        );
      },
    );
  }

  Widget _buildNearbyList(AppLocalizations loc, ThemeData theme) {
    return Column(
      children: _nearbyPlaces.map((p) {
        final color = p['color'] as Color;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(p['icon'] as IconData, size: 18, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    loc.isArabic
                        ? p['name_ar'] as String
                        : p['name_en'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    loc.isArabic
                        ? p['dist_ar'] as String
                        : p['dist_en'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsightTips(AppLocalizations loc, ThemeData theme) {
    final tips = loc.isArabic
        ? [
            'الحي يوفر وصولاً ممتازاً للمرافق الأساسية',
            'مناسب للعائلات بوجود المدارس والمستشفيات القريبة',
            'شبكة مواصلات متكاملة تخدم المنطقة بكفاءة عالية',
          ]
        : [
            'Excellent access to essential services in this neighborhood',
            'Family-friendly with nearby schools and medical facilities',
            'Well-connected transportation network serves the area',
          ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.07),
            theme.colorScheme.secondary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                loc.areaAnalysis,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double s) {
    if (s >= 80) return Colors.green;
    if (s >= 65) return Colors.lightGreen.shade700;
    if (s >= 50) return Colors.orange;
    if (s >= 35) return Colors.deepOrange;
    return Colors.red;
  }

  String _getScoreLabel(AppLocalizations loc, double s) {
    if (s >= 80) return loc.excellent;
    if (s >= 65) return loc.veryGood;
    if (s >= 50) return loc.good;
    if (s >= 35) return loc.averageScore;
    return loc.belowAverage;
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final double score;
  final double progress;
  final ThemeData theme;

  const _ScoreCard({
    required this.label,
    required this.icon,
    required this.score,
    required this.progress,
    required this.theme,
  });

  Color get _color {
    if (score >= 80) return Colors.green;
    if (score >= 65) return Colors.lightGreen.shade700;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: _color),
              ),
              const Spacer(),
              Text(
                '${(score * progress).toInt()}',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _color,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 100 * progress,
                  backgroundColor: _color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(_color),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ScoreRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 9.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - strokeWidth / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter o) => o.progress != progress;
}
