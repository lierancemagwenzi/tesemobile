import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/auth/models/country_model.dart';

class RegistrationDocumentsModel{
  CountryModel? country;

  UploadIdModel selfie;
  String type;
  UploadIdModel? idFront;

  UploadIdModel? idBack;

  UploadIdModel? passport;
  RegistrationDocumentsModel({required this.selfie,this.idBack,this.idFront,this.passport,required this.type,this.country});

}