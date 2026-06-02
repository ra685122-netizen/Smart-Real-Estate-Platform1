import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class MortgageCalculatorView extends StatefulWidget {
  const MortgageCalculatorView({super.key});

  @override
  State<MortgageCalculatorView> createState() => _MortgageCalculatorViewState();
}

class _MortgageCalculatorViewState extends State<MortgageCalculatorView>
    with SingleTickerProviderStateMixin {
  double _propertyPrice = 1500000;
  double _downPaymentPercent = 20;
  double _interestRate = 4.5;
  int _loanYears = 25;
  bool _showResults = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double get _downPayment => _propertyPrice * _downPaymentPercent / 100;
  double get _loanAmount => _propertyPrice - _downPayment;
  double get _monthlyRate => _interestRate / 100 / 12;
  int get _totalMonths => _loanYears * 12;

  double get _monthlyPayment {
    if (_monthlyRate == 0) return _loanAmount / _totalMonths;
    final factor = pow(1 + _monthlyRate, _totalMonths);
    return _loanAmount * _monthlyRate * factor / (factor - 1);
  }

  double get _totalPayment => _monthlyPayment * _totalMonths;
  double get _totalInterest => _totalPayment - _loanAmount;

  void _calculate() {
    setState(() => _showResults = true);
    _animController.forward(from: 0);
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
            expandedHeight: 140,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isArabic ? 'حاسبة التمويل العقاري' : 'Mortgage Calculator',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30, bottom: 30),
                    child: Icon(Icons.calculate_rounded, size: 80, color: Colors.white.withValues(alpha: 0.15)),
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
                  // Property Price
                  _buildSliderCard(
                    title: isArabic ? 'سعر العقار' : 'Property Price',
                    value: _propertyPrice,
                    min: 100000,
                    max: 10000000,
                    divisions: 990,
                    suffix: isArabic ? ' ريال' : ' SAR',
                    icon: Icons.home_rounded,
                    color: primary,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _propertyPrice = v),
                    formatter: _formatCurrency,
                  ),
                  const SizedBox(height: 16),

                  // Down Payment
                  _buildSliderCard(
                    title: isArabic ? 'الدفعة الأولى' : 'Down Payment',
                    value: _downPaymentPercent,
                    min: 5,
                    max: 50,
                    divisions: 45,
                    suffix: '%',
                    icon: Icons.payments_rounded,
                    color: Colors.green,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _downPaymentPercent = v),
                    formatter: (v) => '${v.toInt()}%  (${_formatCurrency(_downPayment)})',
                  ),
                  const SizedBox(height: 16),

                  // Interest Rate
                  _buildSliderCard(
                    title: isArabic ? 'نسبة الفائدة السنوية' : 'Annual Interest Rate',
                    value: _interestRate,
                    min: 1,
                    max: 12,
                    divisions: 110,
                    suffix: '%',
                    icon: Icons.percent_rounded,
                    color: Colors.orange,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _interestRate = v),
                    formatter: (v) => '${v.toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 16),

                  // Loan Duration
                  _buildSliderCard(
                    title: isArabic ? 'مدة التمويل' : 'Loan Duration',
                    value: _loanYears.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    suffix: isArabic ? ' سنة' : ' years',
                    icon: Icons.calendar_month_rounded,
                    color: Colors.purple,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _loanYears = v.toInt()),
                    formatter: (v) => '${v.toInt()} ${isArabic ? "سنة" : "years"}',
                  ),
                  const SizedBox(height: 24),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calculate, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            isArabic ? 'احسب القسط الشهري' : 'Calculate Monthly Payment',
                            style: GoogleFonts.cairo(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Results
                  if (_showResults) ...[
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildResultsSection(primary, secondary, isArabic, isDark),
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

  Widget _buildSliderCard({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required IconData icon,
    required Color color,
    required bool isDark,
    required ValueChanged<double> onChanged,
    required String Function(double) formatter,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14)),
              const Spacer(),
              Text(
                formatter(value),
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(Color primary, Color secondary, bool isArabic, bool isDark) {
    return Column(
      children: [
        // Main payment card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primary, secondary]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              Text(
                isArabic ? 'القسط الشهري' : 'Monthly Payment',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _formatCurrency(_monthlyPayment),
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
              ),
              Text(
                isArabic ? 'ريال سعودي / شهر' : 'SAR / month',
                style: GoogleFonts.cairo(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Details grid
        Row(
          children: [
            Expanded(
              child: _buildResultCard(
                isArabic ? 'مبلغ التمويل' : 'Loan Amount',
                _formatCurrency(_loanAmount),
                Icons.account_balance,
                Colors.blue,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResultCard(
                isArabic ? 'إجمالي الفوائد' : 'Total Interest',
                _formatCurrency(_totalInterest),
                Icons.trending_up,
                Colors.orange,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildResultCard(
                isArabic ? 'إجمالي المدفوع' : 'Total Payment',
                _formatCurrency(_totalPayment),
                Icons.receipt_long,
                Colors.green,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResultCard(
                isArabic ? 'الدفعة الأولى' : 'Down Payment',
                _formatCurrency(_downPayment),
                Icons.savings,
                Colors.purple,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
