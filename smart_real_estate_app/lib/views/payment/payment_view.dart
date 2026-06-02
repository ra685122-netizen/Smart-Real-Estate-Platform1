import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/payment_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../widgets/riyal_icon.dart';
import './payment_success_view.dart';

class PaymentView extends StatefulWidget {
  final double amount;
  final String propertyTitle;
  final int? contractId;
  final int? sellerId;

  const PaymentView({
    Key? key,
    required this.amount,
    required this.propertyTitle,
    this.contractId,
    this.sellerId,
  }) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _methodToString(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.bankTransfer: return 'bankTransfer';
      case PaymentMethod.stcPay:       return 'stcPay';
      case PaymentMethod.applePay:     return 'applePay';
      case PaymentMethod.googlePay:    return 'googlePay';
      case PaymentMethod.qrCode:       return 'qrCode';
      default:                         return 'creditCard';
    }
  }

  void _handlePayment() async {
    if (_selectedMethod == PaymentMethod.creditCard && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    final user = context.read<AuthProvider>().currentUser;
    String transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';

    if (user != null) {
      final result = await ApiService.processPayment(
        payerId: user.id,
        payeeId: 1,
        amount: widget.amount,
        method: _methodToString(_selectedMethod),
        contractId: widget.contractId,
        notes: widget.propertyTitle,
      );
      if (result['success'] == true) {
        final payment = result['payment'] as dynamic;
        transactionId = payment?.transactionId ?? transactionId;
      }
      ApiService.sendPaymentNotifications(
        buyerId: user.id,
        sellerId: widget.sellerId ?? 1,
        amount: widget.amount,
        propertyTitle: widget.propertyTitle,
        transactionId: transactionId,
        buyerName: user.name,
      );
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessView(
            amount: widget.amount,
            transactionId: transactionId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.payment),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.currentScheme.gradient,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAmountHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),
                  if (_selectedMethod == PaymentMethod.creditCard) _buildCreditCardForm(),
                  if (_selectedMethod == PaymentMethod.qrCode) _buildQRCodeSection(),
                  const SizedBox(height: 24),
                  _buildOrderSummary(),
                  const SizedBox(height: 32),
                  _buildPayButton(),
                  const SizedBox(height: 20),
                  _buildSecurityBadges(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeProvider.currentScheme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.propertyTitle,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RiyalIcon(size: 28, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.amount.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildMethodCard(PaymentMethod.creditCard, Icons.credit_card, AppLocalizations.of(context).creditCard),
        _buildMethodCard(PaymentMethod.qrCode, Icons.qr_code_2, AppLocalizations.of(context).isArabic ? 'دفع بالباركود' : 'QR Code Payment'),
        _buildMethodCard(PaymentMethod.applePay, Icons.apple, 'Apple Pay'),
        _buildMethodCard(PaymentMethod.stcPay, Icons.phone_android, 'STC Pay'),
        _buildMethodCard(PaymentMethod.bankTransfer, Icons.account_balance, AppLocalizations.of(context).bankTransfer),
      ],
    );
  }

  Widget _buildMethodCard(PaymentMethod method, IconData icon, String title) {
    final isSelected = _selectedMethod == method;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? themeProvider.currentScheme.primary : Colors.grey[200]!, width: 2),
          boxShadow: [
            if (isSelected) BoxShadow(color: themeProvider.currentScheme.primary.withValues(alpha: 0.1), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? themeProvider.currentScheme.primary : Colors.grey),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: themeProvider.currentScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildCardVisual(),
          const SizedBox(height: 24),
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: 'XXXX XXXX XXXX XXXX',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (v) => v!.length < 19 ? 'Invalid card number' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _holderNameController,
            decoration: InputDecoration(
              labelText: 'Card Holder Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => v!.isEmpty ? 'Name required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateFormatter(),
                  ],
                  validator: (v) => v!.length < 5 ? 'Invalid expiry' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (v) => v!.length < 3 ? 'Invalid CVV' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardVisual() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeProvider.currentScheme.primary, themeProvider.currentScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.contactless, color: Colors.white, size: 32),
              Text('VISA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
          const Spacer(),
          Text(
            _cardNumberController.text.isEmpty ? 'XXXX XXXX XXXX XXXX' : _cardNumberController.text,
            style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HOLDER NAME', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(_holderNameController.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EXPIRY', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(_expiryController.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final vat = widget.amount * 0.15;
    final total = widget.amount + vat;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _summaryRow(l10n.price, widget.amount),
          _summaryRow('VAT (15%)', vat),
          const Divider(height: 24),
          _summaryRow('Total', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
          Row(
            children: [
              Text(amount.toStringAsFixed(0), style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
              const SizedBox(width: 4),
              const Text('SAR', style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.currentScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Pay Securely', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityBadges() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text('SSL Encrypted', style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(width: 16),
        Icon(Icons.security, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text('PCI DSS Compliant', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildQRCodeSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primary = themeProvider.currentScheme.primary;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.isArabic ? 'امسح الرمز للدفع' : 'Scan QR Code to Pay',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primary),
          ),
          const SizedBox(height: 20),
          // Custom QR Code
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary, width: 3),
            ),
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              painter: _QRCodePainter(primary),
              size: const Size(184, 184),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_money, color: primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.amount.toStringAsFixed(0)} ${l10n.isArabic ? "ريال" : "SAR"}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.isArabic
                ? 'استخدم تطبيق البنك لمسح رمز QR وإتمام الدفع'
                : 'Use your banking app to scan the QR code and complete payment',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQRBankIcon('mada', Colors.blue[800]!),
              const SizedBox(width: 12),
              _buildQRBankIcon('STC', Colors.purple),
              const SizedBox(width: 12),
              _buildQRBankIcon('الراجحي', Colors.teal),
              const SizedBox(width: 12),
              _buildQRBankIcon('الأهلي', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRBankIcon(String name, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (color ?? Colors.grey).withValues(alpha: 0.3)),
      ),
      child: Text(
        name,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color ?? Colors.grey),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class _QRCodePainter extends CustomPainter {
  final Color color;
  _QRCodePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final unit = size.width / 25;

    // Draw finder patterns (3 corner squares)
    _drawFinderPattern(canvas, paint, 0, 0, unit);
    _drawFinderPattern(canvas, paint, size.width - 7 * unit, 0, unit);
    _drawFinderPattern(canvas, paint, 0, size.height - 7 * unit, unit);

    // Draw data modules (deterministic pattern)
    final pattern = [
      [0,0,0,0,0,0,0,0,1,0,1,1,0,1,0,1,1,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,0,1,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,1,0,1,1,0,1,0,1,1,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [1,0,1,0,1,0,1,0,1,1,0,1,1,0,1,0,1,1,1,0,1,1,0,1,0],
      [0,1,0,1,0,0,1,0,0,1,0,0,1,1,0,1,0,1,0,1,0,0,1,0,1],
      [1,0,1,1,0,1,0,1,1,0,1,1,0,0,1,1,0,0,1,0,1,1,0,1,0],
      [1,1,0,0,1,0,1,0,0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1],
      [0,1,1,0,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,0],
      [1,0,0,1,0,1,1,0,1,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1],
      [0,1,1,1,0,0,1,0,0,1,1,0,1,1,0,1,1,1,0,1,1,0,1,1,0],
      [1,0,1,0,1,1,0,0,1,0,1,0,0,1,1,0,1,0,1,0,0,1,0,1,1],
      [0,1,0,1,1,0,1,0,1,1,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0],
      [0,0,0,0,0,0,0,0,1,0,1,0,1,1,0,1,1,0,1,0,1,1,0,1,1],
      [0,0,0,0,0,0,0,0,0,1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0],
      [0,0,0,0,0,0,0,0,1,1,1,0,1,1,0,1,1,1,1,0,1,1,0,1,1],
      [0,0,0,0,0,0,0,0,1,0,0,1,0,1,1,0,1,0,0,1,0,1,1,0,0],
      [0,0,0,0,0,0,0,0,0,1,1,0,1,0,0,1,0,1,1,0,1,0,0,1,1],
      [0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,1,0,1,1,0,1,1,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,1,0,1,1,1],
      [0,0,0,0,0,0,0,0,1,1,0,1,0,1,0,0,1,1,0,1,0,1,0,0,0],
    ];

    for (int row = 0; row < 25; row++) {
      for (int col = 0; col < 25; col++) {
        // Skip finder pattern areas
        if ((row < 8 && col < 8) || (row < 8 && col > 16) || (row > 16 && col < 8)) continue;
        if (pattern[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(col * unit, row * unit, unit, unit),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, double x, double y, double unit) {
    // Outer border
    canvas.drawRect(Rect.fromLTWH(x, y, 7 * unit, 7 * unit), paint);
    // White inner
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + unit, y + unit, 5 * unit, 5 * unit), whitePaint);
    // Inner black square
    canvas.drawRect(Rect.fromLTWH(x + 2 * unit, y + 2 * unit, 3 * unit, 3 * unit), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
