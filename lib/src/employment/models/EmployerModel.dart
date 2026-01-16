/// id : 16
/// accountMerchantId : "491723648274438"
/// registeredLegalCompanyName : "PD House"
/// tradingName : "PD House"
/// accountMerchantLogo : "https://www.pdhse.com/wp-content/uploads/2022/08/Logo-plain.png"

class EmployerModel {
  EmployerModel({
      num? id, 
      String? accountMerchantId, 
      String? registeredLegalCompanyName, 
      String? tradingName, 
      String? accountMerchantLogo,}){
    _id = id;
    _accountMerchantId = accountMerchantId;
    _registeredLegalCompanyName = registeredLegalCompanyName;
    _tradingName = tradingName;
    _accountMerchantLogo = accountMerchantLogo;
}

  EmployerModel.fromJson(dynamic json) {
    _id = json['id'];
    _accountMerchantId = json['accountMerchantId'];
    _registeredLegalCompanyName = json['registeredLegalCompanyName'];
    _tradingName = json['tradingName'];
    _accountMerchantLogo = json['accountMerchantLogo'];
  }
  num? _id;
  String? _accountMerchantId;
  String? _registeredLegalCompanyName;
  String? _tradingName;
  String? _accountMerchantLogo;
EmployerModel copyWith({  num? id,
  String? accountMerchantId,
  String? registeredLegalCompanyName,
  String? tradingName,
  String? accountMerchantLogo,
}) => EmployerModel(  id: id ?? _id,
  accountMerchantId: accountMerchantId ?? _accountMerchantId,
  registeredLegalCompanyName: registeredLegalCompanyName ?? _registeredLegalCompanyName,
  tradingName: tradingName ?? _tradingName,
  accountMerchantLogo: accountMerchantLogo ?? _accountMerchantLogo,
);
  num? get id => _id;
  String? get accountMerchantId => _accountMerchantId;
  String? get registeredLegalCompanyName => _registeredLegalCompanyName;
  String? get tradingName => _tradingName;
  String? get accountMerchantLogo => _accountMerchantLogo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['accountMerchantId'] = _accountMerchantId;
    map['registeredLegalCompanyName'] = _registeredLegalCompanyName;
    map['tradingName'] = _tradingName;
    map['accountMerchantLogo'] = _accountMerchantLogo;
    return map;
  }

}