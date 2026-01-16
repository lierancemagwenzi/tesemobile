/// id : 1
/// documentTypeName : "Copy of memorandum and articles of association"
/// createdAt : "2024-08-01T14:48:59.192+00:00"
/// updatedAt : "2024-08-01T14:48:59.192+00:00"

class DocumentTypeModel {
  DocumentTypeModel({
      num? id, 
      String? documentTypeName, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _documentTypeName = documentTypeName;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  DocumentTypeModel.fromJson(dynamic json) {
    _id = json['id'];
    _documentTypeName = json['documentTypeName'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  num? _id;
  String? _documentTypeName;
  String? _createdAt;
  String? _updatedAt;
DocumentTypeModel copyWith({  num? id,
  String? documentTypeName,
  String? createdAt,
  String? updatedAt,
}) => DocumentTypeModel(  id: id ?? _id,
  documentTypeName: documentTypeName ?? _documentTypeName,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  String? get documentTypeName => _documentTypeName;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['documentTypeName'] = _documentTypeName;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }

}