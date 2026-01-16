/// ID_Number : "63-1394336 Q 26 CIT M"
/// Surname : "MBANO"
/// First_Name : "UDEAN"
/// Date_of_Birth : "08/04/1990"
/// Village_of_Origin : "MANGIRAZI"
/// Place_of_Birth : "BULAWAYO"
/// Date_of_Issue : "10/04/2006"

class ExtractIdModel {
  ExtractIdModel({
      String? iDNumber, 
      String? surname, 
      String? firstName, 
      String? dateOfBirth, 
      String? villageOfOrigin, 
      String? placeOfBirth, 
      String? dateOfIssue,}){
    _iDNumber = iDNumber;
    _surname = surname;
    _firstName = firstName;
    _dateOfBirth = dateOfBirth;
    _villageOfOrigin = villageOfOrigin;
    _placeOfBirth = placeOfBirth;
    _dateOfIssue = dateOfIssue;
}

  ExtractIdModel.fromJson(dynamic json) {
    _iDNumber = json['id_number'];
    _surname = json['surname'];
    _firstName = json['first_name'];
    _dateOfBirth = json['date_of_birth'];
    _villageOfOrigin = json['village_of_origin'];
    _placeOfBirth = json['place_of_birth'];
    _dateOfIssue = json['date_of_issue'];
  }
  String? _iDNumber;
  String? _surname;
  String? _firstName;
  String? _dateOfBirth;
  String? _villageOfOrigin;
  String? _placeOfBirth;
  String? _dateOfIssue;
ExtractIdModel copyWith({  String? iDNumber,
  String? surname,
  String? firstName,
  String? dateOfBirth,
  String? villageOfOrigin,
  String? placeOfBirth,
  String? dateOfIssue,
}) => ExtractIdModel(  iDNumber: iDNumber ?? _iDNumber,
  surname: surname ?? _surname,
  firstName: firstName ?? _firstName,
  dateOfBirth: dateOfBirth ?? _dateOfBirth,
  villageOfOrigin: villageOfOrigin ?? _villageOfOrigin,
  placeOfBirth: placeOfBirth ?? _placeOfBirth,
  dateOfIssue: dateOfIssue ?? _dateOfIssue,
);
  String? get iDNumber => _iDNumber;
  String? get surname => _surname;
  String? get firstName => _firstName;
  String? get dateOfBirth => _dateOfBirth;
  String? get villageOfOrigin => _villageOfOrigin;
  String? get placeOfBirth => _placeOfBirth;
  String? get dateOfIssue => _dateOfIssue;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ID_Number'] = _iDNumber;
    map['Surname'] = _surname;
    map['First_Name'] = _firstName;
    map['Date_of_Birth'] = _dateOfBirth;
    map['Village_of_Origin'] = _villageOfOrigin;
    map['Place_of_Birth'] = _placeOfBirth;
    map['Date_of_Issue'] = _dateOfIssue;
    return map;
  }

}