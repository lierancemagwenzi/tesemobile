class PaymentResponseWrapper {
  final ResponseData? response;
  final PurchaseData? purchase;

  PaymentResponseWrapper({this.response, this.purchase});

  factory PaymentResponseWrapper.fromJson(Map<String, dynamic> json) {
    return PaymentResponseWrapper(
      response: json['response'] != null
          ? ResponseData.fromJson(json['response'])
          : null,
      purchase: json['purchase'] != null
          ? PurchaseData.fromJson(json['purchase'])
          : null,
    );
  }
}

class ResponseData {
  final AuthData? auth;
  final PaymentInitiationResponse? paymentInitiationResponse;

  ResponseData({this.auth, this.paymentInitiationResponse});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      auth: json['auth'] != null ? AuthData.fromJson(json['auth']) : null,
      paymentInitiationResponse: json['paymentInitiationResponse'] != null
          ? PaymentInitiationResponse.fromJson(
              json['paymentInitiationResponse'],
            )
          : null,
    );
  }
}

class AuthData {
  final String? token;
  final UserData? user;
  final ErrorResponse? errorResponse;

  AuthData({this.token, this.user, this.errorResponse});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      errorResponse: json['errorResponse'] != null
          ? ErrorResponse.fromJson(json['errorResponse'])
          : null,
    );
  }
}

class UserData {
  final int? id;
  final String? email;
  final String? role;
  final String? token;

  UserData({this.id, this.email, this.role, this.token});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
    );
  }
}

class ErrorResponse {
  final String? errorMessage;
  final int? statusCode;

  ErrorResponse({this.errorMessage, this.statusCode});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      errorMessage: json['errorMessage'],
      statusCode: json['statusCode'],
    );
  }
}

class PaymentInitiationResponse {
  final String? status;
  final String? paymentId;
  final String? paymentRedirectUrl;
  final String? paymentCode;
  final String? paymentApplicationID;
  final dynamic
  paymentTokenExpiry; // Using dynamic for null values that might change type
  final String? paymentResponseMessage;
final String? paymentToken;
  PaymentInitiationResponse({
    this.status,
    this.paymentId,
    this.paymentRedirectUrl,
    this.paymentCode,
    this.paymentApplicationID,
    this.paymentTokenExpiry,
    this.paymentResponseMessage,this.paymentToken
  });

  factory PaymentInitiationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitiationResponse(
      status: json['status'],
      paymentId: json['paymentId'],
      paymentRedirectUrl: json['paymentRedirectUrl'],
      paymentCode: json['paymentCode'],
       paymentToken: json['paymentToken'],
      paymentApplicationID: json['paymentApplicationID'],
      paymentTokenExpiry: json['paymentTokenExpiry'],
      paymentResponseMessage: json['paymentResponseMessage'],
    );
  }
}

class PurchaseData {
  final int? id;
  final int? userId;
  final int? videoId;
  final String? reference;
  final double? amount;
  final String? paymentMethod;
  final String? status;
  final String? currency;
  final String? createdAt;
  final String? updatedAt;

  PurchaseData({
    this.id,
    this.userId,
    this.videoId,
    this.reference,
    this.amount,
    this.paymentMethod,
    this.status,
    this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) {
    return PurchaseData(
      id: json['id'],
      userId: json['user_id'],
      videoId: json['video_id'],
      reference: json['reference'],
      amount: json['amount']?.toDouble(), // Safely convert int to double
      paymentMethod: json['payment_method'],
      status: json['status'],
      currency: json['currency'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
