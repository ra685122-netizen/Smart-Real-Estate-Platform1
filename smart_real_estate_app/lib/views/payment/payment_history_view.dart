import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/payment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/riyal_icon.dart';
import 'payment_success_view.dart';

class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> with SingleTickerProviderStateMixin {
  List<Payment> _payments = [];
  bool _isLoading = true;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadPayments();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      final data = await ApiService.getPayments(userId);
      if (mounted) setState(() { _payments = data; _isLoading = false; });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Payment> _byStatus(PaymentStatus? s) => s == null
      ? _payments
      : _payments.where((p) => p.status == s).toList();

  double get _totalSpent => _payments
      .where((p) => p.status == PaymentStatus.completed)
      .fold(0.0, (sum, p) => sum + p.amount);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = themeProvider.currentScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, themeProvider, primary),
            _buildSummaryCards(l10n, primary, theme, isDark),
            _buildTabs(l10n, primary),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildList(_byStatus(null), l10n, primary, isDark, theme),
                      _buildList(_byStatus(PaymentStatus.completed), l10n, primary, isDark, theme),
                      _buildList(_byStatus(PaymentStatus.pending), l10n, primary, isDark, theme),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeProvider tp, Color primary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tp.currentScheme.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(l10n.paymentHistory, style: GoogleFonts.cairo(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadPayments),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AppLocalizations l10n, Color primary, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, primary.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 22),
                  const SizedBox(height: 8),
                  Text(l10n.isArabic ? 'إجمالي المدفوع' : 'Total Paid', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
                  Row(
                    children: [
                      const RiyalIcon(size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Flexible(child: Text(_formatAmount(_totalSpent), style: GoogleFonts.cairo(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _miniCard(l10n.isArabic ? 'المعاملات' : 'Total', _payments.length.toString(), Icons.receipt_long_outlined, Colors.blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniCard(l10n.isArabic ? 'معلق' : 'Pending', _byStatus(PaymentStatus.pending).length.toString(), Icons.pending_outlined, Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.cairo(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTabs(AppLocalizations l10n, Color primary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
        tabs: [
          Tab(text: l10n.isArabic ? 'الكل' : 'All'),
          Tab(text: l10n.isArabic ? 'مكتمل' : 'Done'),
          Tab(text: l10n.isArabic ? 'معلق' : 'Pending'),
        ],
      ),
    );
  }

  Widget _buildList(List<Payment> payments, AppLocalizations l10n, Color primary, bool isDark, ThemeData theme) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 70, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(l10n.noPayments, style: GoogleFonts.cairo(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: payments.length,
        itemBuilder: (_, i) => _buildCard(payments[i], l10n, primary, isDark, theme),
      ),
    );
  }

  Widget _buildCard(Payment p, AppLocalizations l10n, Color primary, bool isDark, ThemeData theme) {
    final statusColor = _statusColor(p.status);
    final statusLabel = l10n.isArabic ? p.statusLabelAr : _statusLabelEn(p.status);
    final methodLabel = l10n.isArabic ? p.methodLabelAr : _methodLabelEn(p.method);
    final dateStr = '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}  ${p.createdAt.hour}:${p.createdAt.minute.toString().padLeft(2, "0")}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 5))],
        border: Border.all(color: statusColor.withValues(alpha: 0.18), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_methodIcon(p.method), color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.propertyTitle, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(methodLabel, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusLabel, style: GoogleFonts.cairo(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.isArabic ? 'رقم المعاملة' : 'Transaction ID', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                        Text(p.transactionId, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l10n.isArabic ? 'المبلغ' : 'Amount', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                        Row(
                          children: [
                            RiyalIcon(size: 14, color: primary),
                            const SizedBox(width: 4),
                            Text(_formatAmount(p.amount), style: GoogleFonts.cairo(color: primary, fontWeight: FontWeight.w800, fontSize: 17)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(dateStr, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewReceipt(p),
                        icon: Icon(Icons.receipt_long_outlined, size: 15, color: primary),
                        label: Text(l10n.isArabic ? 'الإيصال' : 'Receipt', style: GoogleFonts.cairo(fontSize: 12, color: primary, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDetails(p, l10n, primary),
                        icon: const Icon(Icons.visibility_outlined, size: 15, color: Colors.white),
                        label: Text(l10n.isArabic ? 'التفاصيل' : 'View', style: GoogleFonts.cairo(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size.zero,
                          elevation: 0,
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
    );
  }

  void _viewReceipt(Payment p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessView(amount: p.amount, transactionId: p.transactionId),
      ),
    );
  }

  void _showDetails(Payment p, AppLocalizations l10n, Color primary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.45,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.receipt_long_rounded, color: primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.isArabic ? 'تفاصيل الدفعة' : 'Payment Details', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(p.transactionId, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailRow(l10n.isArabic ? 'العقار' : 'Property', p.propertyTitle, Icons.home_outlined),
              _detailRow(l10n.isArabic ? 'المبلغ المدفوع' : 'Amount Paid', '${_formatAmount(p.amount)} ${l10n.isArabic ? "ريال" : "SAR"}', Icons.payments_outlined, valueColor: primary),
              _detailRow(l10n.isArabic ? 'الحالة' : 'Status', l10n.isArabic ? p.statusLabelAr : _statusLabelEn(p.status), Icons.info_outline, valueColor: _statusColor(p.status)),
              _detailRow(l10n.isArabic ? 'طريقة الدفع' : 'Method', l10n.isArabic ? p.methodLabelAr : _methodLabelEn(p.method), Icons.credit_card_outlined),
              _detailRow(l10n.isArabic ? 'التاريخ' : 'Date', '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}', Icons.calendar_today_outlined),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () { Navigator.pop(context); _viewReceipt(p); },
                  icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
                  label: Text(l10n.isArabic ? 'عرض الإيصال الكامل' : 'View Full Receipt', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () { Clipboard.setData(ClipboardData(text: p.transactionId)); HapticFeedback.selectionClick(); Navigator.pop(context); },
                  icon: Icon(Icons.copy_rounded, color: primary),
                  label: Text(l10n.isArabic ? 'نسخ رقم المعاملة' : 'Copy Transaction ID', style: GoogleFonts.cairo(color: primary, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Flexible(child: Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Color _statusColor(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.completed: return Colors.green;
      case PaymentStatus.pending:   return Colors.orange;
      case PaymentStatus.failed:    return Colors.red;
      case PaymentStatus.refunded:  return Colors.purple;
    }
  }

  String _statusLabelEn(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.completed: return 'Completed';
      case PaymentStatus.pending:   return 'Pending';
      case PaymentStatus.failed:    return 'Failed';
      case PaymentStatus.refunded:  return 'Refunded';
    }
  }

  String _methodLabelEn(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.creditCard:   return 'Credit Card';
      case PaymentMethod.bankTransfer: return 'Bank Transfer';
      case PaymentMethod.stcPay:       return 'STC Pay';
      case PaymentMethod.applePay:     return 'Apple Pay';
      case PaymentMethod.googlePay:    return 'Google Pay';
      case PaymentMethod.qrCode:       return 'QR Code';
    }
  }

  IconData _methodIcon(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.creditCard:   return Icons.credit_card;
      case PaymentMethod.bankTransfer: return Icons.account_balance;
      case PaymentMethod.stcPay:       return Icons.phone_android;
      case PaymentMethod.applePay:     return Icons.apple;
      case PaymentMethod.googlePay:    return Icons.g_mobiledata;
      case PaymentMethod.qrCode:       return Icons.qr_code;
    }
  }

  String _formatAmount(double a) {
    if (a >= 1000000) return '${(a / 1000000).toStringAsFixed(1)}M';
    if (a >= 1000) return '${(a / 1000).toStringAsFixed(0)}K';
    return a.toStringAsFixed(0);
  }
}
