/// status : "Success"
/// fileLink : "https://smatpay.s3.af-south-1.amazonaws.com/20241106082540-f5838a66-2c42-4ae2-9140-f5ce9f1bce4c3836511194782480445.jpg"
/// message : "National ID uploaded successfully"

class UploadIdModel {
  UploadIdModel({
      String? status, 
      String? fileLink, 
      String? message,}){
    _status = status;
    _fileLink = fileLink;
    _message = message;
}

  UploadIdModel.fromJson(dynamic json) {
    _status = json['status'];
    _fileLink = json['fileLink'];
    _message = json['message'];
  }
  String? _status;
  String? _fileLink;
  String? _message;
UploadIdModel copyWith({  String? status,
  String? fileLink,
  String? message,
}) => UploadIdModel(  status: status ?? _status,
  fileLink: fileLink ?? _fileLink,
  message: message ?? _message,
);
  String? get status => _status;
  String? get fileLink => _fileLink;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['fileLink'] = _fileLink;
    map['message'] = _message;
    return map;
  }

}