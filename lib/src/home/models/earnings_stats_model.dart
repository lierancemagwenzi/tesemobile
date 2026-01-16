class AmountStatsModel {
  final String? currency;
  final double? totalAmount;
  final double? todayAmount;
  final double? weeklyAmount;
  final double? monthlyAmount;

  AmountStatsModel({
    this.currency,
    this.totalAmount,
    this.todayAmount,
    this.weeklyAmount,
    this.monthlyAmount,
  });

  // --- Static Helper to safely parse numbers ---
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // --- Factory Constructor for JSON Deserialization (FROM JSON) ---
  factory AmountStatsModel.fromJson(Map<String, dynamic> json) {
    return AmountStatsModel(
      currency: json['currency'] as String?,
      totalAmount: _parseDouble(json['totalAmount']),
      todayAmount: _parseDouble(json['todayAmount']),
      weeklyAmount: _parseDouble(json['weeklyAmount']),
      monthlyAmount: _parseDouble(json['monthlyAmount']),
    );
  }

  // --- Method for JSON Serialization (TO JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'totalAmount': totalAmount,
      'todayAmount': todayAmount,
      'weeklyAmount': weeklyAmount,
      'monthlyAmount': monthlyAmount,
    };
  }
}
