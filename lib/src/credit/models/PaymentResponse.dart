/// auth : {"token":"eyJhbGciOiJFUzI1NiJ9.eyJVc2VySWQiOjMxLCJyb2xlcyI6WyJVU0VSIl0sIm1lcmNoYW50X2lkIjoiMzExNzIyNTA0OTUxMDQ5Iiwic3ViIjoidWRlYW5tYmFubysxMkBnbWFpbC5jb20iLCJpYXQiOjE3NjE4Mjk4NzcsImV4cCI6MTc2MTg0Nzg3N30.__lP6V_f5R4laXS8wGY-qenmaVTcsEoIrETMsW5L-JsSeHKOwMBLXoRMG_QTYBSt8bHLHWI6cZNWbqTA2MVQlg","user":{"id":31,"email":"udeanmbano+12@gmail.com","role":"USER","token":"eyJhbGciOiJFUzI1NiJ9.eyJVc2VySWQiOjMxLCJyb2xlcyI6WyJVU0VSIl0sIm1lcmNoYW50X2lkIjoiMzExNzIyNTA0OTUxMDQ5Iiwic3ViIjoidWRlYW5tYmFubysxMkBnbWFpbC5jb20iLCJpYXQiOjE3NjE4Mjk4NzcsImV4cCI6MTc2MTg0Nzg3N30.__lP6V_f5R4laXS8wGY-qenmaVTcsEoIrETMsW5L-JsSeHKOwMBLXoRMG_QTYBSt8bHLHWI6cZNWbqTA2MVQlg"},"errorResponse":{"errorMessage":"","statusCode":0}}
/// paymentInitiationResponse : {"status":"Success","paymentTokenExpiry":"","paymentTokenDescription":"","paymentToken":"","paymentId":"aa57bdc8-a822-48a8-a5be-f7282b003f4c","paymentRedirectUrl":"https://dev-payments.smatpay.africa/visa-payment?paymentCode=aa57bdc8-a822-48a8-a5be-f7282b003f4c","paymentResponseMessage":"","paymentProcessedDateTime":"","paymentCode":"aa57bdc8-a822-48a8-a5be-f7282b003f4c","paymentQrCode":"","paymentApplicationID":"{6eaa71c9-4b15-4ed1-907d-8a6137a98614}"}

class PaymentResponse {
  PaymentResponse({
      Auth? auth, 
      PaymentInitiationResponse? paymentInitiationResponse,}){
    _auth = auth;
    _paymentInitiationResponse = paymentInitiationResponse;
}

  PaymentResponse.fromJson(dynamic json) {
    _auth = json['auth'] != null ? Auth.fromJson(json['auth']) : null;
    _paymentInitiationResponse = json['paymentInitiationResponse'] != null ? PaymentInitiationResponse.fromJson(json['paymentInitiationResponse']) : null;
  }
  Auth? _auth;
  PaymentInitiationResponse? _paymentInitiationResponse;
PaymentResponse copyWith({  Auth? auth,
  PaymentInitiationResponse? paymentInitiationResponse,
}) => PaymentResponse(  auth: auth ?? _auth,
  paymentInitiationResponse: paymentInitiationResponse ?? _paymentInitiationResponse,
);
  Auth? get auth => _auth;
  PaymentInitiationResponse? get paymentInitiationResponse => _paymentInitiationResponse;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_auth != null) {
      map['auth'] = _auth?.toJson();
    }
    if (_paymentInitiationResponse != null) {
      map['paymentInitiationResponse'] = _paymentInitiationResponse?.toJson();
    }
    return map;
  }

}

/// status : "Success"
/// paymentTokenExpiry : ""
/// paymentTokenDescription : ""
/// paymentToken : ""
/// paymentId : "aa57bdc8-a822-48a8-a5be-f7282b003f4c"
/// paymentRedirectUrl : "https://dev-payments.smatpay.africa/visa-payment?paymentCode=aa57bdc8-a822-48a8-a5be-f7282b003f4c"
/// paymentResponseMessage : ""
/// paymentProcessedDateTime : ""
/// paymentCode : "aa57bdc8-a822-48a8-a5be-f7282b003f4c"
/// paymentQrCode : ""
/// paymentApplicationID : "{6eaa71c9-4b15-4ed1-907d-8a6137a98614}"

class PaymentInitiationResponse {
  PaymentInitiationResponse({
      String? status, 
      String? paymentTokenExpiry, 
      String? paymentTokenDescription, 
      String? paymentToken, 
      String? paymentId, 
      String? paymentRedirectUrl, 
      String? paymentResponseMessage, 
      String? paymentProcessedDateTime, 
      String? paymentCode, 
      String? paymentQrCode, 
      String? paymentApplicationID,}){
    _status = status;
    _paymentTokenExpiry = paymentTokenExpiry;
    _paymentTokenDescription = paymentTokenDescription;
    _paymentToken = paymentToken;
    _paymentId = paymentId;
    _paymentRedirectUrl = paymentRedirectUrl;
    _paymentResponseMessage = paymentResponseMessage;
    _paymentProcessedDateTime = paymentProcessedDateTime;
    _paymentCode = paymentCode;
    _paymentQrCode = paymentQrCode;
    _paymentApplicationID = paymentApplicationID;
}

  PaymentInitiationResponse.fromJson(dynamic json) {
    _status = json['status'];
    _paymentTokenExpiry = json['paymentTokenExpiry'];
    _paymentTokenDescription = json['paymentTokenDescription'];
    _paymentToken = json['paymentToken'];
    _paymentId = json['paymentId'];
    _paymentRedirectUrl = json['paymentRedirectUrl'];
    _paymentResponseMessage = json['paymentResponseMessage'];
    _paymentProcessedDateTime = json['paymentProcessedDateTime'];
    _paymentCode = json['paymentCode'];
    _paymentQrCode = json['paymentQrCode'];
    _paymentApplicationID = json['paymentApplicationID'];
  }
  String? _status;
  String? _paymentTokenExpiry;
  String? _paymentTokenDescription;
  String? _paymentToken;
  String? _paymentId;
  String? _paymentRedirectUrl;
  String? _paymentResponseMessage;
  String? _paymentProcessedDateTime;
  String? _paymentCode;
  String? _paymentQrCode;
  String? _paymentApplicationID;
PaymentInitiationResponse copyWith({  String? status,
  String? paymentTokenExpiry,
  String? paymentTokenDescription,
  String? paymentToken,
  String? paymentId,
  String? paymentRedirectUrl,
  String? paymentResponseMessage,
  String? paymentProcessedDateTime,
  String? paymentCode,
  String? paymentQrCode,
  String? paymentApplicationID,
}) => PaymentInitiationResponse(  status: status ?? _status,
  paymentTokenExpiry: paymentTokenExpiry ?? _paymentTokenExpiry,
  paymentTokenDescription: paymentTokenDescription ?? _paymentTokenDescription,
  paymentToken: paymentToken ?? _paymentToken,
  paymentId: paymentId ?? _paymentId,
  paymentRedirectUrl: paymentRedirectUrl ?? _paymentRedirectUrl,
  paymentResponseMessage: paymentResponseMessage ?? _paymentResponseMessage,
  paymentProcessedDateTime: paymentProcessedDateTime ?? _paymentProcessedDateTime,
  paymentCode: paymentCode ?? _paymentCode,
  paymentQrCode: paymentQrCode ?? _paymentQrCode,
  paymentApplicationID: paymentApplicationID ?? _paymentApplicationID,
);
  String? get status => _status;
  String? get paymentTokenExpiry => _paymentTokenExpiry;
  String? get paymentTokenDescription => _paymentTokenDescription;
  String? get paymentToken => _paymentToken;
  String? get paymentId => _paymentId;
  String? get paymentRedirectUrl => _paymentRedirectUrl;
  String? get paymentResponseMessage => _paymentResponseMessage;
  String? get paymentProcessedDateTime => _paymentProcessedDateTime;
  String? get paymentCode => _paymentCode;
  String? get paymentQrCode => _paymentQrCode;
  String? get paymentApplicationID => _paymentApplicationID;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['paymentTokenExpiry'] = _paymentTokenExpiry;
    map['paymentTokenDescription'] = _paymentTokenDescription;
    map['paymentToken'] = _paymentToken;
    map['paymentId'] = _paymentId;
    map['paymentRedirectUrl'] = _paymentRedirectUrl;
    map['paymentResponseMessage'] = _paymentResponseMessage;
    map['paymentProcessedDateTime'] = _paymentProcessedDateTime;
    map['paymentCode'] = _paymentCode;
    map['paymentQrCode'] = _paymentQrCode;
    map['paymentApplicationID'] = _paymentApplicationID;
    return map;
  }

}

/// token : "eyJhbGciOiJFUzI1NiJ9.eyJVc2VySWQiOjMxLCJyb2xlcyI6WyJVU0VSIl0sIm1lcmNoYW50X2lkIjoiMzExNzIyNTA0OTUxMDQ5Iiwic3ViIjoidWRlYW5tYmFubysxMkBnbWFpbC5jb20iLCJpYXQiOjE3NjE4Mjk4NzcsImV4cCI6MTc2MTg0Nzg3N30.__lP6V_f5R4laXS8wGY-qenmaVTcsEoIrETMsW5L-JsSeHKOwMBLXoRMG_QTYBSt8bHLHWI6cZNWbqTA2MVQlg"
/// user : {"id":31,"email":"udeanmbano+12@gmail.com","role":"USER","token":"eyJhbGciOiJFUzI1NiJ9.eyJVc2VySWQiOjMxLCJyb2xlcyI6WyJVU0VSIl0sIm1lcmNoYW50X2lkIjoiMzExNzIyNTA0OTUxMDQ5Iiwic3ViIjoidWRlYW5tYmFubysxMkBnbWFpbC5jb20iLCJpYXQiOjE3NjE4Mjk4NzcsImV4cCI6MTc2MTg0Nzg3N30.__lP6V_f5R4laXS8wGY-qenmaVTcsEoIrETMsW5L-JsSeHKOwMBLXoRMG_QTYBSt8bHLHWI6cZNWbqTA2MVQlg"}
/// errorResponse : {"errorMessage":"","statusCode":0}

class Auth {
  Auth({
      String? token, 
      User? user, 
      ErrorResponse? errorResponse,}){
    _token = token;
    _user = user;
    _errorResponse = errorResponse;
}

  Auth.fromJson(dynamic json) {
    _token = json['token'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _errorResponse = json['errorResponse'] != null ? ErrorResponse.fromJson(json['errorResponse']) : null;
  }
  String? _token;
  User? _user;
  ErrorResponse? _errorResponse;
Auth copyWith({  String? token,
  User? user,
  ErrorResponse? errorResponse,
}) => Auth(  token: token ?? _token,
  user: user ?? _user,
  errorResponse: errorResponse ?? _errorResponse,
);
  String? get token => _token;
  User? get user => _user;
  ErrorResponse? get errorResponse => _errorResponse;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = _token;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_errorResponse != null) {
      map['errorResponse'] = _errorResponse?.toJson();
    }
    return map;
  }

}

/// errorMessage : ""
/// statusCode : 0

class ErrorResponse {
  ErrorResponse({
      String? errorMessage, 
      num? statusCode,}){
    _errorMessage = errorMessage;
    _statusCode = statusCode;
}

  ErrorResponse.fromJson(dynamic json) {
    _errorMessage = json['errorMessage'];
    _statusCode = json['statusCode'];
  }
  String? _errorMessage;
  num? _statusCode;
ErrorResponse copyWith({  String? errorMessage,
  num? statusCode,
}) => ErrorResponse(  errorMessage: errorMessage ?? _errorMessage,
  statusCode: statusCode ?? _statusCode,
);
  String? get errorMessage => _errorMessage;
  num? get statusCode => _statusCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['errorMessage'] = _errorMessage;
    map['statusCode'] = _statusCode;
    return map;
  }

}

/// id : 31
/// email : "udeanmbano+12@gmail.com"
/// role : "USER"
/// token : "eyJhbGciOiJFUzI1NiJ9.eyJVc2VySWQiOjMxLCJyb2xlcyI6WyJVU0VSIl0sIm1lcmNoYW50X2lkIjoiMzExNzIyNTA0OTUxMDQ5Iiwic3ViIjoidWRlYW5tYmFubysxMkBnbWFpbC5jb20iLCJpYXQiOjE3NjE4Mjk4NzcsImV4cCI6MTc2MTg0Nzg3N30.__lP6V_f5R4laXS8wGY-qenmaVTcsEoIrETMsW5L-JsSeHKOwMBLXoRMG_QTYBSt8bHLHWI6cZNWbqTA2MVQlg"

class User {
  User({
      num? id, 
      String? email, 
      String? role, 
      String? token,}){
    _id = id;
    _email = email;
    _role = role;
    _token = token;
}

  User.fromJson(dynamic json) {
    _id = json['id'];
    _email = json['email'];
    _role = json['role'];
    _token = json['token'];
  }
  num? _id;
  String? _email;
  String? _role;
  String? _token;
User copyWith({  num? id,
  String? email,
  String? role,
  String? token,
}) => User(  id: id ?? _id,
  email: email ?? _email,
  role: role ?? _role,
  token: token ?? _token,
);
  num? get id => _id;
  String? get email => _email;
  String? get role => _role;
  String? get token => _token;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['email'] = _email;
    map['role'] = _role;
    map['token'] = _token;
    return map;
  }

}