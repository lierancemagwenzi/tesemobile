/// id : 5
/// productName : "SmatCredit"
/// productValue : 5.0
/// depositValue : 10.0
/// repaymentPeriod : 5
/// insuranceFee : 1.0
/// platformFeePercent : 2.0
/// platformFeeFixed : 1.0
/// interestFeePercent : 5.0
/// interestFeeFixed : 1.0
/// monthlyRepaymentAmount : 1.0
/// totalRepaymentAmount : 8.8721603125
/// adminFees : 1.15
/// outstandingBalanceAmount : -5.505660312500001
/// paidRepaymentAmount : 10.5056603125
/// depositAndAdminAmount : 1.65
/// applicationVerified : true
/// applicationVerifiedDate : "2025-10-16T12:12:18.396+00:00"
/// applicationVerifiedOTP : 722353
/// creditApplicationReference : "CRD-20251016-3AF709"
/// creditApplicationStatus : "APPROVED"
/// creditApplicationGlobalToken : "FYAtgzd56oXrSykZWsXTgG1kPWqt5Plj-665"
/// creditApplicationUpfrontPaymentStatus : "PENDING"
/// creditApplicationUpfrontPaymentLink : "https://dev-payments.smatpay.africa/global?token=S7v09fGTUcJqckkU_RXSdqccaipfjOpT-674"
/// installmentSchedule : [{"id":5,"title":"5 month ($5.0)","paymentNumber":5,"dueDate":"2026-02-15T22:00:00.000+00:00","amount":1.8154915625,"description":"Fifth Payment (16 February 2026)","creditReference":"CRD-20251016-3AF709-5","creditPaymentStatus":"PENDING"}]

class CreditApplication {
  CreditApplication({
      num? id, 
      String? productName, 
      num? productValue, 
      num? depositValue, 
      num? repaymentPeriod, 
      num? insuranceFee, 
      num? platformFeePercent, 
      num? platformFeeFixed, 
      num? interestFeePercent, 
      num? interestFeeFixed, 
      num? monthlyRepaymentAmount, 
      num? totalRepaymentAmount, 
      num? adminFees, 
      num? outstandingBalanceAmount, 
      num? paidRepaymentAmount, 
      num? depositAndAdminAmount, 
      bool? applicationVerified, 
      String? applicationVerifiedDate, 
      num? applicationVerifiedOTP, 
      String? creditApplicationReference, 
      String? creditApplicationStatus, 
      String? creditApplicationGlobalToken, 
      String? creditApplicationUpfrontPaymentStatus, 
      String? creditApplicationUpfrontPaymentLink, 
      List<InstallmentSchedule>? installmentSchedule,}){
    _id = id;
    _productName = productName;
    _productValue = productValue;
    _depositValue = depositValue;
    _repaymentPeriod = repaymentPeriod;
    _insuranceFee = insuranceFee;
    _platformFeePercent = platformFeePercent;
    _platformFeeFixed = platformFeeFixed;
    _interestFeePercent = interestFeePercent;
    _interestFeeFixed = interestFeeFixed;
    _monthlyRepaymentAmount = monthlyRepaymentAmount;
    _totalRepaymentAmount = totalRepaymentAmount;
    _adminFees = adminFees;
    _outstandingBalanceAmount = outstandingBalanceAmount;
    _paidRepaymentAmount = paidRepaymentAmount;
    _depositAndAdminAmount = depositAndAdminAmount;
    _applicationVerified = applicationVerified;
    _applicationVerifiedDate = applicationVerifiedDate;
    _applicationVerifiedOTP = applicationVerifiedOTP;
    _creditApplicationReference = creditApplicationReference;
    _creditApplicationStatus = creditApplicationStatus;
    _creditApplicationGlobalToken = creditApplicationGlobalToken;
    _creditApplicationUpfrontPaymentStatus = creditApplicationUpfrontPaymentStatus;
    _creditApplicationUpfrontPaymentLink = creditApplicationUpfrontPaymentLink;
    _installmentSchedule = installmentSchedule;
}

  CreditApplication.fromJson(dynamic json) {
    _id = json['id'];
    _productName = json['productName'];
    _productValue = json['productValue'];
    _depositValue = json['depositValue'];
    _repaymentPeriod = json['repaymentPeriod'];
    _insuranceFee = json['insuranceFee'];
    _platformFeePercent = json['platformFeePercent'];
    _platformFeeFixed = json['platformFeeFixed'];
    _interestFeePercent = json['interestFeePercent'];
    _interestFeeFixed = json['interestFeeFixed'];
    _monthlyRepaymentAmount = json['monthlyRepaymentAmount'];
    _totalRepaymentAmount = json['totalRepaymentAmount'];
    _adminFees = json['adminFees'];
    _outstandingBalanceAmount = json['outstandingBalanceAmount'];
    _paidRepaymentAmount = json['paidRepaymentAmount'];
    _depositAndAdminAmount = json['depositAndAdminAmount'];
    _applicationVerified = json['applicationVerified'];
    _applicationVerifiedDate = json['applicationVerifiedDate'];
    _applicationVerifiedOTP = json['applicationVerifiedOTP'];
    _creditApplicationReference = json['creditApplicationReference'];
    _creditApplicationStatus = json['creditApplicationStatus'];
    _creditApplicationGlobalToken = json['creditApplicationGlobalToken'];
    _creditApplicationUpfrontPaymentStatus = json['creditApplicationUpfrontPaymentStatus'];
    _creditApplicationUpfrontPaymentLink = json['creditApplicationUpfrontPaymentLink'];
    if (json['installmentSchedule'] != null) {
      _installmentSchedule = [];
      json['installmentSchedule'].forEach((v) {
        _installmentSchedule?.add(InstallmentSchedule.fromJson(v));
      });
    }
  }
  num? _id;
  String? _productName;
  num? _productValue;
  num? _depositValue;
  num? _repaymentPeriod;
  num? _insuranceFee;
  num? _platformFeePercent;
  num? _platformFeeFixed;
  num? _interestFeePercent;
  num? _interestFeeFixed;
  num? _monthlyRepaymentAmount;
  num? _totalRepaymentAmount;
  num? _adminFees;
  num? _outstandingBalanceAmount;
  num? _paidRepaymentAmount;
  num? _depositAndAdminAmount;
  bool? _applicationVerified;
  String? _applicationVerifiedDate;
  num? _applicationVerifiedOTP;
  String? _creditApplicationReference;
  String? _creditApplicationStatus;
  String? _creditApplicationGlobalToken;
  String? _creditApplicationUpfrontPaymentStatus;
  String? _creditApplicationUpfrontPaymentLink;
  List<InstallmentSchedule>? _installmentSchedule;
CreditApplication copyWith({  num? id,
  String? productName,
  num? productValue,
  num? depositValue,
  num? repaymentPeriod,
  num? insuranceFee,
  num? platformFeePercent,
  num? platformFeeFixed,
  num? interestFeePercent,
  num? interestFeeFixed,
  num? monthlyRepaymentAmount,
  num? totalRepaymentAmount,
  num? adminFees,
  num? outstandingBalanceAmount,
  num? paidRepaymentAmount,
  num? depositAndAdminAmount,
  bool? applicationVerified,
  String? applicationVerifiedDate,
  num? applicationVerifiedOTP,
  String? creditApplicationReference,
  String? creditApplicationStatus,
  String? creditApplicationGlobalToken,
  String? creditApplicationUpfrontPaymentStatus,
  String? creditApplicationUpfrontPaymentLink,
  List<InstallmentSchedule>? installmentSchedule,
}) => CreditApplication(  id: id ?? _id,
  productName: productName ?? _productName,
  productValue: productValue ?? _productValue,
  depositValue: depositValue ?? _depositValue,
  repaymentPeriod: repaymentPeriod ?? _repaymentPeriod,
  insuranceFee: insuranceFee ?? _insuranceFee,
  platformFeePercent: platformFeePercent ?? _platformFeePercent,
  platformFeeFixed: platformFeeFixed ?? _platformFeeFixed,
  interestFeePercent: interestFeePercent ?? _interestFeePercent,
  interestFeeFixed: interestFeeFixed ?? _interestFeeFixed,
  monthlyRepaymentAmount: monthlyRepaymentAmount ?? _monthlyRepaymentAmount,
  totalRepaymentAmount: totalRepaymentAmount ?? _totalRepaymentAmount,
  adminFees: adminFees ?? _adminFees,
  outstandingBalanceAmount: outstandingBalanceAmount ?? _outstandingBalanceAmount,
  paidRepaymentAmount: paidRepaymentAmount ?? _paidRepaymentAmount,
  depositAndAdminAmount: depositAndAdminAmount ?? _depositAndAdminAmount,
  applicationVerified: applicationVerified ?? _applicationVerified,
  applicationVerifiedDate: applicationVerifiedDate ?? _applicationVerifiedDate,
  applicationVerifiedOTP: applicationVerifiedOTP ?? _applicationVerifiedOTP,
  creditApplicationReference: creditApplicationReference ?? _creditApplicationReference,
  creditApplicationStatus: creditApplicationStatus ?? _creditApplicationStatus,
  creditApplicationGlobalToken: creditApplicationGlobalToken ?? _creditApplicationGlobalToken,
  creditApplicationUpfrontPaymentStatus: creditApplicationUpfrontPaymentStatus ?? _creditApplicationUpfrontPaymentStatus,
  creditApplicationUpfrontPaymentLink: creditApplicationUpfrontPaymentLink ?? _creditApplicationUpfrontPaymentLink,
  installmentSchedule: installmentSchedule ?? _installmentSchedule,
);
  num? get id => _id;
  String? get productName => _productName;
  num? get productValue => _productValue;
  num? get depositValue => _depositValue;
  num? get repaymentPeriod => _repaymentPeriod;
  num? get insuranceFee => _insuranceFee;
  num? get platformFeePercent => _platformFeePercent;
  num? get platformFeeFixed => _platformFeeFixed;
  num? get interestFeePercent => _interestFeePercent;
  num? get interestFeeFixed => _interestFeeFixed;
  num? get monthlyRepaymentAmount => _monthlyRepaymentAmount;
  num? get totalRepaymentAmount => _totalRepaymentAmount;
  num? get adminFees => _adminFees;
  num? get outstandingBalanceAmount => _outstandingBalanceAmount;
  num? get paidRepaymentAmount => _paidRepaymentAmount;
  num? get depositAndAdminAmount => _depositAndAdminAmount;
  bool? get applicationVerified => _applicationVerified;
  String? get applicationVerifiedDate => _applicationVerifiedDate;
  num? get applicationVerifiedOTP => _applicationVerifiedOTP;
  String? get creditApplicationReference => _creditApplicationReference;
  String? get creditApplicationStatus => _creditApplicationStatus;
  String? get creditApplicationGlobalToken => _creditApplicationGlobalToken;
  String? get creditApplicationUpfrontPaymentStatus => _creditApplicationUpfrontPaymentStatus;
  String? get creditApplicationUpfrontPaymentLink => _creditApplicationUpfrontPaymentLink;
  List<InstallmentSchedule>? get installmentSchedule => _installmentSchedule;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['productName'] = _productName;
    map['productValue'] = _productValue;
    map['depositValue'] = _depositValue;
    map['repaymentPeriod'] = _repaymentPeriod;
    map['insuranceFee'] = _insuranceFee;
    map['platformFeePercent'] = _platformFeePercent;
    map['platformFeeFixed'] = _platformFeeFixed;
    map['interestFeePercent'] = _interestFeePercent;
    map['interestFeeFixed'] = _interestFeeFixed;
    map['monthlyRepaymentAmount'] = _monthlyRepaymentAmount;
    map['totalRepaymentAmount'] = _totalRepaymentAmount;
    map['adminFees'] = _adminFees;
    map['outstandingBalanceAmount'] = _outstandingBalanceAmount;
    map['paidRepaymentAmount'] = _paidRepaymentAmount;
    map['depositAndAdminAmount'] = _depositAndAdminAmount;
    map['applicationVerified'] = _applicationVerified;
    map['applicationVerifiedDate'] = _applicationVerifiedDate;
    map['applicationVerifiedOTP'] = _applicationVerifiedOTP;
    map['creditApplicationReference'] = _creditApplicationReference;
    map['creditApplicationStatus'] = _creditApplicationStatus;
    map['creditApplicationGlobalToken'] = _creditApplicationGlobalToken;
    map['creditApplicationUpfrontPaymentStatus'] = _creditApplicationUpfrontPaymentStatus;
    map['creditApplicationUpfrontPaymentLink'] = _creditApplicationUpfrontPaymentLink;
    if (_installmentSchedule != null) {
      map['installmentSchedule'] = _installmentSchedule?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 5
/// title : "5 month ($5.0)"
/// paymentNumber : 5
/// dueDate : "2026-02-15T22:00:00.000+00:00"
/// amount : 1.8154915625
/// description : "Fifth Payment (16 February 2026)"
/// creditReference : "CRD-20251016-3AF709-5"
/// creditPaymentStatus : "PENDING"

class InstallmentSchedule {
  InstallmentSchedule({
      num? id, 
      String? title, 
      num? paymentNumber, 
      String? dueDate, 
      num? amount, 
      String? description, 
      String? creditReference, 
      String? creditPaymentStatus,}){
    _id = id;
    _title = title;
    _paymentNumber = paymentNumber;
    _dueDate = dueDate;
    _amount = amount;
    _description = description;
    _creditReference = creditReference;
    _creditPaymentStatus = creditPaymentStatus;
}

  InstallmentSchedule.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _paymentNumber = json['paymentNumber'];
    _dueDate = json['dueDate'];
    _amount = json['amount'];
    _description = json['description'];
    _creditReference = json['creditReference'];
    _creditPaymentStatus = json['creditPaymentStatus'];
  }
  num? _id;
  String? _title;
  num? _paymentNumber;
  String? _dueDate;
  num? _amount;
  String? _description;
  String? _creditReference;
  String? _creditPaymentStatus;
InstallmentSchedule copyWith({  num? id,
  String? title,
  num? paymentNumber,
  String? dueDate,
  num? amount,
  String? description,
  String? creditReference,
  String? creditPaymentStatus,
}) => InstallmentSchedule(  id: id ?? _id,
  title: title ?? _title,
  paymentNumber: paymentNumber ?? _paymentNumber,
  dueDate: dueDate ?? _dueDate,
  amount: amount ?? _amount,
  description: description ?? _description,
  creditReference: creditReference ?? _creditReference,
  creditPaymentStatus: creditPaymentStatus ?? _creditPaymentStatus,
);
  num? get id => _id;
  String? get title => _title;
  num? get paymentNumber => _paymentNumber;
  String? get dueDate => _dueDate;
  num? get amount => _amount;
  String? get description => _description;
  String? get creditReference => _creditReference;
  String? get creditPaymentStatus => _creditPaymentStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['paymentNumber'] = _paymentNumber;
    map['dueDate'] = _dueDate;
    map['amount'] = _amount;
    map['description'] = _description;
    map['creditReference'] = _creditReference;
    map['creditPaymentStatus'] = _creditPaymentStatus;
    return map;
  }

}