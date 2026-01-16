/// nextOfKinName : "Father A"
/// nextOfKinSurname : "SurnameB"
/// nextOfKinCellNumber : "+263779627951"
/// nextOfKinEmailAddress : "55 A Road Alexander Park"
/// nextOfKinAddress : "5 Court Road Greendale"
/// createdAt : "2024-11-18T09:00:44.832+00:00"
/// updatedAt : "2024-11-18T09:00:44.832+00:00"
/// id : 1

class NextOfKinModel {
  NextOfKinModel({
      String? nextOfKinName, 
      String? nextOfKinSurname, 
      String? nextOfKinCellNumber, 
      String? nextOfKinEmailAddress, 
      String? nextOfKinAddress, 
      String? createdAt, 
      String? updatedAt, 
      num? id,}){
    _nextOfKinName = nextOfKinName;
    _nextOfKinSurname = nextOfKinSurname;
    _nextOfKinCellNumber = nextOfKinCellNumber;
    _nextOfKinEmailAddress = nextOfKinEmailAddress;
    _nextOfKinAddress = nextOfKinAddress;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _id = id;
}

  NextOfKinModel.fromJson(dynamic json) {
    _nextOfKinName = json['nextOfKinName'];
    _nextOfKinSurname = json['nextOfKinSurname'];
    _nextOfKinCellNumber = json['nextOfKinCellNumber'];
    _nextOfKinEmailAddress = json['nextOfKinEmailAddress'];
    _nextOfKinAddress = json['nextOfKinAddress'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _id = json['id'];
  }
  String? _nextOfKinName;
  String? _nextOfKinSurname;
  String? _nextOfKinCellNumber;
  String? _nextOfKinEmailAddress;
  String? _nextOfKinAddress;
  String? _createdAt;
  String? _updatedAt;
  num? _id;
NextOfKinModel copyWith({  String? nextOfKinName,
  String? nextOfKinSurname,
  String? nextOfKinCellNumber,
  String? nextOfKinEmailAddress,
  String? nextOfKinAddress,
  String? createdAt,
  String? updatedAt,
  num? id,
}) => NextOfKinModel(  nextOfKinName: nextOfKinName ?? _nextOfKinName,
  nextOfKinSurname: nextOfKinSurname ?? _nextOfKinSurname,
  nextOfKinCellNumber: nextOfKinCellNumber ?? _nextOfKinCellNumber,
  nextOfKinEmailAddress: nextOfKinEmailAddress ?? _nextOfKinEmailAddress,
  nextOfKinAddress: nextOfKinAddress ?? _nextOfKinAddress,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  id: id ?? _id,
);
  String? get nextOfKinName => _nextOfKinName;
  String? get nextOfKinSurname => _nextOfKinSurname;
  String? get nextOfKinCellNumber => _nextOfKinCellNumber;
  String? get nextOfKinEmailAddress => _nextOfKinEmailAddress;
  String? get nextOfKinAddress => _nextOfKinAddress;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['nextOfKinName'] = _nextOfKinName;
    map['nextOfKinSurname'] = _nextOfKinSurname;
    map['nextOfKinCellNumber'] = _nextOfKinCellNumber;
    map['nextOfKinEmailAddress'] = _nextOfKinEmailAddress;
    map['nextOfKinAddress'] = _nextOfKinAddress;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['id'] = _id;
    return map;
  }

}