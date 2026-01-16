import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:smacredit/src/auth/repository/inteceptor.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:http/http.dart' as http;
import 'package:smacredit/src/employment/models/EmploymentTypeModel.dart';
import 'package:smacredit/src/home/models/DashboardModel.dart';
import 'package:smacredit/src/home/models/user_stats.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

import '../../auth/models/VerifyOTPModel.dart';
import '../../helpers/Helper.dart';
import '../models/ProfileModel.dart';

final http.Client client = RetryClient(
  http.Client(),
  // Or wherever your renewal endpoint is
);

Future<Stream<UserStatsModel?>> get_dashboard_info() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/dashboard-stats';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        try {
          UserStatsModel employerModel = UserStatsModel.fromJson(data);
          return employerModel;
        } catch (e, s) {
          print(e);
          print(s);

          return null;
        }
      });
}

Future<Stream<ProfileModel>> get_profile_info() async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}credit/api/customer/profile/${currentuser.value.user?.id}';
  print(url);
  final client = new http.Client();
  http.Request request = http.Request('get', Uri.parse(url));
  request.headers['Authorization'] = 'Bearer ${currentuser.value.token}';
  final streamedRest = await client.send(request);

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .map((data) {
        print(data);

        ProfileModel employerModel = ProfileModel.fromJson(data);
        return employerModel;
      });
}
