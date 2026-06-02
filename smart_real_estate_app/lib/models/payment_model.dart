enum PaymentStatus { pending, completed, failed, refunded }

enum PaymentMethod { creditCard, bankTransfer, stcPay, applePay, googlePay, qrCode }

class Payment {
  final int id;
  final int userId;
  final int? contractId;
  final int? propertyId;
  final String propertyTitle;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime createdAt;
  final String transactionId;
  final String? description;

  const Payment({
    required this.id,
    required this.userId,
    this.contractId,
    this.propertyId,
    required this.propertyTitle,
    required this.amount,
    required this.status,
    required this.method,
    required this.createdAt,
    required this.transactionId,
    this.description,
  });

  String get statusLabelAr {
    switch (status) {
      case PaymentStatus.pending:
        return 'قيد المعالجة';
      case PaymentStatus.completed:
        return 'مكتمل';
      case PaymentStatus.failed:
        return 'فشل';
      case PaymentStatus.refunded:
        return 'مُسترد';
    }
  }

  String get methodLabelAr {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمانية';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethod.stcPay:
        return 'STC Pay';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.qrCode:
        return 'دفع بالباركود';
    }
  }
}

class CardInfo {
  final String number;
  final String holderName;
  final String expiryDate;
  final String cvv;

  const CardInfo({
    required this.number,
    required this.holderName,
    required this.expiryDate,
    required this.cvv,
  });
}
