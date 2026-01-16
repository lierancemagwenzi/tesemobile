/// status : "Success"
/// message : "Success"
/// data : {"status":"Success","message":"Success","data":{"id":101,"phoneNumber":"+263785963546","gender":"Male","nationality":"Zimbabwean","nationalIdentificationTypeID":2,"nationalIdentificationType":"National ID","nationalIdentification":"63-1234567Z12","email":"udean.mbano@smatpay.africa","firstName":"Udean","lastName":"Mbano","password":"hashed_password_here","title":"Mr","role":"Admin","roleId":1,"activationCode":458921,"forgotPasswordCode":12,"activationActivated":true,"country":"Zimbabwe","activationBaseUrl":"https://staging.smatpay.africa/activate","nationalIdentityUrl":"https://cdn.smatpay.africa/users/101/id_front.jpg","nationalIdentityBackUrl":"https://cdn.smatpay.africa/users/101/id_back.jpg","capturePhotoUrl":"https://cdn.smatpay.africa/users/101/photo.jpg","userResidentialAddress":"13 David Morgan Crescent, Avondale, Harare","userSignatureUrl":"https://cdn.smatpay.africa/users/101/signature.png","salaryPayDay":25,"photoVerification":true,"createdAt":"2025-10-24T08:00:00Z","employers":[{"id":1,"employerName":"Weighty Premier Solutions","employerAddress":"Avondale, Harare","position":"Head of IT","startDate":"2020-01-15","isCurrentEmployer":true}]}}

class UpdateSalaryPayDayResponse {
  UpdateSalaryPayDayResponse({
      String? status, 
      String? message, 
      DataModel? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  UpdateSalaryPayDayResponse.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? DataModel.fromJson(json['data']) : null;
  }
  String? _status;
  String? _message;
  DataModel? _data;
UpdateSalaryPayDayResponse copyWith({  String? status,
  String? message,
  DataModel? data,
}) => UpdateSalaryPayDayResponse(  status: status ?? _status,
  message: message ?? _message,
  data: data ?? _data,
);
  String? get status => _status;
  String? get message => _message;
  DataModel? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// status : "Success"
/// message : "Success"
/// data : {"id":101,"phoneNumber":"+263785963546","gender":"Male","nationality":"Zimbabwean","nationalIdentificationTypeID":2,"nationalIdentificationType":"National ID","nationalIdentification":"63-1234567Z12","email":"udean.mbano@smatpay.africa","firstName":"Udean","lastName":"Mbano","password":"hashed_password_here","title":"Mr","role":"Admin","roleId":1,"activationCode":458921,"forgotPasswordCode":12,"activationActivated":true,"country":"Zimbabwe","activationBaseUrl":"https://staging.smatpay.africa/activate","nationalIdentityUrl":"https://cdn.smatpay.africa/users/101/id_front.jpg","nationalIdentityBackUrl":"https://cdn.smatpay.africa/users/101/id_back.jpg","capturePhotoUrl":"https://cdn.smatpay.africa/users/101/photo.jpg","userResidentialAddress":"13 David Morgan Crescent, Avondale, Harare","userSignatureUrl":"https://cdn.smatpay.africa/users/101/signature.png","salaryPayDay":25,"photoVerification":true,"createdAt":"2025-10-24T08:00:00Z","employers":[{"id":1,"employerName":"Weighty Premier Solutions","employerAddress":"Avondale, Harare","position":"Head of IT","startDate":"2020-01-15","isCurrentEmployer":true}]}

class Data {
  Data({
      String? status, 
      String? message, 
      DataModel? data,}){
    _status = status;
    _message = message;
    _data = data;
}

  Data.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? DataModel.fromJson(json['data']) : null;
  }
  String? _status;
  String? _message;
  DataModel? _data;
  Data copyWith({  String? status,
  String? message,
  DataModel? data,
}) => Data(  status: status ?? _status,
  message: message ?? _message,
  data: data ?? _data,
);
  String? get status => _status;
  String? get message => _message;
  DataModel? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// id : 101
/// phoneNumber : "+263785963546"
/// gender : "Male"
/// nationality : "Zimbabwean"
/// nationalIdentificationTypeID : 2
/// nationalIdentificationType : "National ID"
/// nationalIdentification : "63-1234567Z12"
/// email : "udean.mbano@smatpay.africa"
/// firstName : "Udean"
/// lastName : "Mbano"
/// password : "hashed_password_here"
/// title : "Mr"
/// role : "Admin"
/// roleId : 1
/// activationCode : 458921
/// forgotPasswordCode : 12
/// activationActivated : true
/// country : "Zimbabwe"
/// activationBaseUrl : "https://staging.smatpay.africa/activate"
/// nationalIdentityUrl : "https://cdn.smatpay.africa/users/101/id_front.jpg"
/// nationalIdentityBackUrl : "https://cdn.smatpay.africa/users/101/id_back.jpg"
/// capturePhotoUrl : "https://cdn.smatpay.africa/users/101/photo.jpg"
/// userResidentialAddress : "13 David Morgan Crescent, Avondale, Harare"
/// userSignatureUrl : "https://cdn.smatpay.africa/users/101/signature.png"
/// salaryPayDay : 25
/// photoVerification : true
/// createdAt : "2025-10-24T08:00:00Z"
/// employers : [{"id":1,"employerName":"Weighty Premier Solutions","employerAddress":"Avondale, Harare","position":"Head of IT","startDate":"2020-01-15","isCurrentEmployer":true}]

class DataModel {
  DataModel({
      num? id, 
      String? phoneNumber, 
      String? gender, 
      String? nationality, 
      num? nationalIdentificationTypeID, 
      String? nationalIdentificationType, 
      String? nationalIdentification, 
      String? email, 
      String? firstName, 
      String? lastName, 
      String? password, 
      String? title, 
      String? role, 
      num? roleId, 
      num? activationCode, 
      num? forgotPasswordCode, 
      bool? activationActivated, 
      String? country, 
      String? activationBaseUrl, 
      String? nationalIdentityUrl, 
      String? nationalIdentityBackUrl, 
      String? capturePhotoUrl, 
      String? userResidentialAddress, 
      String? userSignatureUrl, 
      num? salaryPayDay, 
      bool? photoVerification, 
      String? createdAt, 
      List<Employers>? employers,}){
    _id = id;
    _phoneNumber = phoneNumber;
    _gender = gender;
    _nationality = nationality;
    _nationalIdentificationTypeID = nationalIdentificationTypeID;
    _nationalIdentificationType = nationalIdentificationType;
    _nationalIdentification = nationalIdentification;
    _email = email;
    _firstName = firstName;
    _lastName = lastName;
    _password = password;
    _title = title;
    _role = role;
    _roleId = roleId;
    _activationCode = activationCode;
    _forgotPasswordCode = forgotPasswordCode;
    _activationActivated = activationActivated;
    _country = country;
    _activationBaseUrl = activationBaseUrl;
    _nationalIdentityUrl = nationalIdentityUrl;
    _nationalIdentityBackUrl = nationalIdentityBackUrl;
    _capturePhotoUrl = capturePhotoUrl;
    _userResidentialAddress = userResidentialAddress;
    _userSignatureUrl = userSignatureUrl;
    _salaryPayDay = salaryPayDay;
    _photoVerification = photoVerification;
    _createdAt = createdAt;
    _employers = employers;
}

  DataModel.fromJson(dynamic json) {
    _id = json['id'];
    _phoneNumber = json['phoneNumber'];
    _gender = json['gender'];
    _nationality = json['nationality'];
    _nationalIdentificationTypeID = json['nationalIdentificationTypeID'];
    _nationalIdentificationType = json['nationalIdentificationType'];
    _nationalIdentification = json['nationalIdentification'];
    _email = json['email'];
    _firstName = json['firstName'];
    _lastName = json['lastName'];
    _password = json['password'];
    _title = json['title'];
    _role = json['role'];
    _roleId = json['roleId'];
    _activationCode = json['activationCode'];
    _forgotPasswordCode = json['forgotPasswordCode'];
    _activationActivated = json['activationActivated'];
    _country = json['country'];
    _activationBaseUrl = json['activationBaseUrl'];
    _nationalIdentityUrl = json['nationalIdentityUrl'];
    _nationalIdentityBackUrl = json['nationalIdentityBackUrl'];
    _capturePhotoUrl = json['capturePhotoUrl'];
    _userResidentialAddress = json['userResidentialAddress'];
    _userSignatureUrl = json['userSignatureUrl'];
    _salaryPayDay = json['salaryPayDay'];
    _photoVerification = json['photoVerification'];
    _createdAt = json['createdAt'];
    if (json['employers'] != null) {
      _employers = [];
      json['employers'].forEach((v) {
        _employers?.add(Employers.fromJson(v));
      });
    }
  }
  num? _id;
  String? _phoneNumber;
  String? _gender;
  String? _nationality;
  num? _nationalIdentificationTypeID;
  String? _nationalIdentificationType;
  String? _nationalIdentification;
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _password;
  String? _title;
  String? _role;
  num? _roleId;
  num? _activationCode;
  num? _forgotPasswordCode;
  bool? _activationActivated;
  String? _country;
  String? _activationBaseUrl;
  String? _nationalIdentityUrl;
  String? _nationalIdentityBackUrl;
  String? _capturePhotoUrl;
  String? _userResidentialAddress;
  String? _userSignatureUrl;
  num? _salaryPayDay;
  bool? _photoVerification;
  String? _createdAt;
  List<Employers>? _employers;

  num? get id => _id;
  String? get phoneNumber => _phoneNumber;
  String? get gender => _gender;
  String? get nationality => _nationality;
  num? get nationalIdentificationTypeID => _nationalIdentificationTypeID;
  String? get nationalIdentificationType => _nationalIdentificationType;
  String? get nationalIdentification => _nationalIdentification;
  String? get email => _email;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get password => _password;
  String? get title => _title;
  String? get role => _role;
  num? get roleId => _roleId;
  num? get activationCode => _activationCode;
  num? get forgotPasswordCode => _forgotPasswordCode;
  bool? get activationActivated => _activationActivated;
  String? get country => _country;
  String? get activationBaseUrl => _activationBaseUrl;
  String? get nationalIdentityUrl => _nationalIdentityUrl;
  String? get nationalIdentityBackUrl => _nationalIdentityBackUrl;
  String? get capturePhotoUrl => _capturePhotoUrl;
  String? get userResidentialAddress => _userResidentialAddress;
  String? get userSignatureUrl => _userSignatureUrl;
  num? get salaryPayDay => _salaryPayDay;
  bool? get photoVerification => _photoVerification;
  String? get createdAt => _createdAt;
  List<Employers>? get employers => _employers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['phoneNumber'] = _phoneNumber;
    map['gender'] = _gender;
    map['nationality'] = _nationality;
    map['nationalIdentificationTypeID'] = _nationalIdentificationTypeID;
    map['nationalIdentificationType'] = _nationalIdentificationType;
    map['nationalIdentification'] = _nationalIdentification;
    map['email'] = _email;
    map['firstName'] = _firstName;
    map['lastName'] = _lastName;
    map['password'] = _password;
    map['title'] = _title;
    map['role'] = _role;
    map['roleId'] = _roleId;
    map['activationCode'] = _activationCode;
    map['forgotPasswordCode'] = _forgotPasswordCode;
    map['activationActivated'] = _activationActivated;
    map['country'] = _country;
    map['activationBaseUrl'] = _activationBaseUrl;
    map['nationalIdentityUrl'] = _nationalIdentityUrl;
    map['nationalIdentityBackUrl'] = _nationalIdentityBackUrl;
    map['capturePhotoUrl'] = _capturePhotoUrl;
    map['userResidentialAddress'] = _userResidentialAddress;
    map['userSignatureUrl'] = _userSignatureUrl;
    map['salaryPayDay'] = _salaryPayDay;
    map['photoVerification'] = _photoVerification;
    map['createdAt'] = _createdAt;
    if (_employers != null) {
      map['employers'] = _employers?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 1
/// employerName : "Weighty Premier Solutions"
/// employerAddress : "Avondale, Harare"
/// position : "Head of IT"
/// startDate : "2020-01-15"
/// isCurrentEmployer : true

class Employers {
  Employers({
      num? id, 
      String? employerName, 
      String? employerAddress, 
      String? position, 
      String? startDate, 
      bool? isCurrentEmployer,}){
    _id = id;
    _employerName = employerName;
    _employerAddress = employerAddress;
    _position = position;
    _startDate = startDate;
    _isCurrentEmployer = isCurrentEmployer;
}

  Employers.fromJson(dynamic json) {
    _id = json['id'];
    _employerName = json['employerName'];
    _employerAddress = json['employerAddress'];
    _position = json['position'];
    _startDate = json['startDate'];
    _isCurrentEmployer = json['isCurrentEmployer'];
  }
  num? _id;
  String? _employerName;
  String? _employerAddress;
  String? _position;
  String? _startDate;
  bool? _isCurrentEmployer;
Employers copyWith({  num? id,
  String? employerName,
  String? employerAddress,
  String? position,
  String? startDate,
  bool? isCurrentEmployer,
}) => Employers(  id: id ?? _id,
  employerName: employerName ?? _employerName,
  employerAddress: employerAddress ?? _employerAddress,
  position: position ?? _position,
  startDate: startDate ?? _startDate,
  isCurrentEmployer: isCurrentEmployer ?? _isCurrentEmployer,
);
  num? get id => _id;
  String? get employerName => _employerName;
  String? get employerAddress => _employerAddress;
  String? get position => _position;
  String? get startDate => _startDate;
  bool? get isCurrentEmployer => _isCurrentEmployer;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['employerName'] = _employerName;
    map['employerAddress'] = _employerAddress;
    map['position'] = _position;
    map['startDate'] = _startDate;
    map['isCurrentEmployer'] = _isCurrentEmployer;
    return map;
  }

}