class BankAccount {
  final int? id;
  final String? bankName;
  final String? bankAccountNames;
  final String? bankBICCode;
  final String? bankBranch;
  final String? bankAccount;
  final String? bankSwiftCode;
  final String? bankCurrency;
  final int? bankCurrencyId;
  final DateTime? createdAt;

  BankAccount({
    this.id,
    this.bankName,
    this.bankAccountNames,
    this.bankBICCode,
    this.bankBranch,
    this.bankAccount,
    this.bankSwiftCode,
    this.bankCurrency,
    this.bankCurrencyId,
    this.createdAt,
  });

  // --- Factory Constructor for JSON Deserialization (FROM JSON) ---
  factory BankAccount.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse DateTime
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    // Helper to safely parse Integers
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return BankAccount(
      id: parseInt(json['id']),
      bankName: json['bankName'] as String?,
      bankAccountNames: json['bankAccountNames'] as String?,
      bankBICCode: json['bankBICCode'] as String?,
      bankBranch: json['bankBranch'] as String?,
      bankAccount: json['bankAccount'] as String?,
      bankSwiftCode: json['bankSwiftCode'] as String?,
      bankCurrency: json['bankCurrency'] as String?,
      bankCurrencyId: parseInt(json['bankCurrencyId']),
      createdAt: parseDate(json['createdAt']),
    );
  }

  // --- Method for JSON Serialization (TO JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'bankAccountNames': bankAccountNames,
      'bankBICCode': bankBICCode,
      'bankBranch': bankBranch,
      'bankAccount': bankAccount,
      'bankSwiftCode': bankSwiftCode,
      'bankCurrency': bankCurrency,
      'bankCurrencyId': bankCurrencyId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
