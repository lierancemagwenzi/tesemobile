// Assume BankAccount model (from previous response) is available here or imported
// import 'bank_account.dart';

import 'package:smacredit/src/payments/models/bank_account.dart';

// Assume BankAccount model (from previous request) is available here or imported

class ProfileBankLinking {
  final int? profileBankLinkingId;
  final int? profileId;
  final int? bankAccountId;
  // CHANGED: Now expects a single BankAccount object, not a List.
  final BankAccount? bankAccounts;

  ProfileBankLinking({
    this.profileBankLinkingId,
    this.profileId,
    this.bankAccountId,
    this.bankAccounts,
  });

  factory ProfileBankLinking.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Safely parse the single BankAccount object
    final Map<String, dynamic>? rawBankAccounts =
        json['bankAccounts'] as Map<String, dynamic>?;

    final BankAccount? parsedBankAccount = rawBankAccounts != null
        ? BankAccount.fromJson(rawBankAccounts)
        : null;

    return ProfileBankLinking(
      profileBankLinkingId: parseInt(json['profileBankLinkingId']),
      profileId: parseInt(json['profileId']),
      bankAccountId: parseInt(json['bankAccountId']),
      bankAccounts: parsedBankAccount, // Assign the single object
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileBankLinkingId': profileBankLinkingId,
      'profileId': profileId,
      'bankAccountId': bankAccountId,
      'bankAccounts': bankAccounts
          ?.toJson(), // Call toJson on the single object
    };
  }
}

class PaymentProfile {
  final int? id;
  final String? paymentProfileName;
  final int? paymentProfileNumber;
  final String? paymentProfileDescription;
  final bool? paymentProfileApproved;
  final bool? paymentChargeCustomer;
  final String? paymentProfileWebHookUrl;
  final String? paymentProfileRedirectUrl;
  final String? paymentProfileFailedRedirectUrl;
  final int? bankAccountId;
  final DateTime? createdAt;
  final dynamic
  bankAccounts; // Assumed to be dynamic/null based on initial data
  final List<ProfileBankLinking>?
  otherBanks; // Correctly using the nested model

  PaymentProfile({
    this.id,
    this.paymentProfileName,
    this.paymentProfileNumber,
    this.paymentProfileDescription,
    this.paymentProfileApproved,
    this.paymentChargeCustomer,
    this.paymentProfileWebHookUrl,
    this.paymentProfileRedirectUrl,
    this.paymentProfileFailedRedirectUrl,
    this.bankAccountId,
    this.createdAt,
    this.bankAccounts,
    this.otherBanks,
  });

  factory PaymentProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Safely parse the 'otherBanks' list into a list of ProfileBankLinking objects
    final List<ProfileBankLinking>? otherBanksList =
        (json['otherBanks'] as List<dynamic>?)
            ?.map(
              (item) =>
                  ProfileBankLinking.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    return PaymentProfile(
      id: parseInt(json['id']),
      paymentProfileName: json['paymentProfileName'] as String?,
      paymentProfileNumber: parseInt(json['paymentProfileNumber']),
      paymentProfileDescription: json['paymentProfileDescription'] as String?,
      paymentProfileApproved: json['paymentProfileApproved'] as bool?,
      paymentChargeCustomer: json['paymentChargeCustomer'] as bool?,
      paymentProfileWebHookUrl: json['paymentProfileWebHookUrl'] as String?,
      paymentProfileRedirectUrl: json['paymentProfileRedirectUrl'] as String?,
      paymentProfileFailedRedirectUrl:
          json['paymentProfileFailedRedirectUrl'] as String?,
      bankAccountId: parseInt(json['bankAccountId']),
      createdAt: parseDate(json['createdAt']),
      bankAccounts: json['bankAccounts'], // Retained as dynamic/null
      otherBanks: otherBanksList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentProfileName': paymentProfileName,
      'paymentProfileNumber': paymentProfileNumber,
      // ... (other fields)
      'createdAt': createdAt?.toIso8601String(),
      'otherBanks': otherBanks?.map((e) => e.toJson()).toList(),
    };
  }
}

class AccountInfo {
  final PaymentProfile? paymentProfile;
  final String? proofOfResidence; // Assuming this would hold a string/URL

  AccountInfo({this.paymentProfile, this.proofOfResidence});

  bool get hasBank {
    return paymentProfile?.bankAccountId != null ||
        paymentProfile?.otherBanks?.isNotEmpty == true ||
        paymentProfile?.bankAccounts != null;
  }

  BankAccount? get bank {
    if (paymentProfile?.otherBanks != null) {
      return (paymentProfile?.otherBanks ?? []).first.bankAccounts;
    }

    return null;
  }

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    final paymentProfileJson = json['paymentProfile'];

    return AccountInfo(
      // Safely parse the nested object
      paymentProfile: paymentProfileJson != null
          ? PaymentProfile.fromJson(paymentProfileJson as Map<String, dynamic>)
          : null,

      proofOfResidence: json['proof_of_residence'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentProfile': paymentProfile?.toJson(),
      'proof_of_residence': proofOfResidence,
    };
  }
}
