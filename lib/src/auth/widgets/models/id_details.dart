class IdDetails {
  final String? idNumber;
  final String? surname;
  final String? firstName; // <-- NEW FIELD
  final String? dob;

  IdDetails({this.idNumber, this.surname, this.firstName, this.dob});

  @override
  String toString() {
    return 'ID: $idNumber, Name: $firstName $surname, DOB: $dob';
  }
}
