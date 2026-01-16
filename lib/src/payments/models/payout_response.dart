class ApiResponseModel {
  final PayoutDataModel data;
  final String status;
  final String message;

  ApiResponseModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    // Deserialize the nested 'data' map into the PayoutDataModel
    return ApiResponseModel(
      data: PayoutDataModel.fromJson(json['data'] as Map<String, dynamic>),
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.toJson(), 'status': status, 'message': message};
  }
}



class PayoutDataModel {
  final String merchantId;
  final double amount;
  final String currency;

  PayoutDataModel({
    required this.merchantId,
    required this.amount,
    required this.currency,
  });

  factory PayoutDataModel.fromJson(Map<String, dynamic> json) {
    return PayoutDataModel(
      merchantId: json['merchantId'] as String,
      // Safely convert amount to double
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'merchantId': merchantId, 'amount': amount, 'currency': currency};
  }
}
