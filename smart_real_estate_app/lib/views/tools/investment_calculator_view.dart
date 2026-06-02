import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class InvestmentCalculatorView extends StatefulWidget {
  final double? propertyPrice;

  const InvestmentCalculatorView({super.key, this.propertyPrice});

  @override
  State<InvestmentCalculatorView> createState() =>
      _InvestmentCalculatorViewState();
}

class _InvestmentCalculatorViewState extends State<InvestmentCalculatorView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _rentCtrl;

  double _maintenancePct = 2.0;
  double _managementPct = 5.0;
  double _vacancyPct   = 10.0;

  bool _showResults = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
      text: widget.propertyPrice?.toStringAsFixed(0) ?? '1500000',
    );
    _rentCtrl = TextEditingController(text: '90000');

    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _rentCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  double get _price  => double.tryParse(_priceCtrl.text) ?? 0;
  double get _rent   => double.tryParse(_rentCtrl.text)  ?? 0;
  double get _maint  => _price * _maintenancePct / 100;
  double get _mgmt   => _rent  * _managementPct  / 100;
  double get _vac    => _rent  * _vacancyPct      / 100;
  double get _net    => _rent - _maint - _mgmt - _vac;
  double get _gross  => _price > 0 ? (_rent  / _price) * 100 : 0;
  double get _netY   => _price > 0 ? (_net   / _price) * 100 : 0;
  double get _payback=> _net   > 0 ? _price  / _net : 0;

  void _calculate() {
    FocusScope.of(context).unfocus();
    setState(() => _showResults = true);
    _animCtrl.forward(from: 0);
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final loc   = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tp    = context.watch<ThemeProvider>();
    final grad  = tp.currentScheme.gradient;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
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
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.investmentCalculator,
                          style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                        Text(
                          loc.investmentSubtitle,
                          style: GoogleFonts.cairo(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13),
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
                children: [
                  _buildInputCard(loc, theme),
                  const SizedBox(height: 20),
                  _buildSlidersCard(loc, theme),
                  const SizedBox(height: 24),
                  _buildCalcButton(loc, theme),
                  if (_showResults) ...[
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: AnimatedBuilder(
                        animation: _slideAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: child,
                        ),
                        child: _buildResults(loc, theme),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(AppLocalizations loc, ThemeData theme) {
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(loc.investmentData, theme),
          const SizedBox(height: 16),
          _field(
            ctrl: _priceCtrl,
            label: loc.price,
            suffix: loc.sarUnit,
            icon: Icons.home_work_outlined,
            theme: theme,
          ),
          const SizedBox(height: 14),
          _field(
            ctrl: _rentCtrl,
            label: loc.annualRent,
            suffix: loc.sarPerYear,
            icon: Icons.payments_outlined,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSlidersCard(AppLocalizations loc, ThemeData theme) {
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(loc.costsAndExpenses, theme),
          const SizedBox(height: 16),
          _slider(
            label: loc.maintenanceCost,
            value: _maintenancePct,
            max: 10,
            onChanged: (v) => setState(() => _maintenancePct = v),
            theme: theme,
          ),
          _slider(
            label: loc.managementFee,
            value: _managementPct,
            max: 15,
            onChanged: (v) => setState(() => _managementPct = v),
            theme: theme,
          ),
          _slider(
            label: loc.vacancyRate,
            value: _vacancyPct,
            max: 30,
            onChanged: (v) => setState(() => _vacancyPct = v),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildCalcButton(AppLocalizations loc, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _calculate,
        icon: const Icon(Icons.analytics_outlined, color: Colors.white),
        label: Text(
          loc.calculateRoi,
          style: GoogleFonts.cairo(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildResults(AppLocalizations loc, ThemeData theme) {
    final isGood = _netY >= 7;
    final isFair = _netY >= 4;
    final verdictColor =
        isGood ? Colors.green : (isFair ? Colors.orange : Colors.red);
    final verdict = isGood
        ? '✅ ${loc.goodInvestment}'
        : (isFair ? '⚠️ ${loc.fairInvestment}' : '❌ ${loc.poorInvestment}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.roiResults,
          style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: verdictColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: verdictColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(verdict,
                    style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: verdictColor)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: verdictColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${_netY.toStringAsFixed(2)}%',
                  style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          theme,
          child: Column(
            children: [
              _resultRow(
                  label: loc.grossRentalYield,
                  value: '${_gross.toStringAsFixed(2)}%',
                  icon: Icons.percent,
                  color: Colors.blue,
                  theme: theme),
              _divider(theme),
              _resultRow(
                  label: loc.netRentalYield,
                  value: '${_netY.toStringAsFixed(2)}%',
                  icon: Icons.trending_up,
                  color: verdictColor,
                  theme: theme),
              _divider(theme),
              _resultRow(
                  label: loc.annualNetIncome,
                  value: '${_fmt(_net)} ${loc.sarUnit}',
                  icon: Icons.monetization_on_outlined,
                  color: Colors.green,
                  theme: theme),
              _divider(theme),
              _resultRow(
                  label: loc.paybackPeriod,
                  value: '${_payback.toStringAsFixed(1)} ${loc.years}',
                  icon: Icons.hourglass_bottom,
                  color: Colors.purple,
                  theme: theme),
              _divider(theme),
              _resultRow(
                  label: loc.maintenanceCostLabel,
                  value: '${_fmt(_maint)} ${loc.sarUnit}',
                  icon: Icons.build_outlined,
                  color: Colors.orange,
                  theme: theme),
              _divider(theme),
              _resultRow(
                  label: loc.mgmtAndVacancy,
                  value: '${_fmt(_mgmt + _vac)} ${loc.sarUnit}',
                  icon: Icons.remove_circle_outline,
                  color: Colors.redAccent,
                  theme: theme),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInvestmentTip(loc, theme, isGood, isFair),
      ],
    );
  }

  Widget _buildInvestmentTip(
      AppLocalizations loc, ThemeData theme, bool isGood, bool isFair) {
    final tips = loc.isArabic
        ? (isGood
            ? 'عائد ممتاز! هذا العقار يوفر دخلاً إيجارياً جيداً مع استرداد رأس المال في فترة معقولة.'
            : isFair
                ? 'عائد مقبول. قد تحتاج إلى مراجعة شروط الإيجار أو خفض تكاليف الصيانة لتحسين الربحية.'
                : 'العائد منخفض نسبياً. تأكد من أن السعر منافس وأن الإيجار مناسب للسوق.')
        : (isGood
            ? 'Excellent yield! This property provides solid rental income with a reasonable payback period.'
            : isFair
                ? 'Acceptable return. Consider reviewing lease terms or reducing maintenance costs.'
                : 'Low yield. Ensure the price is competitive and the rent matches market rates.');

    final color =
        isGood ? Colors.green : (isFair ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_outlined, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tips,
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(ThemeData theme, {required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)
          ],
        ),
        child: child,
      );

  Widget _sectionLabel(String text, ThemeData theme) => Text(text,
      style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface));

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String suffix,
    required IconData icon,
    required ThemeData theme,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(fontSize: 14),
          suffixText: suffix,
          prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
      );

  Widget _slider({
    required String label,
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
    required ThemeData theme,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${value.toStringAsFixed(1)}%',
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              thumbColor: theme.colorScheme.primary,
              inactiveTrackColor:
                  theme.colorScheme.primary.withValues(alpha: 0.15),
              trackHeight: 4,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              divisions: (max * 2).toInt(),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 2),
        ],
      );

  Widget _resultRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.65))),
            ),
            Text(value,
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface)),
          ],
        ),
      );

  Widget _divider(ThemeData theme) =>
      Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1));
}
