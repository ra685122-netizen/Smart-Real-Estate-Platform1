import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class MarketTrendsCard extends StatefulWidget {
  final String city;

  const MarketTrendsCard({super.key, required this.city});

  @override
  State<MarketTrendsCard> createState() => _MarketTrendsCardState();
}

class _MarketTrendsCardState extends State<MarketTrendsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late List<double> _chartPoints;
  late double _avgPrice;
  late double _changePct;
  late int _activeListings;

  @override
  void initState() {
    super.initState();
    _generateData();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  void _generateData() {
    final seed = widget.city.hashCode.abs();
    final rng = Random(seed);
    _avgPrice = 4500 + rng.nextInt(4000).toDouble();
    _changePct = -3.5 + rng.nextDouble() * 12;
    _activeListings = 120 + rng.nextInt(380);
    _chartPoints = List.generate(7, (i) {
      final base = _avgPrice * (0.88 + rng.nextDouble() * 0.24);
      return base;
    });
    _chartPoints[6] = _avgPrice;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final gradient = themeProvider.currentScheme.gradient;
    final isPositive = _changePct >= 0;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(loc, theme, gradient),
            _buildStats(loc, theme, isPositive),
            _buildMiniChart(theme, gradient),
            _buildFooter(loc, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      AppLocalizations loc, ThemeData theme, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient.first.withValues(alpha: 0.12), Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.marketTrends,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  widget.city,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle,
                    size: 7, color: Color(0xFF4CAF50)),
                const SizedBox(width: 5),
                Text(
                  loc.activeMarket,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
      AppLocalizations loc, ThemeData theme, bool isPositive) {
    final changeColor =
        isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatBox(
            label: loc.avgPricePerSqm,
            value:
                '${_avgPrice.toStringAsFixed(0)} ${loc.sarUnit}',
            icon: Icons.price_change_outlined,
            iconColor: theme.colorScheme.primary,
            theme: theme,
          ),
          const SizedBox(width: 12),
          _StatBox(
            label: '${loc.priceChange} (${loc.yearOverYear})',
            value:
                '${isPositive ? '+' : ''}${_changePct.toStringAsFixed(1)}%',
            icon: isPositive
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            iconColor: changeColor,
            valueColor: changeColor,
            theme: theme,
          ),
          const SizedBox(width: 12),
          _StatBox(
            label: loc.activeMarket,
            value: '$_activeListings',
            icon: Icons.home_work_outlined,
            iconColor: theme.colorScheme.tertiary,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart(ThemeData theme, List<Color> gradient) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: SizedBox(
        height: 70,
        child: CustomPaint(
          size: const Size(double.infinity, 70),
          painter: _MiniChartPainter(
            points: _chartPoints,
            lineColor: gradient.first,
            fillColor: gradient.first.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations loc, ThemeData theme) {
    final days = loc.isArabic
        ? ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب']
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days
            .map((d) => Text(
                  d,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;
  final ThemeData theme;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;

  _MiniChartPainter(
      {required this.points,
      required this.lineColor,
      required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final minVal = points.reduce(min);
    final maxVal = points.reduce(max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    List<Offset> pts = [];
    for (int i = 0; i < points.length; i++) {
      final x = i * size.width / (points.length - 1);
      final y = size.height - ((points[i] - minVal) / range) * size.height;
      pts.add(Offset(x, y));
    }

    final fillPath = Path();
    fillPath.moveTo(pts.first.dx, size.height);
    for (int i = 0; i < pts.length; i++) {
      if (i == 0) {
        fillPath.lineTo(pts[i].dx, pts[i].dy);
      } else {
        final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
        final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
        fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
      }
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    final linePath = Path();
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    canvas.drawCircle(
      pts.last,
      5,
      Paint()..color = lineColor,
    );
    canvas.drawCircle(
      pts.last,
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_MiniChartPainter old) =>
      old.points != points || old.lineColor != lineColor;
}
