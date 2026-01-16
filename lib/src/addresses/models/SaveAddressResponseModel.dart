/// status : "Success"
/// data : {"addressLineOne":"1 estelle road paulshof","addressLineTwo":"sandton","createdAt":"2024-11-11T15:43:39.018+00:00","id":1}
/// message : "Address created successfully"

class SaveAddressResponseModel {
  SaveAddressResponseModel({
      String? status, 
      Data? data, 
      String? message,}){
    _status = status;
    _data = data;
    _message = message;
}

  SaveAddressResponseModel.fromJson(dynamic json) {
    _status = json['status'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _message = json['message'];
  }
  String? _status;
  Data? _data;
  String? _message;
SaveAddressResponseModel copyWith({  String? status,
  Data? data,
  String? message,
}) => SaveAddressResponseModel(  status: status ?? _status,
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

/// addressLineOne : "1 estelle road paulshof"
/// addressLineTwo : "sandton"
/// createdAt : "2024-11-11T15:43:39.018+00:00"
/// id : 1

class Data {
  Data({
      String? addressLineOne, 
      String? addressLineTwo, 
      String? createdAt, 
      num? id,}){
    _addressLineOne = addressLineOne;
    _addressLineTwo = addressLineTwo;
    _createdAt = createdAt;
    _id = id;
}

  Data.fromJson(dynamic json) {
    _addressLineOne = json['addressLineOne'];
    _addressLineTwo = json['addressLineTwo'];
    _createdAt = json['createdAt'];
    _id = json['id'];
  }
  String? _addressLineOne;
  String? _addressLineTwo;
  String? _createdAt;
  num? _id;
Data copyWith({  String? addressLineOne,
  String? addressLineTwo,
  String? createdAt,
  num? id,
}) => Data(  addressLineOne: addressLineOne ?? _addressLineOne,
  addressLineTwo: addressLineTwo ?? _addressLineTwo,
  createdAt: createdAt ?? _createdAt,
  id: id ?? _id,
);
  String? get addressLineOne => _addressLineOne;
  String? get addressLineTwo => _addressLineTwo;
  String? get createdAt => _createdAt;
  num? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['addressLineOne'] = _addressLineOne;
    map['addressLineTwo'] = _addressLineTwo;
    map['createdAt'] = _createdAt;
    map['id'] = _id;
    return map;
  }

}