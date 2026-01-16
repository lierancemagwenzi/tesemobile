class VerifyIDModel {
  VerifyIDModel({bool? canProceed, num? result, String? message}) {
    _canProceed = canProceed;
    _result = result;
    _message = message;
  }

  VerifyIDModel.fromJson(dynamic json) {
    _canProceed = json['canProceed'];
    _result = json['result'];
    _message = json['message'];
  }
  bool? _canProceed;
  num? _result;
  String? _message;

  bool? get canProceed => _canProceed;
  dynamic get data => _result;
  String? get message => _message;
}
