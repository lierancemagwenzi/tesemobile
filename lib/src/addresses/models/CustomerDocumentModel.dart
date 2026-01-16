/// fileName : "Reinsurance BRD v1.0.pdf"
/// fileType : "Naional ID"
/// fileUrl : "https://smatpay.s3.af-south-1.amazonaws.com/Reinsurance BRD v1.0.pdf"
/// createdAt : "2024-07-26T12:15:11.882+00:00"
/// id : 1

class CustomerDocumentModel {
  CustomerDocumentModel({
      String? fileName, 
      String? fileType, 
      String? fileUrl, 
      String? createdAt, 
      num? id,}){
    _fileName = fileName;
    _fileType = fileType;
    _fileUrl = fileUrl;
    _createdAt = createdAt;
    _id = id;
}

  CustomerDocumentModel.fromJson(dynamic json) {
    _fileName = json['fileName'];
    _fileType = json['fileType'];
    _fileUrl = json['fileUrl'];
    _createdAt = json['createdAt'];
    _id = json['id'];
  }
  String? _fileName;
  String? _fileType;
  String? _fileUrl;
  String? _createdAt;
  num? _id;
CustomerDocumentModel copyWith({  String? fileName,
  String? fileType,
  String? fileUrl,
  String? createdAt,
  num? id,
}) => CustomerDocumentModel(  fileName: fileName ?? _fileName,
  fileType: fileType ?? _fileType,
  fileUrl: fileUrl ?? _fileUrl,
  createdAt: createdAt ?? _createdAt,
  id: id ?? _id,
);
  String? get fileName => _fileName;
  String? get fileType => _fileType;
  String? get fileUrl => _fileUrl;
  String? get createdAt => _createdAt;
  num? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['fileName'] = _fileName;
    map['fileType'] = _fileType;
    map['fileUrl'] = _fileUrl;
    map['createdAt'] = _createdAt;
    map['id'] = _id;
    return map;
  }

}