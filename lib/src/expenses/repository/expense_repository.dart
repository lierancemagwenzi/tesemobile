import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:http/http.dart' as http;
import 'package:smacredit/src/employment/models/EmploymentTypeModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

import '../../auth/models/VerifyOTPModel.dart';
import '../../helpers/Helper.dart';
import '../models/AddExpenseResponseModel.dart';
import '../models/ExpenseModel.dart';


Future<Stream<ExpenseModel>>get_expenses_list() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/expense/${currentuser.value.user?.id}';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url),);
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) {
    print(data);
    return Helper.getData(data);
  }).expand((data) => (data as List)).map((data) {
    ExpenseModel employerModel= ExpenseModel.fromJson(data);
    return employerModel;
  });
}
Future<AddExpenseResponseModel?> add_expense(Map map) async {
  print("#adding expense user");
  final String url = '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/createExpense';
  final client = new http.Client();
  try{
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json','Authorization':'Bearer ${currentuser.value.token}'},
      body: json.encode(map),
    ).timeout(const Duration(seconds: 6));

    print(response.body);
    if(response.statusCode==200) {
      AddExpenseResponseModel userModel=AddExpenseResponseModel.fromJson(json.decode(response.body));
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

Future<AddExpenseResponseModel?> update_expense(Map map) async {
  print("#adding expense user");
  final String url = '${GlobalConfiguration().getValue(
      'api_base_url')}credit/api/customer/updateExpense';
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
      AddExpenseResponseModel userModel = AddExpenseResponseModel.fromJson(
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
    print("error");
    print(e.stackTrace);
    return null;
  }
}