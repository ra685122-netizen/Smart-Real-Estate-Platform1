import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/payment_model.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/riyal_icon.dart';

class AdminPaymentsView extends StatefulWidget {
  const AdminPaymentsView({Key? key}) : super(key: key);

  @override
  State<AdminPaymentsView> createState() => _AdminPaymentsViewState();
}

class _AdminPaymentsViewState extends State<AdminPaymentsView> {
  List<Payment> _payments = [];
  List<Payment> _filtered = [];
  bool _isLoading = true;
  String _sortBy = 'newest';
  PaymentStatus? _statusFilter;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getAllPayments();
    if (mounted) {
      setState(() {
        _payments = data;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Payment> list = List.from(_payments);
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) =>
        p.propertyTitle.toLowerCase().contains(q) ||
        p.transactionId.toLowerCase().contains(q)
      ).toList();
    }
    if (_statusFilter != null) {
      list = list.where((p) => p.status == _statusFilter).toList();
    }
    switch (_sortBy) {
      case 'newest':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'lowest':
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    _filtered = list;
  }

  double get _totalRevenue => _payments
      .where((p) => p.status == PaymentStatus.completed)
      .fold(0, (sum, p) => sum + p.amount);

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
            _buildStats(l10n, primary),
            _buildFilters(l10n, primary, theme, isDark),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                  ? _buildEmpty(l10n, theme)
                  : RefreshIndicator(
                      onRefresh: _loadPayments,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) => _buildPaymentCard(_filtered[i], l10n, primary, isDark, theme),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeProvider tp, Color primary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tp.currentScheme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  l10n.isArabic ? 'إدارة المدفوعات' : 'Manage Payments',
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadPayments,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(_applyFilters),
            style: GoogleFonts.cairo(color: Colors.white),
            decoration: InputDecoration(
              hintText: l10n.isArabic ? 'بحث بالعقار أو رقم المعاملة...' : 'Search by property or TXN...',
              hintStyle: GoogleFonts.cairo(color: Colors.white60),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              fillColor: Colors.white.withValues(alpha: 0.15),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AppLocalizations l10n, Color primary) {
    final completed = _payments.where((p) => p.status == PaymentStatus.completed).length;
    final pending = _payments.where((p) => p.status == PaymentStatus.pending).length;
    final refunded = _payments.where((p) => p.status == PaymentStatus.refunded).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          _statChip(l10n.isArabic ? 'الإجمالي' : 'Total', _totalRevenue, primary, Icons.account_balance_wallet_outlined),
          const SizedBox(width: 10),
          _miniStat(l10n.isArabic ? 'مكتمل' : 'Done', completed.toString(), Colors.green),
          const SizedBox(width: 10),
          _miniStat(l10n.isArabic ? 'معلق' : 'Pending', pending.toString(), Colors.orange),
          const SizedBox(width: 10),
          _miniStat(l10n.isArabic ? 'مُسترد' : 'Refunded', refunded.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _statChip(String label, double amount, Color color, IconData icon) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Row(
              children: [
                const RiyalIcon(size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _formatAmount(amount),
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(label, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.cairo(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: GoogleFonts.cairo(color: color, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n, Color primary, ThemeData theme, bool isDark) {
    final sorts = [
      ('newest', l10n.isArabic ? 'الأحدث' : 'Newest'),
      ('oldest', l10n.isArabic ? 'الأقدم' : 'Oldest'),
      ('highest', l10n.isArabic ? 'الأعلى' : 'Highest'),
      ('lowest', l10n.isArabic ? 'الأدنى' : 'Lowest'),
    ];
    final statuses = [
      (null, l10n.isArabic ? 'الكل' : 'All'),
      (PaymentStatus.completed, l10n.isArabic ? 'مكتمل' : 'Completed'),
      (PaymentStatus.pending, l10n.isArabic ? 'معلق' : 'Pending'),
      (PaymentStatus.refunded, l10n.isArabic ? 'مُسترد' : 'Refunded'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: statuses.map((s) {
                final selected = _statusFilter == s.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s.$2, style: GoogleFonts.cairo(fontSize: 12, color: selected ? Colors.white : theme.colorScheme.onSurface)),
                    selected: selected,
                    selectedColor: primary,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: selected ? primary : Colors.grey.shade400),
                    showCheckmark: false,
                    onSelected: (_) => setState(() { _statusFilter = s.$1; _applyFilters(); }),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: sorts.map((s) {
                final selected = _sortBy == s.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() { _sortBy = s.$1; _applyFilters(); }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? primary.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? primary : Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort, size: 14, color: selected ? primary : Colors.grey),
                          const SizedBox(width: 4),
                          Text(s.$2, style: GoogleFonts.cairo(fontSize: 11, color: selected ? primary : Colors.grey, fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment p, AppLocalizations l10n, Color primary, bool isDark, ThemeData theme) {
    final statusColor = _statusColor(p.status);
    final statusLabel = l10n.isArabic ? p.statusLabelAr : _statusLabelEn(p.status);
    final methodLabel = l10n.isArabic ? p.methodLabelAr : _methodLabelEn(p.method);
    final dateStr = '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
        border: Border.all(color: statusColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
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
                    color: statusColor.withValues(alpha: 0.12),
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
                        GestureDetector(
                          onTap: () { Clipboard.setData(ClipboardData(text: p.transactionId)); HapticFeedback.selectionClick(); },
                          child: Row(
                            children: [
                              Text(p.transactionId, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 12)),
                              const SizedBox(width: 4),
                              Icon(Icons.copy_rounded, size: 12, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
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
                            Text(_formatAmount(p.amount), style: GoogleFonts.cairo(color: primary, fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(dateStr, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _showReceiptDialog(p, l10n, primary),
                      icon: Icon(Icons.receipt_long_outlined, size: 15, color: primary),
                      label: Text(l10n.isArabic ? 'الإيصال' : 'Receipt', style: GoogleFonts.cairo(fontSize: 12, color: primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showDetailsDialog(p, l10n, primary),
                      icon: const Icon(Icons.visibility_outlined, size: 15, color: Colors.white),
                      label: Text(l10n.isArabic ? 'تفاصيل' : 'Details', style: GoogleFonts.cairo(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size.zero,
                        elevation: 0,
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

  void _showDetailsDialog(Payment p, AppLocalizations l10n, Color primary) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
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
              _detailRow(l10n.isArabic ? 'المبلغ' : 'Amount', '${_formatAmount(p.amount)} ${l10n.isArabic ? "ريال" : "SAR"}', Icons.payments_outlined, valueColor: primary),
              _detailRow(l10n.isArabic ? 'الحالة' : 'Status', l10n.isArabic ? p.statusLabelAr : _statusLabelEn(p.status), Icons.info_outline, valueColor: _statusColor(p.status)),
              _detailRow(l10n.isArabic ? 'طريقة الدفع' : 'Method', l10n.isArabic ? p.methodLabelAr : _methodLabelEn(p.method), Icons.credit_card_outlined),
              _detailRow(l10n.isArabic ? 'التاريخ' : 'Date', '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year} ${p.createdAt.hour}:${p.createdAt.minute.toString().padLeft(2, "0")}', Icons.calendar_today_outlined),
              _detailRow(l10n.isArabic ? 'المستخدم' : 'User ID', '#${p.userId}', Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiptDialog(Payment p, AppLocalizations l10n, Color primary) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.isArabic ? 'إيصال الدفع' : 'Payment Receipt', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _detailRow(l10n.isArabic ? 'رقم المعاملة' : 'Transaction', p.transactionId, Icons.tag),
                  _detailRow(l10n.isArabic ? 'المبلغ' : 'Amount', '${_formatAmount(p.amount)} SAR', Icons.payments_outlined, valueColor: primary),
                  _detailRow(l10n.isArabic ? 'التاريخ' : 'Date', '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}', Icons.calendar_today_outlined),
                  _detailRow(l10n.isArabic ? 'الحالة' : 'Status', l10n.isArabic ? p.statusLabelAr : _statusLabelEn(p.status), Icons.check_circle_outline, valueColor: _statusColor(p.status)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Clipboard.setData(ClipboardData(text: p.transactionId)); HapticFeedback.selectionClick(); Navigator.pop(context); },
            child: Text(l10n.isArabic ? 'نسخ رقم المعاملة' : 'Copy TXN ID', style: GoogleFonts.cairo(color: primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l10n.isArabic ? 'إغلاق' : 'Close', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(l10n.noPayments, style: GoogleFonts.cairo(fontSize: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
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
