import 'dart:convert';

extension StringCasingExtension on String {
  /// Converts a string to Title Case (e.g., "hello world" -> "Hello World").
  String toTitleCase() {
    if (this.isEmpty) {
      return this;
    }

    // 1. Convert the entire string to lowercase first (optional, but ensures consistent output)
    String lowerCaseString = this.toLowerCase();

    // 2. Split the string by spaces, map each word, and join them back.
    return lowerCaseString
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return '';
          }
          // Capitalize the first letter and append the rest of the word
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}

class PaymentLinkModel {
  final int id;
  final String paymentProfileName;
  final String paymentLinkEmail;
  final String paymentProfileDescription;
  final String paymentLinkReference;
  final String paymentLinkUrl;
  final String paymentLinkShortUrl;
  final double? paymentLinkAmount; // Use double for currency amounts
  final String paymentLinkType;
  final String paymentLinkToken;
  final String? paymentLinkImageUrl;
  final DateTime paymentLinkStartDate;
  final DateTime paymentLinkEndDate;
  final bool paymentLinkIsActive;
  final String paymentLinkCurrency;
  final int paymentLinkCurrencyId;
  final bool paymentLinkOtherCurrencies;
  final String paymentLinkCustomerRedirectUrl;
  final String paymentCustomerFailRedirectUrl;
  final String? paymentPayerFullNames; // Nullable
  final String? paymentPayerEmailAddress; // Nullable
  final String? paymentPayerAddress; // Nullable
  final String? paymentPayerMobile; // Nullable
  final int? paymentPayerCustomerId; // Nullable
  final DateTime createdAt;

  final String? paymentLinkCustomerZimSwitchSkinnedUrl;
  final String? paymentLinkCustomerEcocashSkinnedUrl;
  final String? paymentLinkCustomerInnBucksSkinnedUrl;
  final String? paymentLinkCustomerVisaSkinnedUrl;
  final String? paymentLinkCustomerMastercardSkinnedUrl;
  final num? paymentLinkAdditionalFees;

  String get title {
    return paymentLinkType.replaceAll('_', ' ').toLowerCase().toTitleCase();
  }

  PaymentLinkModel({
    required this.id,
    this.paymentLinkCustomerZimSwitchSkinnedUrl,
    this.paymentLinkCustomerEcocashSkinnedUrl,
    this.paymentLinkCustomerInnBucksSkinnedUrl,
    this.paymentLinkCustomerVisaSkinnedUrl,
    this.paymentLinkCustomerMastercardSkinnedUrl,
    required this.paymentProfileName,
    required this.paymentLinkEmail,
    required this.paymentProfileDescription,
    required this.paymentLinkReference,
    required this.paymentLinkUrl,
    required this.paymentLinkShortUrl,
    this.paymentLinkAmount,
    required this.paymentLinkType,
    required this.paymentLinkToken,
    this.paymentLinkImageUrl,
    this.paymentLinkAdditionalFees,
    required this.paymentLinkStartDate,
    required this.paymentLinkEndDate,
    required this.paymentLinkIsActive,
    required this.paymentLinkCurrency,
    required this.paymentLinkCurrencyId,
    required this.paymentLinkOtherCurrencies,
    required this.paymentLinkCustomerRedirectUrl,
    required this.paymentCustomerFailRedirectUrl,
    this.paymentPayerFullNames,
    this.paymentPayerEmailAddress,
    this.paymentPayerAddress,
    this.paymentPayerMobile,
    this.paymentPayerCustomerId,
    required this.createdAt,
  });

  // Factory constructor for JSON deserialization
  factory PaymentLinkModel.fromJson(Map<String, dynamic> json) {
    return PaymentLinkModel(
      id: json['id'] as int,
      paymentProfileName: json['paymentProfileName'] as String,
      paymentLinkEmail: json['paymentLinkEmail'] as String,
      paymentProfileDescription: json['paymentProfileDescription'] as String,
      paymentLinkReference: json['paymentLinkReference'] as String,
      paymentLinkUrl: json['paymentLinkUrl'] as String,
      paymentLinkShortUrl: json['paymentLinkShortUrl'] as String,
      // Ensure amount is parsed as a double, even if it comes as an int
      paymentLinkAmount: json['paymentLinkAmount'] != null
          ? (json['paymentLinkAmount'] as num).toDouble()
          : null,
      paymentLinkType: json['paymentLinkType'] as String,
      paymentLinkToken: json['paymentLinkToken'] as String,
      paymentLinkImageUrl: json['paymentLinkImageUrl'] != null
          ? json['paymentLinkImageUrl'] as String
          : null,

      // Parse DateTimes
      paymentLinkStartDate: DateTime.parse(
        json['paymentLinkStartDate'] as String,
      ),
      paymentLinkEndDate: DateTime.parse(json['paymentLinkEndDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),

      paymentLinkIsActive: json['paymentLinkIsActive'] as bool,
      paymentLinkCurrency: json['paymentLinkCurrency'] as String,
      paymentLinkCurrencyId: json['paymentLinkCurrencyId'] as int,
      paymentLinkOtherCurrencies: json['paymentLinkOtherCurrencies'] as bool,
      paymentLinkCustomerRedirectUrl:
          json['paymentLinkCustomerRedirectUrl'] as String,
      paymentCustomerFailRedirectUrl:
          json['paymentCustomerFailRedirectUrl'] as String,

      // Handle Nullable String Fields
      paymentPayerFullNames: json['paymentPayerFullNames'] as String?,
      paymentPayerEmailAddress: json['paymentPayerEmailAddress'] as String?,
      paymentPayerAddress: json['paymentPayerAddress'] as String?,
      paymentPayerMobile: json['paymentPayerMobile'] as String?,

      paymentLinkAdditionalFees:
          json['paymentLinkAdditionalFees'] != null &&
              num.tryParse(json['paymentLinkAdditionalFees'].toString()) != null
          ? num.tryParse(json['paymentLinkAdditionalFees'].toString())
          : 0,

      // Handle Nullable Int Field
      paymentPayerCustomerId: json['paymentPayerCustomerId'] as int?,

      paymentLinkCustomerZimSwitchSkinnedUrl:
          json['paymentLinkCustomerZimSwitchSkinnedUrl'] as String?,
      paymentLinkCustomerEcocashSkinnedUrl:
          json['paymentLinkCustomerEcocashSkinnedUrl'] as String?,
      paymentLinkCustomerInnBucksSkinnedUrl:
          json['paymentLinkCustomerInnBucksSkinnedUrl'] as String?,
      paymentLinkCustomerVisaSkinnedUrl:
          json['paymentLinkCustomerVisaSkinnedUrl'] as String?,
      paymentLinkCustomerMastercardSkinnedUrl:
          json['paymentLinkCustomerMastercardSkinnedUrl'] as String?,
    );
  }

  // Optional: Method for JSON serialization (to send back to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentProfileName': paymentProfileName,
      // ... include all fields ...
      'paymentLinkAmount': paymentLinkAmount,
      'paymentLinkStartDate': paymentLinkStartDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'paymentPayerFullNames': paymentPayerFullNames,
      // ... and so on
    };
  }
}
