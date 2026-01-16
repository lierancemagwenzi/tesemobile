import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:smacredit/src/credit/models/PaymentResponse.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:http/http.dart' as http;
import 'package:smacredit/src/employment/models/EmploymentTypeModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

import '../../credit/models/CreditApplication.dart';
import '../../expenses/models/AddExpenseResponseModel.dart';
import '../../helpers/Helper.dart';
import '../models/AddEmploymentResponseModel.dart';
import '../models/ConfirmOTPResult.dart';
import '../models/UpdateSalaryPayDayResponse.dart';

Future<Stream<EmployerModel>> get_employer_list() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}auth/merchantEmployer/all';
  print(url);
  final client = new http.Client();

  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) {
        // print(data);
        return Helper.getData(data);
      })
      .expand((data) => (data as List))
      .map((data) {
        EmployerModel employerModel = EmployerModel.fromJson(data);
        return employerModel;
      });
}

Future<Stream<EmploymentTypeModel>> get_employment_types() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}param/employmentTypes';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) {
        print(data);
        return Helper.getData(data);
      })
      .expand((data) => (data as List))
      .map((data) {
        EmploymentTypeModel employerModel = EmploymentTypeModel.fromJson(data);
        return employerModel;
      });
}

Future<Stream<CustomerEmployerModel>> get_customer_employers() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/employer/${currentuser.value.user?.id}';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);

  getCreditApplications();
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) {
        print(data);
        return Helper.getData(data);
      })
      .expand((data) => (data as List))
      .map((data) {
        CustomerEmployerModel employerModel = CustomerEmployerModel.fromJson(
          data,
        );
        return employerModel;
      });
}

Future<AddEmploymentResponseModel?> save_employment(Map map) async {
  print("#adding employment");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/createEmployer';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'Authorization': 'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(const Duration(seconds: 6));

    print(response.body);
    if (response.statusCode == 200) {
      AddEmploymentResponseModel userModel =
          AddEmploymentResponseModel.fromJson(json.decode(response.body));
      return userModel;
    } else {
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

Future<PaymentResponse?> initialise_payment(Map map) async {
  print("#adding initialisePayment");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}sandbox/init/authenticate/merchant/wallet';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'Authorization': 'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(const Duration(seconds: 6));

    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      PaymentResponse paymentResponse = PaymentResponse.fromJson(
        json.decode(response.body),
      );
      return paymentResponse;
    } else {
      return null;
    }
  } on TimeoutException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
    return null;
  } on SocketException catch (e) {
    return null;
  } on Error catch (e) {
    if (kDebugMode) {
      print("error");
    }
    if (kDebugMode) {
      print(e.stackTrace);
    }
    return null;
  }
}

Future<UpdateSalaryPayDayResponse?> update_pay_day(Map map) async {
  print("#updating payday");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/updateSalaryPayDay';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'Authorization': 'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(const Duration(seconds: 6));
    print(response.body);
    if (response.statusCode == 200) {
      UpdateSalaryPayDayResponse userModel =
          UpdateSalaryPayDayResponse.fromJson(json.decode(response.body));
      return userModel;
    } else {
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

void LogPrint(Object object) async {
  int defaultPrintLength = 1020;
  if (object == null || object.toString().length <= defaultPrintLength) {
    print(object);
  } else {
    String log = object.toString();
    int start = 0;
    int endIndex = defaultPrintLength;
    int logLength = log.length;
    int tmpLogLength = log.length;
    while (endIndex < logLength) {
      print(log.substring(start, endIndex));
      endIndex += defaultPrintLength;
      start += defaultPrintLength;
      tmpLogLength -= defaultPrintLength;
    }
    if (tmpLogLength > 0) {
      print(log.substring(start, logLength));
    }
  }
}

Future<Stream<CreditApplication>> getCreditApplications() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/customer/creditApplications/${currentuser.value.user?.id}';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  print("--------------------------------------------------------");
  LogPrint(currentuser.value.token ?? "");
  print("--------------------------------------------------------");
  final streamedRest = await client.send(request);
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) {
        print('getData ${data}');
        return Helper.getData(data);
      })
      .expand((data) => (data as List))
      .map((data) {
        CreditApplication employerModel = CreditApplication.fromJson(data);
        return employerModel;
      });
}

Future<ConfirmOtpResult?> confirmQRCode(Map map) async {
  print("# confirmQRCode");
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/customer/appVerify';
  final client = new http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'Authorization': 'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(const Duration(seconds: 6));
    print(response.body);
    if (response.statusCode == 200) {
      ConfirmOtpResult userModel = ConfirmOtpResult.fromJson(
        json.decode(response.body),
      );
      return userModel;
    } else {
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
