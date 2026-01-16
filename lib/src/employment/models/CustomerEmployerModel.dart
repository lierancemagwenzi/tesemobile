/// employerName : "FBC"
/// employerMerchantId : "491723648274438"
/// employmentType : "Part-Time"
/// employmentEmployerLogo : ""
/// employerCurrentPosition : "Manager"
/// employerGrossMonthlyIncome : 1000.0
/// employerNetMonthlyIncome : 800.0
/// employerOtherIncome : 200.0
/// createdAt : "2024-11-11T15:02:48.581+00:00"
/// id : 1

class CustomerEmployerModel {
  CustomerEmployerModel({
      String? employerName, 
      String? employerMerchantId, 
      String? employmentType, 
      String? employmentEmployerLogo, 
      String? employerCurrentPosition, 
      num? employerGrossMonthlyIncome, 
      num? employerNetMonthlyIncome, 
      num? employerOtherIncome, 
      String? createdAt, 
      num? id,}){
    _employerName = employerName;
    _employerMerchantId = employerMerchantId;
    _employmentType = employmentType;
    _employmentEmployerLogo = employmentEmployerLogo;
    _employerCurrentPosition = employerCurrentPosition;
    _employerGrossMonthlyIncome = employerGrossMonthlyIncome;
    _employerNetMonthlyIncome = employerNetMonthlyIncome;
    _employerOtherIncome = employerOtherIncome;
    _createdAt = createdAt;
    _id = id;
}

  CustomerEmployerModel.fromJson(dynamic json) {
    _employerName = json['employerName'];
    _employerMerchantId = json['employerMerchantId'];
    _employmentType = json['employmentType'];
    _employmentEmployerLogo = json['employmentEmployerLogo'];
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
  String? _employmentEmployerLogo;
  String? _employerCurrentPosition;
  num? _employerGrossMonthlyIncome;
  num? _employerNetMonthlyIncome;
  num? _employerOtherIncome;
  String? _createdAt;
  num? _id;
CustomerEmployerModel copyWith({  String? employerName,
  String? employerMerchantId,
  String? employmentType,
  String? employmentEmployerLogo,
  String? employerCurrentPosition,
  num? employerGrossMonthlyIncome,
  num? employerNetMonthlyIncome,
  num? employerOtherIncome,
  String? createdAt,
  num? id,
}) => CustomerEmployerModel(  employerName: employerName ?? _employerName,
  employerMerchantId: employerMerchantId ?? _employerMerchantId,
  employmentType: employmentType ?? _employmentType,
  employmentEmployerLogo: employmentEmployerLogo ?? _employmentEmployerLogo,
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
  String? get employmentEmployerLogo => _employmentEmployerLogo;
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
    map['employmentEmployerLogo'] = _employmentEmployerLogo;
    map['employerCurrentPosition'] = _employerCurrentPosition;
    map['employerGrossMonthlyIncome'] = _employerGrossMonthlyIncome;
    map['employerNetMonthlyIncome'] = _employerNetMonthlyIncome;
    map['employerOtherIncome'] = _employerOtherIncome;
    map['createdAt'] = _createdAt;
    map['id'] = _id;
    return map;
  }

}