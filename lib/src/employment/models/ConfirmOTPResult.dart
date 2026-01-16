/// status : "SUCCESS"
/// data : null
/// message : "Application verified"

class ConfirmOtpResult {
  ConfirmOtpResult({
      String? status, 
      dynamic data, 
      String? message,}){
    _status = status;
    _data = data;
    _message = message;
}

  ConfirmOtpResult.fromJson(dynamic json) {
    _status = json['status'];
    _data = json['data'];
    _message = json['message'];
  }
  String? _status;
  dynamic _data;
  String? _message;
ConfirmOtpResult copyWith({  String? status,
  dynamic data,
  String? message,
}) => ConfirmOtpResult(  status: status ?? _status,
  data: data ?? _data,
  message: message ?? _message,
);
  String? get status => _status;
  dynamic get data => _data;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['data'] = _data;
    map['message'] = _message;
    return map;
  }

}