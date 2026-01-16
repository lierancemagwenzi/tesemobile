import 'package:country_picker/country_picker.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';

class RegistrationDocumentsModel{
  Country? country;

  UploadIdModel selfie;
  String type;
  UploadIdModel? idFront;

  UploadIdModel? idBack;

  UploadIdModel? passport;
  RegistrationDocumentsModel({required this.selfie,this.idBack,this.idFront,this.passport,required this.type,this.country});

}