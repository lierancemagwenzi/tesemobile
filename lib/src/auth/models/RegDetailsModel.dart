/// firstName : "John"
/// lastName : "Doe"
/// email : "lierance@smatechgroup.com"
/// phoneNumber : "+1234567890"
/// gender : "Male"
/// nationality : "Zimbabwean"
/// nationalIdentificationTypeID : 1
/// nationalIdentificationType : "National ID"
/// nationalIdentification : "AA0192463D18"
/// title : "Mr."
/// dob : ""

class RegDetailsModel {
  RegDetailsModel({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? gender,
    String? nationality,
    num? nationalIdentificationTypeID,
    String? nationalIdentificationType,
    String? nationalIdentification,
    String? title,
    String? dob,

    String? province,
    String? tradingName,
    String? businessDescription,
    String? tradingAddress,

    String? telephoneNumber,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _phoneNumber = phoneNumber;
    _gender = gender;
    _nationality = nationality;
    _nationalIdentificationTypeID = nationalIdentificationTypeID;
    _nationalIdentificationType = nationalIdentificationType;
    _nationalIdentification = nationalIdentification;
    _title = title;
    _dob = dob;

    _province = province;
    _tradingName = tradingName;
    _businessDescription = businessDescription;
    _tradingAddress = tradingAddress;
    _telephoneNumber = telephoneNumber;
  }

  RegDetailsModel.fromJson(dynamic json) {
    _firstName = json['firstName'];
    _lastName = json['lastName'];
    _email = json['email'];
    _phoneNumber = json['phoneNumber'];
    _gender = json['gender'];
    _nationality = json['nationality'];
    _nationalIdentificationTypeID = json['nationalIdentificationTypeID'];
    _nationalIdentificationType = json['nationalIdentificationType'];
    _nationalIdentification = json['nationalIdentification'];
    _title = json['title'];
    _dob = json['dob'];
  }
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phoneNumber;
  String? _gender;
  String? _nationality;
  num? _nationalIdentificationTypeID;
  String? _nationalIdentificationType;
  String? _nationalIdentification;
  String? _title;
  String? _dob;

  String? _tradingName;
  String? _businessDescription;
  String? _telephoneNumber;
  String? _province;
  String? _tradingAddress;

  RegDetailsModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? gender,
    String? nationality,
    num? nationalIdentificationTypeID,
    String? nationalIdentificationType,
    String? nationalIdentification,
    String? title,
    String? dob,
  }) => RegDetailsModel(
    firstName: firstName ?? _firstName,
    lastName: lastName ?? _lastName,
    email: email ?? _email,
    phoneNumber: phoneNumber ?? _phoneNumber,
    gender: gender ?? _gender,
    nationality: nationality ?? _nationality,
    nationalIdentificationTypeID:
        nationalIdentificationTypeID ?? _nationalIdentificationTypeID,
    nationalIdentificationType:
        nationalIdentificationType ?? _nationalIdentificationType,
    nationalIdentification: nationalIdentification ?? _nationalIdentification,
    title: title ?? _title,
    dob: dob ?? _dob,
  );
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get gender => _gender;
  String? get nationality => _nationality;
  num? get nationalIdentificationTypeID => _nationalIdentificationTypeID;
  String? get nationalIdentificationType => _nationalIdentificationType;
  String? get nationalIdentification => _nationalIdentification;
  String? get title => _title;
  String? get dob => _dob;

  String? get province => _province;
  String? get tradingName => _tradingName;
  String? get tradingAddress => _tradingAddress;
  String? get businessDescription => _businessDescription;
  String? get telephoneNumber => _telephoneNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstName'] = _firstName;
    map['lastName'] = _lastName;
    map['email'] = _email;
    map['phoneNumber'] = _phoneNumber;
    map['gender'] = _gender;
    map['nationality'] = _nationality;
    map['nationalIdentificationTypeID'] = _nationalIdentificationTypeID;
    map['nationalIdentificationType'] = _nationalIdentificationType;
    map['nationalIdentification'] = _nationalIdentification;
    map['title'] = _title;
    map['dateOfBirth'] = _dob;

    map['province'] = _province;
    map['businessDescription'] = _businessDescription;
    map['tradingAddress'] = _tradingAddress;
    map['tradingName'] = _tradingName;
    map['province'] = _province;
    return map;
  }
}
