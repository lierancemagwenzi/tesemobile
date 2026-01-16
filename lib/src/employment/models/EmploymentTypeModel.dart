/// id : 1
/// employmentTypeName : "Full-Time"
/// createdAt : "2024-10-26T19:09:26.329+00:00"
/// updatedAt : "2024-10-26T19:09:26.329+00:00"

class EmploymentTypeModel {
  EmploymentTypeModel({
      num? id, 
      String? employmentTypeName, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _employmentTypeName = employmentTypeName;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  EmploymentTypeModel.fromJson(dynamic json) {
    _id = json['id'];
    _employmentTypeName = json['employmentTypeName'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  num? _id;
  String? _employmentTypeName;
  String? _createdAt;
  String? _updatedAt;
EmploymentTypeModel copyWith({  num? id,
  String? employmentTypeName,
  String? createdAt,
  String? updatedAt,
}) => EmploymentTypeModel(  id: id ?? _id,
  employmentTypeName: employmentTypeName ?? _employmentTypeName,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  String? get employmentTypeName => _employmentTypeName;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['employmentTypeName'] = _employmentTypeName;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}