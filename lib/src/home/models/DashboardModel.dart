/// status : "Success"
/// data : {"creditLines":50,"statusOfProofOfResidence":true,"profileCompletionLevel":75.0,"accountStatus":"Not active","totalExposures":65.0,"disposableIncomeRemaining":803.0}
/// message : ""

class DashboardModel {
  DashboardModel({
      String? status, 
      Data? data, 
      String? message,}){
    _status = status;
    _data = data;
    _message = message;
}

  DashboardModel.fromJson(dynamic json) {
    _status = json['status'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _message = json['message'];
  }
  String? _status;
  Data? _data;
  String? _message;
DashboardModel copyWith({  String? status,
  Data? data,
  String? message,
}) => DashboardModel(  status: status ?? _status,
  data: data ?? _data,
  message: message ?? _message,
);
  String? get status => _status;
  Data? get data => _data;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    map['message'] = _message;
    return map;
  }

}

/// creditLines : 50
/// statusOfProofOfResidence : true
/// profileCompletionLevel : 75.0
/// accountStatus : "Not active"
/// totalExposures : 65.0
/// disposableIncomeRemaining : 803.0

class Data {
  Data({
      num? creditLines, 
      bool? statusOfProofOfResidence, 
      num? profileCompletionLevel, 
      String? accountStatus, 
      num? totalExposures, 
      num? disposableIncomeRemaining,}){
    _creditLines = creditLines;
    _statusOfProofOfResidence = statusOfProofOfResidence;
    _profileCompletionLevel = profileCompletionLevel;
    _accountStatus = accountStatus;
    _totalExposures = totalExposures;
    _disposableIncomeRemaining = disposableIncomeRemaining;
}

  Data.fromJson(dynamic json) {
    _creditLines = json['creditLines'];
    _statusOfProofOfResidence = json['statusOfProofOfResidence'];
    _profileCompletionLevel = json['profileCompletionLevel'];
    _accountStatus = json['accountStatus'];
    _totalExposures = json['totalExposures'];
    _disposableIncomeRemaining = json['disposableIncomeRemaining'];
  }
  num? _creditLines;
  bool? _statusOfProofOfResidence;
  num? _profileCompletionLevel;
  String? _accountStatus;
  num? _totalExposures;
  num? _disposableIncomeRemaining;
Data copyWith({  num? creditLines,
  bool? statusOfProofOfResidence,
  num? profileCompletionLevel,
  String? accountStatus,
  num? totalExposures,
  num? disposableIncomeRemaining,
}) => Data(  creditLines: creditLines ?? _creditLines,
  statusOfProofOfResidence: statusOfProofOfResidence ?? _statusOfProofOfResidence,
  profileCompletionLevel: profileCompletionLevel ?? _profileCompletionLevel,
  accountStatus: accountStatus ?? _accountStatus,
  totalExposures: totalExposures ?? _totalExposures,
  disposableIncomeRemaining: disposableIncomeRemaining ?? _disposableIncomeRemaining,
);
  num? get creditLines => _creditLines;
  bool? get statusOfProofOfResidence => _statusOfProofOfResidence;
  num? get profileCompletionLevel => _profileCompletionLevel;
  String? get accountStatus => _accountStatus;
  num? get totalExposures => _totalExposures;
  num? get disposableIncomeRemaining => _disposableIncomeRemaining;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['creditLines'] = _creditLines;
    map['statusOfProofOfResidence'] = _statusOfProofOfResidence;
    map['profileCompletionLevel'] = _profileCompletionLevel;
    map['accountStatus'] = _accountStatus;
    map['totalExposures'] = _totalExposures;
    map['disposableIncomeRemaining'] = _disposableIncomeRemaining;
    return map;
  }

}