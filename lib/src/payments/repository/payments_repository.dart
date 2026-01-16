import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:smacredit/src/auth/repository/inteceptor.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/payments/models/bank_account.dart';
import 'package:smacredit/src/payments/models/currencyModel.dart';
import 'package:smacredit/src/payments/models/document_type.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'package:smacredit/src/payments/models/payout_model.dart';
import 'package:smacredit/src/payments/models/payout_response.dart';
import 'package:smacredit/src/payments/models/short_link.dart';
import 'package:smacredit/src/payments/models/transaction_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

import '../../helpers/Helper.dart';

final http.Client client = RetryClient(
  http.Client(),
  // Or wherever your renewal endpoint is
);

Future<User?> update_account(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/auth/update-account';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      User userModel = User.fromJson(json.decode(response.body));

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

Future<bool?> delete_payment_link(int id) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/delete-payment-link/$id';

  try {
    final response = await client
        .get(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
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

Future<ShortLinkModel?> generate_short_link(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/generate-short-link';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      ShortLinkModel userModel = ShortLinkModel.fromJson(
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

Future<ApiResponseModel?> payout_request(Map map) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/payout-request';

  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${currentuser.value.token}',
          },
          body: json.encode(map),
        )
        .timeout(Duration(seconds: 60));

    print(response.body);
    if (response.statusCode == 200) {
      ApiResponseModel userModel = ApiResponseModel.fromJson(
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

Future<Stream<CurrencyModel>> get_currencies() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/payment-links/currencies';
  print(url);

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
        CurrencyModel employerModel = CurrencyModel.fromJson(data);
        return employerModel;
      });
}

Future<Stream<PayoutModel>> get_payouts() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/payouts';
  print(url);

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
        PayoutModel employerModel = PayoutModel.fromJson(data);
        return employerModel;
      });
}

Future<Stream<DocumentTypeDetail>> get_document_types() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/document-types';
  print(url);

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
        DocumentTypeDetail employerModel = DocumentTypeDetail.fromJson(data);
        return employerModel;
      });
}

Future<Stream<BankAccount>> get_banks() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/account-banks';
  print(url);

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
        BankAccount employerModel = BankAccount.fromJson(data);
        return employerModel;
      });
}

Future<Stream<PaymentLinkModel>> get_payment_links() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/payment-links/all';
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) {
        return Helper.getData(data);
      })
      .expand((data) => (data as List))
      .map((data) {
        PaymentLinkModel employerModel = PaymentLinkModel.fromJson(data);
        return employerModel;
      });
}

Future<Stream<TransactionModel>> get_transactions() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/transactions/all';
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) {
        return Helper.getData(data);
      })
      .expand((data) => (data as List))
      .map((data) {
        TransactionModel employerModel = TransactionModel.fromJson(data);
        return employerModel;
      });
}

Future<PaymentLinkModel?> create_payment_link_with_file(
  Map map,
  File? files,
) async {
  var postUri = Uri.parse(
    "${GlobalConfiguration().getValue('api_base_url')}/payment-links/create-with-file",
  );
  const Duration timeoutDuration = Duration(seconds: 60);
  try {
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);

    Map<String, String> headers = {
      // 💡 Authorization header for Bearer tokens
      'Authorization': 'Bearer ${currentuser.value.token}',
    };

    // 4. Assign the headers to the request
    request.headers.addAll(headers);

    if (files != null) {
      request.fields['extension'] = files.path.split('.').last;
      File element = files;
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'Image',
        element.path,
        // contentType: MediaType.parse(mimeType!),
      );
      request.files.add(multipartFile);
    }
    request.fields['data'] = jsonEncode(map);
    Future<http.StreamedResponse> responseFuture = client.send(request);
    http.StreamedResponse response = await responseFuture.timeout(
      timeoutDuration,
      onTimeout: () {
        // This block is executed if the timeout occurs
        throw TimeoutException(
          'Request timed out after ${timeoutDuration.inSeconds} seconds.',
        );
      },
    );

    var responseB = await http.Response.fromStream(response);

    print(response.statusCode);
    if (response.statusCode == 200) {
      PaymentLinkModel uploadIdModel = PaymentLinkModel.fromJson(
        jsonDecode(responseB.body),
      );

      return uploadIdModel;
      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<bool?> upload_document(Map map, File files) async {
  var postUri = Uri.parse(
    "${GlobalConfiguration().getValue('api_base_url')}/upload-document",
  );
  const Duration timeoutDuration = Duration(seconds: 60);
  try {
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    request.fields['extension'] = files.path.split('.').last;
    File element = files;
    Map<String, String> headers = {
      // 💡 Authorization header for Bearer tokens
      'Authorization': 'Bearer ${currentuser.value.token}',
    };

    // 4. Assign the headers to the request
    request.headers.addAll(headers);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'Document',
      element.path,
      // contentType: MediaType.parse(mimeType!),
    );
    request.files.add(multipartFile);

    request.fields['data'] = jsonEncode(map);
    Future<http.StreamedResponse> responseFuture = client.send(request);
    http.StreamedResponse response = await responseFuture.timeout(
      timeoutDuration,
      onTimeout: () {
        throw TimeoutException(
          'Request timed out after ${timeoutDuration.inSeconds} seconds.',
        );
      },
    );
    var responseB = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      return true;
      // Navigator.pop(scaffoldKey.currentContext!,'Document uploaded!');
    } else {
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}
