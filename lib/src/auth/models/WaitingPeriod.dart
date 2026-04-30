class WaitingPeriodModel {
  WaitingPeriodModel({bool? status, String? message}) {
    _status = status;
    _message = message;
  }

  WaitingPeriodModel.fromJson(dynamic json) {
    _status = json['waiting_period'];
    _message = json['message'];
  }
  bool? _status;
  String? _message;

  bool? get status => _status;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    return map;
  }
}
