enum ContractStatus { pending, signed, expired, cancelled, underReview }

enum ContractType { sale, rent, agency }

class Contract {
  final int id;
  final int propertyId;
  final String propertyTitle;
  final String propertyImage;
  final int buyerId;
  final String buyerName;
  final int sellerId;
  final String sellerName;
  final double amount;
  final ContractType type;
  final ContractStatus status;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final DateTime? signedAt;
  final String? notes;
  final bool buyerSigned;
  final bool sellerSigned;
  final String contractNumber;

  const Contract({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyImage,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    this.expiryDate,
    this.signedAt,
    this.notes,
    this.buyerSigned = false,
    this.sellerSigned = false,
    required this.contractNumber,
  });

  String get statusLabelAr {
    switch (status) {
      case ContractStatus.pending:
        return 'قيد الانتظار';
      case ContractStatus.signed:
        return 'موقّع';
      case ContractStatus.expired:
        return 'منتهي الصلاحية';
      case ContractStatus.cancelled:
        return 'ملغي';
      case ContractStatus.underReview:
        return 'قيد المراجعة';
    }
  }

  String get statusLabelEn {
    switch (status) {
      case ContractStatus.pending:
        return 'Pending';
      case ContractStatus.signed:
        return 'Signed';
      case ContractStatus.expired:
        return 'Expired';
      case ContractStatus.cancelled:
        return 'Cancelled';
      case ContractStatus.underReview:
        return 'Under Review';
    }
  }

  String get typeLabelAr {
    switch (type) {
      case ContractType.sale:
        return 'عقد بيع';
      case ContractType.rent:
        return 'عقد إيجار';
      case ContractType.agency:
        return 'عقد وكالة';
    }
  }
}
