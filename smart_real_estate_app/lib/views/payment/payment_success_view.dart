import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class PaymentSuccessView extends StatefulWidget {
  final double amount;
  final String transactionId;

  const PaymentSuccessView({
    Key? key,
    required this.amount,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late AnimationController _receiptCtrl;
  late Animation<double> _checkScale;
  late Animation<double> _receiptSlide;
  late Animation<double> _receiptFade;
  late String _qrData;
  late String _verificationCode;
  late DateTime _paidAt;

  @override
  void initState() {
    super.initState();
    _paidAt = DateTime.now();
    _verificationCode =
        widget.transactionId.hashCode.abs().toRadixString(16).toUpperCase();

    _qrData = jsonEncode({
      'platform': 'Aqari عقاري',
      'txId': widget.transactionId,
      'amount': widget.amount,
      'currency': 'SAR',
      'paidAt':
          '${_paidAt.year}-${_paidAt.month.toString().padLeft(2, '0')}-${_paidAt.day.toString().padLeft(2, '0')} '
          '${_paidAt.hour.toString().padLeft(2, '0')}:${_paidAt.minute.toString().padLeft(2, '0')}',
      'verifyCode': _verificationCode,
      'verifyUrl': 'https://aqari.sa/verify?txn=${widget.transactionId}',
      'status': 'VERIFIED',
    });

    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _receiptCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _checkScale =
        CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _receiptSlide = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _receiptCtrl, curve: Curves.easeOutCubic));
    _receiptFade =
        CurvedAnimation(parent: _receiptCtrl, curve: Curves.easeOutCubic);

    _checkCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200),
          () => _receiptCtrl.forward());
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _receiptCtrl.dispose();
    super.dispose();
  }

  String get _formattedDate =>
      '${_paidAt.day}/${_paidAt.month}/${_paidAt.year}  '
      '${_paidAt.hour.toString().padLeft(2, '0')}:${_paidAt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context);
    final gradient = themeProvider.currentScheme.gradient;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient.first.withValues(alpha: 0.06),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildSuccessIcon(gradient),
                const SizedBox(height: 24),
                _buildTitle(l10n),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _receiptCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _receiptFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _receiptSlide.value),
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptCard(l10n, themeProvider, gradient),
                      const SizedBox(height: 20),
                      _buildQrSection(l10n, themeProvider, gradient),
                      const SizedBox(height: 32),
                      _buildActions(l10n, themeProvider, gradient),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon(List<Color> gradient) {
    return ScaleTransition(
      scale: _checkScale,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.4),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          l10n.isArabic ? 'تمت عملية الدفع بنجاح!' : 'Payment Successful!',
          style: GoogleFonts.cairo(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.isArabic
              ? 'تمت معالجة معاملتك بنجاح.'
              : 'Your transaction has been processed successfully.',
          style: GoogleFonts.cairo(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReceiptCard(AppLocalizations l10n, ThemeProvider themeProvider,
      List<Color> gradient) {
    final theme = Theme.of(context);
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [gradient.first.withValues(alpha: 0.1), Colors.transparent]),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    color: gradient.first, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.paymentReceipt,
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.paymentVerified,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              children: [
                _receiptRow(l10n.transactionId, widget.transactionId,
                    icon: Icons.tag, copyable: true),
                _divider(),
                _receiptRow(
                  l10n.amountPaid,
                  '${widget.amount.toStringAsFixed(0)} ${l10n.sarUnit}',
                  icon: Icons.payments_outlined,
                  highlight: true,
                  highlightColor: gradient.first,
                ),
                _divider(),
                _receiptRow(l10n.paymentDate, _formattedDate,
                    icon: Icons.calendar_today_outlined),
                _divider(),
                _receiptRow(
                    l10n.paymentMethod,
                    l10n.isArabic ? 'بطاقة ائتمانية' : 'Credit Card',
                    icon: Icons.credit_card_outlined),
                _divider(),
                _receiptRow(l10n.verificationCode, _verificationCode,
                    icon: Icons.verified_outlined, copyable: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value,
      {IconData? icon,
      bool copyable = false,
      bool highlight = false,
      Color? highlightColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 18,
                color: highlight
                    ? highlightColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const Spacer(),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                HapticFeedback.selectionClick();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).isArabic
                          ? 'تم النسخ'
                          : 'Copied!',
                      style: GoogleFonts.cairo(),
                    ),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin:
                        const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: highlight
                          ? highlightColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.copy_rounded,
                      size: 14,
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.5)),
                ],
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: highlight
                      ? highlightColor
                      : theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15));

  Widget _buildQrSection(AppLocalizations l10n, ThemeProvider themeProvider,
      List<Color> gradient) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.scanToVerify,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 180,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: gradient.first,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: const Color(0xFF1A1A2E),
              ),
              embeddedImage: const AssetImage('assets/images/logo.png'),
              embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(36, 36)),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: gradient.first.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_scanner,
                    size: 16, color: gradient.first),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'aqari.sa/verify?txn=${widget.transactionId}',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: gradient.first,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppLocalizations l10n, ThemeProvider themeProvider,
      List<Color> gradient) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/contracts'),
            icon: const Icon(Icons.description_outlined,
                color: Colors.white, size: 20),
            label: Text(
              l10n.isArabic ? 'عرض العقد' : 'View Contract',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: gradient.first,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.isArabic
                            ? 'جارٍ تحميل الإيصال...'
                            : 'Downloading receipt...',
                        style: GoogleFonts.cairo(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(l10n.downloadReceipt,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.isArabic
                            ? 'جارٍ مشاركة الإيصال...'
                            : 'Sharing receipt...',
                        style: GoogleFonts.cairo(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(l10n.shareReceipt,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go('/home'),
          child: Text(
            l10n.isArabic ? 'العودة للرئيسية' : 'Back to Home',
            style: GoogleFonts.cairo(
              color: themeProvider.currentScheme.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
