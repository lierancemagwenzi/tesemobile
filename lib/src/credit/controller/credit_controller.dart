import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:smacredit/src/credit/models/CreditApplication.dart';
import 'package:smacredit/src/credit/models/PaymentResponse.dart';
import 'package:smacredit/src/employment/models/ConfirmOTPResult.dart';
import 'package:smacredit/src/employment/repository/employer_repository.dart';
import 'package:smacredit/src/home/models/ProfileModel.dart';
import 'package:smacredit/src/home/repository/dashboard_repository.dart';

class CreditController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool loading = false;
  List<CreditApplication> applications = [];

  ProfileModel? profileModel;
  CreditController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }
  Future<void> listenForApplications() async {
    setState(() {
      loading = true;
    });
    applications.clear();
    if (kDebugMode) {
      print("done_applications");
    }
    final Stream<CreditApplication> stream = await getCreditApplications();

    stream.listen(
      (CreditApplication employerModel) {
        setState(() => applications.add(employerModel));
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        if (kDebugMode) {
          print(a);
        }
      },
      onDone: () {
        if (kDebugMode) {
          print("done_applications ${applications.length}");
        }
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForProfileInfo() async {
    setState(() {
      loading = true;
    });
    final Stream<ProfileModel> stream = await get_profile_info();

    stream.listen(
      (ProfileModel employerModel) {
        setState(() {
          profileModel = employerModel;
        });
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        print(a);
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<ConfirmOtpResult?> scanToPay(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      ConfirmOtpResult? response = await confirmQRCode(map);
      setState(() {
        loading = false;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  Future<PaymentResponse?> initialisePayment(Map map) async {
    setState(() {
      loading = true;
    });

    PaymentResponse? response = await initialise_payment(map);

    setState(() {
      loading = false;
    });

    return response;
  }
}
