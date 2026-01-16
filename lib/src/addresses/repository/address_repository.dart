import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:smacredit/src/addresses/NextOfKinModel.dart';
import 'package:smacredit/src/addresses/models/AddressModel.dart';
import 'package:smacredit/src/addresses/models/CustomerDocumentModel.dart';
import 'package:smacredit/src/addresses/models/DocumentTypeModel.dart';
import 'package:smacredit/src/addresses/models/SaveAddressResponseModel.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:http/http.dart' as http;
import 'package:smacredit/src/employment/models/EmploymentTypeModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

import '../../expenses/models/AddExpenseResponseModel.dart';
import '../../helpers/Helper.dart';
import '../models/AddNextOfKinResponseModel.dart';
import '../models/UpdateNextOfKinResponseModel.dart';

Future<Stream<AddressModel>>get_address_list() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/address/${currentuser.value.user?.id}';
  print(url);
  final client = new http.Client();

  http.Request request = http.Request('get', Uri.parse(url),);
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) {
    print(data);
    return Helper.getData(data);
  }).expand((data) => (data as List)).map((data) {
    AddressModel employerModel= AddressModel.fromJson(data);
    return employerModel;
  });
}
Future<Stream<NextOfKinModel>>get_next_of_kins() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/nextofkin/${currentuser.value.user?.id}';
  print(url);
  final client = new http.Client();

  http.Request request = http.Request('get', Uri.parse(url),);
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) {
    print(data);
    return Helper.getData(data);
  }).expand((data) => (data as List)).map((data) {
    NextOfKinModel employerModel= NextOfKinModel.fromJson(data);
    return employerModel;
  });
}


Future<Stream<CustomerDocumentModel>>get_document_list() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/documentsList/${currentuser.value.user?.id}';
  print(url);
  final client = new http.Client();

  http.Request request = http.Request('get', Uri.parse(url),);
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) {
    print(data);
    return Helper.getData(data);
  }).expand((data) => (data as List)).map((data) {
    CustomerDocumentModel employerModel= CustomerDocumentModel.fromJson(data);
    return employerModel;
  });
}
Future<Stream<DocumentTypeModel>>get_document_types() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}param/documentTypes';
  print(url);
  final client = new http.Client();

  http.Request request = http.Request('get', Uri.parse(url),);
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) {
    print(data);
    return Helper.getData(data);
  }).expand((data) => (data as List)).map((data) {
    DocumentTypeModel employerModel= DocumentTypeModel.fromJson(data);
    return employerModel;
  });
}

Future<SaveAddressResponseModel?> update_address(Map map) async {
  print("#update address");
  final String url = '${GlobalConfiguration().getValue(
      'api_base_url')}credit/api/customer/updateAddress';
  final client = new http.Client();
  try {
    final response = await client.patch(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Authorization': 'Bearer ${currentuser.value.token}'
      },
      body: json.encode(map),
    ).timeout(const Duration(seconds: 6));
    print(response.body);
    if (response.statusCode == 200) {
      SaveAddressResponseModel userModel = SaveAddressResponseModel.fromJson(
          json.decode(response.body));
      return userModel;
    }
    else {
      return null;
    }
  } on TimeoutException catch (e) {
    print(e.message);
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    print(e.stackTrace);
    return null;
  }
}


Future<SaveAddressResponseModel?> save_address(Map map) async {
  print("#adding address");
  final String url = '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/createAddress';
  final client = new http.Client();
  try{
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json','Authorization':'Bearer ${currentuser.value.token}'},
      body: json.encode(map),
    ).timeout(const Duration(seconds: 6));

    print(response.body);
    if(response.statusCode==200) {
      SaveAddressResponseModel userModel=SaveAddressResponseModel.fromJson(json.decode(response.body));
      return userModel;
    }
    else{
      return  null;
    }
  }on TimeoutException catch (e) {
    print(e.message);
    return  null;
  } on SocketException catch (e) {
    return   null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return   null;

  }



}


Future<AddNextOfKinResponseModel?> save_next_of_kin(Map map) async {
  print("#adding nextofkin");
  final String url = '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/createNextOfKin';
  final client = new http.Client();
  try{
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json','Authorization':'Bearer ${currentuser.value.token}'},
      body: json.encode(map),
    ).timeout(const Duration(seconds: 6));

    print(response.body);
    if(response.statusCode==200) {
      AddNextOfKinResponseModel userModel=AddNextOfKinResponseModel.fromJson(json.decode(response.body));
      return userModel;
    }
    else{
      return  null;
    }
  }on TimeoutException catch (e) {
    print(e.message);
    return  null;
  } on SocketException catch (e) {
    return   null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return   null;

  }



}


Future<UpdateNextOfKinResponseModel?> update_next_of_kin(Map map) async {
  print("#updating nextofkin");
  final String url = '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/updateNextOfKin';
  final client = new http.Client();
  try{
    final response = await client.patch(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json','Authorization':'Bearer ${currentuser.value.token}'},
      body: json.encode(map),
    ).timeout(const Duration(seconds: 6));

    print(response.body);
    if(response.statusCode==200) {
      UpdateNextOfKinResponseModel userModel=UpdateNextOfKinResponseModel.fromJson(json.decode(response.body));
      return userModel;
    }
    else{
      return  null;
    }
  }on TimeoutException catch (e) {
    print(e.message);
    return  null;
  } on SocketException catch (e) {
    return   null;
  } on Error catch (e) {
    print("error");
    print(e.stackTrace);
    return   null;
  }

}