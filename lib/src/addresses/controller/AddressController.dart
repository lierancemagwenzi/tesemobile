import 'dart:convert';
import 'dart:io';
// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http_parser/http_parser.dart';
import 'package:smacredit/src/addresses/NextOfKinModel.dart';
import 'package:smacredit/src/addresses/models/AddressModel.dart';
import 'package:smacredit/src/addresses/models/CustomerDocumentModel.dart';
import 'package:smacredit/src/addresses/models/DocumentTypeModel.dart';
import 'package:smacredit/src/addresses/repository/address_repository.dart';
import 'package:smacredit/src/auth/models/ExtractIDModel.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:smacredit/src/employment/repository/employer_repository.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import '../../helpers/Message.dart';
import '../../home/models/ProfileModel.dart';
import '../../home/repository/dashboard_repository.dart';


class AddressController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool loading = false;
  List<AddressModel> addresses = [];
  List<NextOfKinModel> kins = [];
  NextOfKinModel? nextOfKinModel;
  List<DocumentTypeModel> document_types = [];
  CustomerDocumentModel? proof_of_residence;
  CustomerDocumentModel? signature;

  List<CustomerDocumentModel> documents = [];
  DocumentTypeModel? documentType;
  DocumentTypeModel? signatureDocumentTypeModel;

  AddressModel? addressModel;
  ProfileModel? profileModel;

  TextEditingController address1Controller=TextEditingController();
  TextEditingController address2Controller=TextEditingController();



  AddressController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  void addNextOfKin(Map map) {
    print(map);
    setState(() {
      loading = true;
    });
    save_next_of_kin(map).then((value) async {
      if (value != null) {
        print(value.toJson());
        setState(() {
          loading = false;
        });
      //   AwesomeDialog(
      //     dismissOnBackKeyPress: false,
      //       dismissOnTouchOutside: false,
      //       context: scaffoldKey.currentContext!,
      //       dialogType: DialogType.success,
      //       animType: AnimType.rightSlide,
      //       title: 'Next of kin added',
      //       desc: 'Next of kin added successfully',
      //       // btnCancelOnPress: () {},
      // btnOkOnPress: () {
      //   Navigator.pop(scaffoldKey.currentContext!,"Next of kin added added");
      //
      // },
      // ).show();


      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
            scaffoldKey.currentContext!, "Something went wrong.Try again");
      }
    });
  }

  void updateNextOfKin(Map map) {
    setState(() {
      loading = true;
    });
    update_next_of_kin(map).then((value) async {
      if (value != null) {
        print(value.toJson());
        setState(() {
          loading = false;
        });
        // AwesomeDialog(
        //   dismissOnBackKeyPress: false,
        //   dismissOnTouchOutside: false,
        //   context: scaffoldKey.currentContext!,
        //   dialogType: DialogType.success,
        //   animType: AnimType.rightSlide,
        //   title: 'Next of kin updated',
        //   desc: 'Next of kin updated successfully',
        //   // btnCancelOnPress: () {},
        //   btnOkOnPress: () {
        //     Navigator.pop(scaffoldKey.currentContext!,"Next of kin added updated");
        //
        //   },
        // ).show();

      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
            scaffoldKey.currentContext!, "Something went wrong.Try again");
      }
    });
  }

  void addAddress(Map map) {
    setState(() {
      loading = true;
    });
    save_address(map).then((value) async {
      if (value != null) {
        print(value.toJson());
        setState(() {
          loading = false;
        });
       Navigator.pop(scaffoldKey.currentContext!,"Address added");
       
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
            scaffoldKey.currentContext!, "Something went wrong.Try again");
      }
    });
  }
  void updateAddress(Map map) {
    setState(() {
      loading = true;
    });
    update_address(map).then((value) async {
      if (value != null) {
        print(value.toJson());
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showSuccessSnakeBar(
            scaffoldKey.currentContext!, "Address updated");

      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(
            scaffoldKey.currentContext!, "Something went wrong.Try again");
      }
    });
  }
  Future<void> listenForCustomerAddresses() async {
    setState(() {
      loading = true;
    });
    addresses.clear();
    final Stream<AddressModel> stream = await get_address_list();

    stream.listen((AddressModel employerModel) {
      setState(() => addresses.add(employerModel));
    }, onError: (a) {
      setState(() {
        loading = false;
      });
      print(a);
    }, onDone: () {
      if(addresses.isNotEmpty){
        addressModel=addresses[0];
        address1Controller.text=addressModel?.addressLineOne??"";
        address2Controller.text=addressModel?.addressLineTwo??"";
      }
      setState(() {
        loading = false;
      });
    });
  }
  Future<void> listenForCustomerDocuments() async {
    setState(() {
      loading = true;
    });
    documents.clear();
    final Stream<CustomerDocumentModel> stream = await get_document_list();

    stream.listen((CustomerDocumentModel employerModel) {
      setState(() => documents.add(employerModel));
    }, onError: (a) {
      setState(() {
        loading = false;
      });
      print(a);
    }, onDone: () {
      if(documents.isNotEmpty){


        documents.forEach((element) {
          if((element.fileType??"").contains("Proof of residence")){

            proof_of_residence=element;
          }
          if((element.fileType??"").contains("Customer Signature")){

            signature=element;
          }
        });
   ;
      }
      setState(() {
        loading = false;
      });
    });
  }
  Future<void> listenForNextKin() async {
    setState(() {
      loading = true;
    });
    kins.clear();
    final Stream<NextOfKinModel> stream = await get_next_of_kins();

    stream.listen((NextOfKinModel employerModel) {
      setState(() => kins.add(employerModel));
    }, onError: (a) {
      setState(() {
        loading = false;
      });
      print(a);
    }, onDone: () {
      if(kins.isNotEmpty){
        nextOfKinModel=kins[0];
      }
      setState(() {
        loading = false;
      });
    });
  }
  Future<void> listenForDocumentTypes() async {
    setState(() {
      loading = true;
    });
    document_types.clear();
    final Stream<DocumentTypeModel> stream = await get_document_types();
    stream.listen((DocumentTypeModel employerModel) {
      setState(() => document_types.add(employerModel));
    }, onError: (a) {
      setState(() {
        loading = false;
      });
      print(a);
    }, onDone: () {
      document_types.forEach((element) {
        if((element.documentTypeName??"").contains("Proof of residence, municipality rates paper")){
          documentType=element;
        }
        if((element.documentTypeName??"").contains("Customer Signature")){
          signatureDocumentTypeModel=element;
        }


        print("${element.id} ${element.documentTypeName}");
      });
      // if(documents.isNotEmpty){
      //   proof_of_residence=documents[0];
      // }
      setState(() {
        loading = false;
      });
    });
  }



  Future<void> listenForProfileInfo() async {

    setState(() {

      loading=true;
    });
    final Stream<ProfileModel> stream = await get_profile_info();

    stream.listen((ProfileModel employerModel) {
      setState(() {
        profileModel=employerModel;
      });
    }, onError: (a) {
      setState(() {
        loading=false;
      });
      print(a);
    }, onDone: () {
      setState(() {
        loading=false;
      });
    });
  }
  uploadDocument(DocumentTypeModel documentTypeModel,File files) async {
    setState(() {
      loading=true;
    });
    Map<String, String> headers = { "Authorization": 'Bearer ${currentuser.value.token}'};
    var postUri = Uri.parse("${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/documentUpload");
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    // request.fields['document_id'] = id.toString();
    // request.fields['user_id'] = currentuser.value.id.toString();
    var files2=[];
    File element=files;
    final mimeType = lookupMimeType(element.path); // 'image/jpeg'
    print(mimeType);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'document', element.path,  contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);
    request.fields['userId'] ="${currentuser.value.user?.id}";
    request.fields['documentTypeId'] ="${documentTypeModel?.id}";
    request.fields['documentType'] ="${documentTypeModel?.documentTypeName}";
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    var responseB = await http.Response.fromStream(response);
    print(responseB.body);
    if(response.statusCode==200){
      setState(() {
        loading=false;
      });

      UploadIdModel uploadIdModel=UploadIdModel.fromJson(jsonDecode(responseB.body));
      Navigator.pop(scaffoldKey.currentContext!,"Document uploaded successfully");
    }
    else{
      setState(() {
        loading=false;
      });
      CustomMessageHandler().showErrorSnakeBar(scaffoldKey.currentContext!, "Something went wrong with the upload.Try again");

    }
    print(response.statusCode);
  }
}