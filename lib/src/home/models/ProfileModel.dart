/// id : 1
/// phoneNumber : "+1234567890"
/// gender : "Male"
/// nationality : "Zimbabwean"
/// nationalIdentificationTypeID : 1
/// nationalIdentificationType : "National ID"
/// nationalIdentification : "AB1234567"
/// email : "udean@smatechgroup.com"
/// firstName : "John"
/// lastName : "Doe"
/// password : "2eba4sy8o1e2t+aZ0U4dXw=="
/// title : "Mr."
/// role : "CUSTOMER"
/// roleId : 2
/// activationCode : 747768
/// forgotPasswordCode : 343443
/// activationActivated : ""
/// country : ""
/// activationBaseUrl : ""
/// nationalIdentityUrl : "https://smatpay.s3.af-south-1.amazonaws.com/Face/IMG_20231112_114406.jpg"
/// nationalIdentityBackUrl : "https://smatpay.s3.af-south-1.amazonaws.com/20241024095159-IMG_20231112_114419.jpg"
/// capturePhotoUrl : "https://smatpay.s3.af-south-1.amazonaws.com/Face/IMG_20241021_163537.jpg"
/// userResidentialAddress : ""
/// userSignatureUrl : ""
/// photoVerification : ""
/// createdAt : "2024-10-24T10:55:08.474+00:00"

class ProfileModel {
  ProfileModel({
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
    String? forgotPasswordCode,
      String? activationActivated, 
      String? country, 
      String? activationBaseUrl, 
      String? nationalIdentityUrl, 
      String? nationalIdentityBackUrl, 
      String? capturePhotoUrl, 
      String? userResidentialAddress, 
      String? userSignatureUrl, 
      String? photoVerification, 
      String? createdAt,}){
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
    _photoVerification = photoVerification;
    _createdAt = createdAt;
}

  ProfileModel.fromJson(dynamic json) {
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
    _photoVerification = json['photoVerification'];
    _createdAt = json['createdAt'];
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
  String? _forgotPasswordCode;
  String? _activationActivated;
  String? _country;
  String? _activationBaseUrl;
  String? _nationalIdentityUrl;
  String? _nationalIdentityBackUrl;
  String? _capturePhotoUrl;
  String? _userResidentialAddress;
  String? _userSignatureUrl;
  String? _photoVerification;
  String? _createdAt;
ProfileModel copyWith({  num? id,
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
  String? forgotPasswordCode,
  String? activationActivated,
  String? country,
  String? activationBaseUrl,
  String? nationalIdentityUrl,
  String? nationalIdentityBackUrl,
  String? capturePhotoUrl,
  String? userResidentialAddress,
  String? userSignatureUrl,
  String? photoVerification,
  String? createdAt,
}) => ProfileModel(  id: id ?? _id,
  phoneNumber: phoneNumber ?? _phoneNumber,
  gender: gender ?? _gender,
  nationality: nationality ?? _nationality,
  nationalIdentificationTypeID: nationalIdentificationTypeID ?? _nationalIdentificationTypeID,
  nationalIdentificationType: nationalIdentificationType ?? _nationalIdentificationType,
  nationalIdentification: nationalIdentification ?? _nationalIdentification,
  email: email ?? _email,
  firstName: firstName ?? _firstName,
  lastName: lastName ?? _lastName,
  password: password ?? _password,
  title: title ?? _title,
  role: role ?? _role,
  roleId: roleId ?? _roleId,
  activationCode: activationCode ?? _activationCode,
  forgotPasswordCode: forgotPasswordCode ?? _forgotPasswordCode,
  activationActivated: activationActivated ?? _activationActivated,
  country: country ?? _country,
  activationBaseUrl: activationBaseUrl ?? _activationBaseUrl,
  nationalIdentityUrl: nationalIdentityUrl ?? _nationalIdentityUrl,
  nationalIdentityBackUrl: nationalIdentityBackUrl ?? _nationalIdentityBackUrl,
  capturePhotoUrl: capturePhotoUrl ?? _capturePhotoUrl,
  userResidentialAddress: userResidentialAddress ?? _userResidentialAddress,
  userSignatureUrl: userSignatureUrl ?? _userSignatureUrl,
  photoVerification: photoVerification ?? _photoVerification,
  createdAt: createdAt ?? _createdAt,
);
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
  String? get forgotPasswordCode => _forgotPasswordCode;
  String? get activationActivated => _activationActivated;
  String? get country => _country;
  String? get activationBaseUrl => _activationBaseUrl;
  String? get nationalIdentityUrl => _nationalIdentityUrl;
  String? get nationalIdentityBackUrl => _nationalIdentityBackUrl;
  String? get capturePhotoUrl => _capturePhotoUrl;
  String? get userResidentialAddress => _userResidentialAddress;
  String? get userSignatureUrl => _userSignatureUrl;
  String? get photoVerification => _photoVerification;
  String? get createdAt => _createdAt;

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
    map['photoVerification'] = _photoVerification;
    map['createdAt'] = _createdAt;
    return map;
  }

}