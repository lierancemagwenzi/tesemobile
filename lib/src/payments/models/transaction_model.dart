import 'dart:convert';

class TransactionModel {
  final int id;
  final String? merchantId;
  final String? walletName;
  final double amount;
  final String? paymentDescription;
  final double? totalCharges;
  final int? transactionPaid;
  final bool? status;
  final String? payerName;
  final int payerAccountId;
  final String? payerSmatPayReference;
  final String? payerReference;
  final String? paymentReference;
  final String? paymentCurrency;
  final String? paymentAuthNumber;
  final String? paymentID;
  final DateTime createdAt;
  final String? payerCode;
  final String? paymentStatus;
  final String? payerQrCode; // Nullable
  final String? payerBatchNumber;
  final String? payerBatchNumberWallet;
  final int? callBackSent;
  final String? sentToBank; // Nullable
  final String? clearedAtBank; // Nullable
  final String? sentForReversal; // Nullable
  final String? reversalConfirmed; // Nullable
  final int? paymentProfileID;
  final int paymentProfileNumber;
  final String? reversalReferenceOne;
  final String? reversalReferenceTwo;
  final String? payerGlobalToken;
  final int? transactionPaymentMethodId;
  final int? transactionCurrencyID;
  final String? transactionFraudStatus; // Nullable
  final bool? transactionOminiStatus;
  final bool? transactionRequestPayoutStatus;
  final String? transactionRequestPayoutOTP; // Nullable
  final String? transactionRequestPayoutUsername; // Nullable
  final String? recurringReference; // Nullable
  final String? paymentBeneficiariesLinked; // Nullable
  final String? paymentDynamicLinked; // Nullable
  final int? bankPercentageCharges;
  final int? bankValue;
  final double? bankCharges;
  final String?
  customerId; // Nullable (Note: 'null' in JSON is treated as null in Dart)
  final bool? creditTransactionFlagged;
  final String? creditTransaction; // Nullable

  TransactionModel({
    required this.id,
    required this.merchantId,
    required this.walletName,
    required this.amount,
    required this.paymentDescription,
    required this.totalCharges,
    required this.transactionPaid,
    required this.status,
    required this.payerName,
    required this.payerAccountId,
    required this.payerSmatPayReference,
    required this.payerReference,
    required this.paymentReference,
    required this.paymentCurrency,
    required this.paymentAuthNumber,
    required this.paymentID,
    required this.createdAt,
    required this.payerCode,
    required this.paymentStatus,
    this.payerQrCode,
    required this.payerBatchNumber,
    required this.payerBatchNumberWallet,
    required this.callBackSent,
    this.sentToBank,
    this.clearedAtBank,
    this.sentForReversal,
    this.reversalConfirmed,
    required this.paymentProfileID,
    required this.paymentProfileNumber,
    required this.reversalReferenceOne,
    required this.reversalReferenceTwo,
    required this.payerGlobalToken,
    required this.transactionPaymentMethodId,
    required this.transactionCurrencyID,
    this.transactionFraudStatus,
    required this.transactionOminiStatus,
    required this.transactionRequestPayoutStatus,
    this.transactionRequestPayoutOTP,
    this.transactionRequestPayoutUsername,
    this.recurringReference,
    this.paymentBeneficiariesLinked,
    this.paymentDynamicLinked,
    required this.bankPercentageCharges,
    required this.bankValue,
    required this.bankCharges,
    this.customerId,
    required this.creditTransactionFlagged,
    this.creditTransaction,
  });

  // Factory constructor to create a TransactionModel from a JSON Map
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      merchantId: json['merchantId'] as String?,
      walletName: json['walletName'] as String?,
      // Amounts and charges should be double
      amount: (json['amount'] as num).toDouble(),
      paymentDescription: json['paymentDescription'] as String?,
      totalCharges: (json['totalCharges'] as num).toDouble(),
      transactionPaid: json['transactionPaid'] as int?,
      status: json['status'] as bool?,
      payerName: json['payerName'] as String?,
      payerAccountId: json['payerAccountId'] as int,
      payerSmatPayReference: json['payerSmatPayReference'] as String?,
      payerReference: json['payerReference'] as String?,
      paymentReference: json['paymentReference'] as String?,
      paymentCurrency: json['paymentCurrency'] as String?,
      paymentAuthNumber: json['paymentAuthNumber'] as String?,
      paymentID: json['paymentID'] as String,
      // Convert the timestamp string to a DateTime object
      createdAt: DateTime.parse(json['createdAt'] as String),
      payerCode: json['payerCode'] as String?,
      paymentStatus: json['paymentStatus'] as String,
      payerQrCode: json['payerQrCode'] as String?,
      payerBatchNumber: json['payerBatchNumber'] as String?,
      payerBatchNumberWallet: json['payerBatchNumberWallet'] as String?,
      callBackSent: json['callBackSent'] as int?,
      sentToBank: json['sentToBank'] as String?,
      clearedAtBank: json['clearedAtBank'] as String?,
      sentForReversal: json['sentForReversal'] as String?,
      reversalConfirmed: json['reversalConfirmed'] as String?,
      paymentProfileID: json['paymentProfileID'] as int?,
      paymentProfileNumber: json['paymentProfileNumber'] as int,
      reversalReferenceOne: json['reversalReferenceOne'] as String?,
      reversalReferenceTwo: json['reversalReferenceTwo'] as String?,
      payerGlobalToken: json['payerGlobalToken'] as String?,
      transactionPaymentMethodId: json['transactionPaymentMethodId'] as int,
      transactionCurrencyID: json['transactionCurrencyID'] as int?,
      transactionFraudStatus: json['transactionFraudStatus'] as String?,
      transactionOminiStatus: json['transactionOminiStatus'] as bool,
      transactionRequestPayoutStatus:
          json['transactionRequestPayoutStatus'] as bool?,
      transactionRequestPayoutOTP:
          json['transactionRequestPayoutOTP'] as String?,
      transactionRequestPayoutUsername:
          json['transactionRequestPayoutUsername'] as String?,
      recurringReference: json['recurringReference'] as String?,
      paymentBeneficiariesLinked: json['paymentBeneficiariesLinked'] as String?,
      // paymentDynamicLinked: json['paymentDynamicLinked'] as String?,
      bankPercentageCharges: json['bankPercentageCharges'] as int?,
      bankValue: json['bankValue'] as int?,
      bankCharges: (json['bankCharges'] as num).toDouble(),
      // Handle the 'null' string coming from the JSON for customerId
      customerId: json['customerId'] != 'null'
          ? json['customerId'] as String?
          : null,
      creditTransactionFlagged: json['creditTransactionFlagged'] as bool?,
      creditTransaction: json['creditTransaction'] as String?,
    );
  }

  // Optional: A method to convert the model back to a Map (useful for serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantId': merchantId,
      'walletName': walletName,
      'amount': amount,
      'paymentDescription': paymentDescription,
      'totalCharges': totalCharges,
      'transactionPaid': transactionPaid,
      'status': status,
      'payerName': payerName,
      'payerAccountId': payerAccountId,
      'payerSmatPayReference': payerSmatPayReference,
      'payerReference': payerReference,
      'paymentReference': paymentReference,
      'paymentCurrency': paymentCurrency,
      'paymentAuthNumber': paymentAuthNumber,
      'paymentID': paymentID,
      'createdAt': createdAt.toIso8601String(),
      'payerCode': payerCode,
      'paymentStatus': paymentStatus,
      'payerQrCode': payerQrCode,
      'payerBatchNumber': payerBatchNumber,
      'payerBatchNumberWallet': payerBatchNumberWallet,
      'callBackSent': callBackSent,
      'sentToBank': sentToBank,
      'clearedAtBank': clearedAtBank,
      'sentForReversal': sentForReversal,
      'reversalConfirmed': reversalConfirmed,
      'paymentProfileID': paymentProfileID,
      'paymentProfileNumber': paymentProfileNumber,
      'reversalReferenceOne': reversalReferenceOne,
      'reversalReferenceTwo': reversalReferenceTwo,
      'payerGlobalToken': payerGlobalToken,
      'transactionPaymentMethodId': transactionPaymentMethodId,
      'transactionCurrencyID': transactionCurrencyID,
      'transactionFraudStatus': transactionFraudStatus,
      'transactionOminiStatus': transactionOminiStatus,
      'transactionRequestPayoutStatus': transactionRequestPayoutStatus,
      'transactionRequestPayoutOTP': transactionRequestPayoutOTP,
      'transactionRequestPayoutUsername': transactionRequestPayoutUsername,
      'recurringReference': recurringReference,
      'paymentBeneficiariesLinked': paymentBeneficiariesLinked,
      'paymentDynamicLinked': paymentDynamicLinked,
      'bankPercentageCharges': bankPercentageCharges,
      'bankValue': bankValue,
      'bankCharges': bankCharges,
      'customerId': customerId,
      'creditTransactionFlagged': creditTransactionFlagged,
      'creditTransaction': creditTransaction,
    };
  }
}
