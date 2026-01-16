/// status : "Success"
/// data : {"employerName":"FBC","employerMerchantId":"491723648274438","employmentType":"Part-Time","employerCurrentPosition":"Manager","employerGrossMonthlyIncome":1000.0,"employerNetMonthlyIncome":800.0,"employerOtherIncome":200.0,"createdAt":"2024-11-11T15:02:48.581+00:00","id":1}

class AddEmploymentResponseModel {
  AddEmploymentResponseModel({
      String? status, 
      Data? data,}){
    _status = status;
    _data = data;
}

  AddEmploymentResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? _status;
  Data? _data;
AddEmploymentResponseModel copyWith({  String? status,
  Data? data,
}) => AddEmploymentResponseModel(  status: status ?? _status,
  data: data ?? _data,
);
  String? get status => _status;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// employerName : "FBC"
/// employerMerchantId : "491723648274438"
/// employmentType : "Part-Time"
/// employerCurrentPosition : "Manager"
/// employerGrossMonthlyIncome : 1000.0
/// employerNetMonthlyIncome : 800.0
/// employerOtherIncome : 200.0
/// createdAt : "2024-11-11T15:02:48.581+00:00"
/// id : 1

class Data {
  Data({
      String? employerName, 
      String? employerMerchantId, 
      String? employmentType, 
      String? employerCurrentPosition, 
      num? employerGrossMonthlyIncome, 
      num? employerNetMonthlyIncome, 
      num? employerOtherIncome, 
      String? createdAt, 
      num? id,}){
    _employerName = employerName;
    _employerMerchantId = employerMerchantId;
    _employmentType = employmentType;
    _employerCurrentPosition = employerCurrentPosition;
    _employerGrossMonthlyIncome = employerGrossMonthlyIncome;
    _employerNetMonthlyIncome = employerNetMonthlyIncome;
    _employerOtherIncome = employerOtherIncome;
    _createdAt = createdAt;
    _id = id;
}

  Data.fromJson(dynamic json) {
    _employerName = json['employerName'];
    _employerMerchantId = json['employerMerchantId'];
    _employmentType = json['employmentType'];
    _employerCurrentPosition = json['employerCurrentPosition'];
    _employerGrossMonthlyIncome = json['employerGrossMonthlyIncome'];
    _employerNetMonthlyIncome = json['employerNetMonthlyIncome'];
    _employerOtherIncome = json['employerOtherIncome'];
    _createdAt = json['createdAt'];
    _id = json['id'];
  }
  String? _employerName;
  String? _employerMerchantId;
  String? _employmentType;
  String? _employerCurrentPosition;
  num? _employerGrossMonthlyIncome;
  num? _employerNetMonthlyIncome;
  num? _employerOtherIncome;
  String? _createdAt;
  num? _id;
Data copyWith({  String? employerName,
  String? employerMerchantId,
  String? employmentType,
  String? employerCurrentPosition,
  num? employerGrossMonthlyIncome,
  num? employerNetMonthlyIncome,
  num? employerOtherIncome,
  String? createdAt,
  num? id,
}) => Data(  employerName: employerName ?? _employerName,
  employerMerchantId: employerMerchantId ?? _employerMerchantId,
  employmentType: employmentType ?? _employmentType,
  employerCurrentPosition: employerCurrentPosition ?? _employerCurrentPosition,
  employerGrossMonthlyIncome: employerGrossMonthlyIncome ?? _employerGrossMonthlyIncome,
  employerNetMonthlyIncome: employerNetMonthlyIncome ?? _employerNetMonthlyIncome,
  employerOtherIncome: employerOtherIncome ?? _employerOtherIncome,
  createdAt: createdAt ?? _createdAt,
  id: id ?? _id,
);
  String? get employerName => _employerName;
  String? get employerMerchantId => _employerMerchantId;
  String? get employmentType => _employmentType;
  String? get employerCurrentPosition => _employerCurrentPosition;
  num? get employerGrossMonthlyIncome => _employerGrossMonthlyIncome;
  num? get employerNetMonthlyIncome => _employerNetMonthlyIncome;
  num? get employerOtherIncome => _employerOtherIncome;
  String? get createdAt => _createdAt;
  num? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['employerName'] = _employerName;
    map['employerMerchantId'] = _employerMerchantId;
    map['employmentType'] = _employmentType;
    map['employerCurrentPosition'] = _employerCurrentPosition;
    map['employerGrossMonthlyIncome'] = _employerGrossMonthlyIncome;
    map['employerNetMonthlyIncome'] = _employerNetMonthlyIncome;
    map['employerOtherIncome'] = _employerOtherIncome;
    map['createdAt'] = _createdAt;
    map['id'] = _id;
    return map;
  }

}