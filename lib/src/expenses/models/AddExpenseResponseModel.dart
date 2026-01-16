/// status : "Success"
/// data : {"userExpenseHousingCosts":1.0,"userExpenseUtilitiesCosts":1.0,"userExpenseDebtPaymentsCosts":1.0,"userExpenseLivingExpensesCosts":1.0,"userExpenseSavingInvestmentsCosts":1.0,"createdAt":"2024-11-10T09:59:26.056+00:00","id":1}
/// message : "Expense created successfully"

class AddExpenseResponseModel {
  AddExpenseResponseModel({
      String? status, 
      Data? data, 
      String? message,}){
    _status = status;
    _data = data;
    _message = message;
}

  AddExpenseResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _message = json['message'];
  }
  String? _status;
  Data? _data;
  String? _message;
AddExpenseResponseModel copyWith({  String? status,
  Data? data,
  String? message,
}) => AddExpenseResponseModel(  status: status ?? _status,
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

/// userExpenseHousingCosts : 1.0
/// userExpenseUtilitiesCosts : 1.0
/// userExpenseDebtPaymentsCosts : 1.0
/// userExpenseLivingExpensesCosts : 1.0
/// userExpenseSavingInvestmentsCosts : 1.0
/// createdAt : "2024-11-10T09:59:26.056+00:00"
/// id : 1

class Data {
  Data({
      num? userExpenseHousingCosts, 
      num? userExpenseUtilitiesCosts, 
      num? userExpenseDebtPaymentsCosts, 
      num? userExpenseLivingExpensesCosts, 
      num? userExpenseSavingInvestmentsCosts, 
      String? createdAt, 
      num? id,}){
    _userExpenseHousingCosts = userExpenseHousingCosts;
    _userExpenseUtilitiesCosts = userExpenseUtilitiesCosts;
    _userExpenseDebtPaymentsCosts = userExpenseDebtPaymentsCosts;
    _userExpenseLivingExpensesCosts = userExpenseLivingExpensesCosts;
    _userExpenseSavingInvestmentsCosts = userExpenseSavingInvestmentsCosts;
    _createdAt = createdAt;
    _id = id;
}

  Data.fromJson(dynamic json) {
    _userExpenseHousingCosts = json['userExpenseHousingCosts'];
    _userExpenseUtilitiesCosts = json['userExpenseUtilitiesCosts'];
    _userExpenseDebtPaymentsCosts = json['userExpenseDebtPaymentsCosts'];
    _userExpenseLivingExpensesCosts = json['userExpenseLivingExpensesCosts'];
    _userExpenseSavingInvestmentsCosts = json['userExpenseSavingInvestmentsCosts'];
    _createdAt = json['createdAt'];
    _id = json['id'];
  }
  num? _userExpenseHousingCosts;
  num? _userExpenseUtilitiesCosts;
  num? _userExpenseDebtPaymentsCosts;
  num? _userExpenseLivingExpensesCosts;
  num? _userExpenseSavingInvestmentsCosts;
  String? _createdAt;
  num? _id;
Data copyWith({  num? userExpenseHousingCosts,
  num? userExpenseUtilitiesCosts,
  num? userExpenseDebtPaymentsCosts,
  num? userExpenseLivingExpensesCosts,
  num? userExpenseSavingInvestmentsCosts,
  String? createdAt,
  num? id,
}) => Data(  userExpenseHousingCosts: userExpenseHousingCosts ?? _userExpenseHousingCosts,
  userExpenseUtilitiesCosts: userExpenseUtilitiesCosts ?? _userExpenseUtilitiesCosts,
  userExpenseDebtPaymentsCosts: userExpenseDebtPaymentsCosts ?? _userExpenseDebtPaymentsCosts,
  userExpenseLivingExpensesCosts: userExpenseLivingExpensesCosts ?? _userExpenseLivingExpensesCosts,
  userExpenseSavingInvestmentsCosts: userExpenseSavingInvestmentsCosts ?? _userExpenseSavingInvestmentsCosts,
  createdAt: createdAt ?? _createdAt,
  id: id ?? _id,
);
  num? get userExpenseHousingCosts => _userExpenseHousingCosts;
  num? get userExpenseUtilitiesCosts => _userExpenseUtilitiesCosts;
  num? get userExpenseDebtPaymentsCosts => _userExpenseDebtPaymentsCosts;
  num? get userExpenseLivingExpensesCosts => _userExpenseLivingExpensesCosts;
  num? get userExpenseSavingInvestmentsCosts => _userExpenseSavingInvestmentsCosts;
  String? get createdAt => _createdAt;
  num? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userExpenseHousingCosts'] = _userExpenseHousingCosts;
    map['userExpenseUtilitiesCosts'] = _userExpenseUtilitiesCosts;
    map['userExpenseDebtPaymentsCosts'] = _userExpenseDebtPaymentsCosts;
    map['userExpenseLivingExpensesCosts'] = _userExpenseLivingExpensesCosts;
    map['userExpenseSavingInvestmentsCosts'] = _userExpenseSavingInvestmentsCosts;
    map['createdAt'] = _createdAt;
    map['id'] = _id;
    return map;
  }

}