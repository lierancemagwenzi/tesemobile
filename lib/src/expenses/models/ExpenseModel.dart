/// userExpenseHousingCosts : 1.0
/// userExpenseUtilitiesCosts : 1.0
/// userExpenseDebtPaymentsCosts : 1.0
/// userExpenseLivingExpensesCosts : 1.0
/// userExpenseSavingInvestmentsCosts : 1.0
/// createdAt : ""
/// id : 1

class ExpenseModel {
  ExpenseModel({
      num? userExpenseHousingCosts, 
      num? userExpenseUtilitiesCosts, 
      num? userExpenseDebtPaymentsCosts, 
      num? userExpenseLivingExpensesCosts, 
      num? userExpenseSavingInvestmentsCosts, 
      String? createdAt,
    num? userExpenseOtherCosts,
      num? id,}){
    _userExpenseHousingCosts = userExpenseHousingCosts;
    _userExpenseUtilitiesCosts = userExpenseUtilitiesCosts;
    _userExpenseDebtPaymentsCosts = userExpenseDebtPaymentsCosts;
    _userExpenseLivingExpensesCosts = userExpenseLivingExpensesCosts;
    _userExpenseSavingInvestmentsCosts = userExpenseSavingInvestmentsCosts;
    _createdAt = createdAt;
    _userExpenseOtherCosts=userExpenseOtherCosts;
    _id = id;
}

  ExpenseModel.fromJson(dynamic json) {
    _userExpenseHousingCosts = json['userExpenseHousingCosts'];
    _userExpenseUtilitiesCosts = json['userExpenseUtilitiesCosts'];
    _userExpenseDebtPaymentsCosts = json['userExpenseDebtPaymentsCosts'];
    _userExpenseLivingExpensesCosts = json['userExpenseLivingExpensesCosts'];
    _userExpenseSavingInvestmentsCosts = json['userExpenseSavingInvestmentsCosts'];
    _createdAt = json['createdAt'];
    _userExpenseOtherCosts=json['userExpenseOtherCosts'];
    _id = json['id'];
  }
  num? _userExpenseHousingCosts;
  num? _userExpenseUtilitiesCosts;
  num? _userExpenseDebtPaymentsCosts;
  num? _userExpenseLivingExpensesCosts;
  num? _userExpenseSavingInvestmentsCosts;
  String? _createdAt;
  num? _id;

  num ? _userExpenseOtherCosts;
ExpenseModel copyWith({  num? userExpenseHousingCosts,
  num? userExpenseUtilitiesCosts,
  num? userExpenseDebtPaymentsCosts,
  num? userExpenseLivingExpensesCosts,
  num? userExpenseSavingInvestmentsCosts,
  String? createdAt,
  num? id,
}) => ExpenseModel(  userExpenseHousingCosts: userExpenseHousingCosts ?? _userExpenseHousingCosts,
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
  num? get userExpenseOtherCosts => _userExpenseOtherCosts;

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
    map['userExpenseOtherCosts'] = _userExpenseOtherCosts;


    map['id'] = _id;
    return map;
  }

}