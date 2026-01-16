class PayoutModel {
  final int? id;
  final String? payoutMerchantId;
  final String? payoutMerchantRef;
  final DateTime? payoutMerchantDate;
  final double? payoutMerchantAmount;
  final String? payoutMerchantCurrency;
  final String? payoutMerchantDocumentOne;
  final String? payoutMerchantDocumentTwo;
  final double? payoutMerchantSmatPayAmountFees;
  final double? payoutMerchantBankFeesAmount;
  final double? payoutMerchantActualPayoutBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? payoutMerchantStatus;

  PayoutModel({
    this.id,
    this.payoutMerchantId,
    this.payoutMerchantRef,
    this.payoutMerchantDate,
    this.payoutMerchantAmount,
    this.payoutMerchantCurrency,
    this.payoutMerchantDocumentOne,
    this.payoutMerchantDocumentTwo,
    this.payoutMerchantSmatPayAmountFees,
    this.payoutMerchantBankFeesAmount,
    this.payoutMerchantActualPayoutBalance,
    this.createdAt,
    this.updatedAt,
    this.payoutMerchantStatus,
  });

  // --- Static Helper Methods ---

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  // --- Factory Constructor for JSON Deserialization (FROM JSON) ---
  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: _parseInt(json['id']),
      payoutMerchantId: json['payoutMerchantId'] as String?,
      payoutMerchantRef: json['payoutMerchantRef'] as String?,
      payoutMerchantDate: _parseDate(json['payoutMerchantDate']),
      payoutMerchantAmount: _parseDouble(json['payoutMerchantAmount']),
      payoutMerchantCurrency: json['payoutMerchantCurrency'] as String?,
      payoutMerchantDocumentOne: json['payoutMerchantDocumentOne'] as String?,
      payoutMerchantDocumentTwo: json['payoutMerchantDocumentTwo'] as String?,
      payoutMerchantSmatPayAmountFees: _parseDouble(
        json['payoutMerchantSmatPayAmountFees'],
      ),
      payoutMerchantBankFeesAmount: _parseDouble(
        json['payoutMerchantBankFeesAmount'],
      ),
      payoutMerchantActualPayoutBalance: _parseDouble(
        json['payoutMerchantActualPayoutBalance'],
      ),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      payoutMerchantStatus: json['payoutMerchantStatus'] as String?,
    );
  }

  // --- Method for JSON Serialization (TO JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payoutMerchantId': payoutMerchantId,
      'payoutMerchantRef': payoutMerchantRef,
      'payoutMerchantDate': payoutMerchantDate?.toIso8601String(),
      'payoutMerchantAmount': payoutMerchantAmount,
      'payoutMerchantCurrency': payoutMerchantCurrency,
      'payoutMerchantDocumentOne': payoutMerchantDocumentOne,
      'payoutMerchantDocumentTwo': payoutMerchantDocumentTwo,
      'payoutMerchantSmatPayAmountFees': payoutMerchantSmatPayAmountFees,
      'payoutMerchantBankFeesAmount': payoutMerchantBankFeesAmount,
      'payoutMerchantActualPayoutBalance': payoutMerchantActualPayoutBalance,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'payoutMerchantStatus': payoutMerchantStatus,
    };
  }
}
