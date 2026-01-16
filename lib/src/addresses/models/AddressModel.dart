/// addressLineOne : ""
/// addressLineTwo : ""
/// createdAt : ""

class AddressModel {
  AddressModel({
      String? addressLineOne, 
      String? addressLineTwo,
    num ? id,
      String? createdAt,}){
    _addressLineOne = addressLineOne;
    _addressLineTwo = addressLineTwo;
    _createdAt = createdAt;
    _id = id;
}

  AddressModel.fromJson(dynamic json) {
    _addressLineOne = json['addressLineOne'];
    _addressLineTwo = json['addressLineTwo'];
    _createdAt = json['createdAt'];
    _id = json['id'];
  }
  String? _addressLineOne;
  String? _addressLineTwo;
  String? _createdAt;
  num? _id;
AddressModel copyWith({  String? addressLineOne,
  String? addressLineTwo,
  String? createdAt,
}) => AddressModel(  addressLineOne: addressLineOne ?? _addressLineOne,
  addressLineTwo: addressLineTwo ?? _addressLineTwo,
  createdAt: createdAt ?? _createdAt,
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
    return map;
  }

}