import 'dart:convert';

class CurrencyModel {
  final int id;
  final String currencyName;
  final String currencyCode;
  final String currencyCrmId;
  final String currencySymbol;
  final String currencyFlag;
  final DateTime createdAt;
  final DateTime? updatedAt; // Nullable field

  CurrencyModel({
    required this.id,
    required this.currencyName,
    required this.currencyCode,
    required this.currencyCrmId,
    required this.currencySymbol,
    required this.currencyFlag,
    required this.createdAt,
    this.updatedAt,
  });

  // --- Factory Constructor for JSON Deserialization (FROM JSON) ---
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] as int,
      currencyName: json['currencyName'] as String,
      currencyCode: json['currencyCode'] as String,
      currencyCrmId: json['currencyCrmId'] as String,
      currencySymbol: json['currencySymbol'] as String,
      currencyFlag: json['currencyFlag'] as String,
      // Parse ISO 8601 strings into DateTime objects
      createdAt: DateTime.parse(json['createdAt'] as String),
      // Handle the nullable 'updatedAt' field
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // --- Method for JSON Serialization (TO JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currencyName': currencyName,
      'currencyCode': currencyCode,
      'currencyCrmId': currencyCrmId,
      'currencySymbol': currencySymbol,
      'currencyFlag': currencyFlag,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(), // Use null-aware operator
    };
  }

  // --- Helper method to convert a list of JSON maps to a List of Currency objects ---
  static List<CurrencyModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => CurrencyModel.fromJson(json)).toList();
  }
}
