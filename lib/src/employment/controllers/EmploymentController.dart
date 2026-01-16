import 'dart:convert';
import 'dart:io';
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
import 'package:smacredit/src/auth/models/ExtractIDModel.dart';
import 'package:smacredit/src/auth/models/UploadIDModel.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:smacredit/src/employment/repository/employer_repository.dart';
import '../../helpers/Message.dart';
import '../models/EmploymentTypeModel.dart';


class EmploymentController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool loading = false;
List<CustomerEmployerModel> customers_employers=[];
  List<EmployerModel> employers=[];
List<EmploymentTypeModel> employmentTypes=[];
  EmploymentController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  Future<void> listenForEmployerList() async {

    setState(() {

      loading=true;
    });
    employers.clear();
    final Stream<EmployerModel> stream = await get_employer_list();

    stream.listen((EmployerModel employerModel) {
      setState(() => employers.add(employerModel));
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
  Future<void> listenForEmploymentTypes() async {

    setState(() {
      loading=true;
    });
    employmentTypes.clear();
    final Stream<EmploymentTypeModel> stream = await get_employment_types();

    stream.listen((EmploymentTypeModel employerModel) {
      setState(() => employmentTypes.add(employerModel));
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
  void addEmployment(Map map) {
    setState(() {
      loading = true;
    });
    save_employment(map).then((value) async {
      if (value != null) {
        print(value.toJson());
        setState(() {
          loading = false;
        });
        Navigator.pushNamed(scaffoldKey.currentContext!, '/PendingVerification');
;

      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(scaffoldKey.currentContext!, "Something went wrong.Try again");
      }
    });
  }

  Future<void> listenForCustomerEmployers() async {

    setState(() {
      loading=true;
    });
    customers_employers.clear();
    final Stream<CustomerEmployerModel> stream = await get_customer_employers();

    stream.listen((CustomerEmployerModel employerModel) {
      setState(() => customers_employers.add(employerModel));
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

  // load(){
  //   employers.add(EmployerModel(id: 1,name: "FBC Holdings"));
  //   employers.add(EmployerModel(id: 2,name: "CBZ"));
  //   setState(() { });
  // }


  // loadEmploymentTypes(){
  //   employmentTypes.add(EmploymentTypeModel(id: 1,employmentTypeName: "Part time"));
  //   employmentTypes.add(EmploymentTypeModel(id: 2,employmentTypeName: "Full time"));
  //   setState(() { });
  // }

  loadCustomEmployers(){
    // customers_employers.add(CustomerEmployerModel(id: 1,name: "FBC"));
    // customers_employers.add(CustomerEmployerModel(id: 2,name: "CBZ"));
    // setState(() { });
  }
}