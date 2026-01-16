import 'dart:async';
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
import 'package:smacredit/src/auth/models/VerifyOTPModel.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:smacredit/src/employment/repository/employer_repository.dart';
import 'package:smacredit/src/expenses/models/ExpenseModel.dart';
import 'package:smacredit/src/expenses/repository/expense_repository.dart';
import '../../helpers/Message.dart';


class ExpenseController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool loading = false;

  List<ExpenseModel> expenses=[];
  ExpenseModel? expenseModel;
  ExpenseController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  Future<void> listenForEmployerList() async {

    setState(() {

      loading=true;
    });
    expenses.clear();
    final Stream<ExpenseModel> stream = await get_expenses_list();

    stream.listen((ExpenseModel employerModel) {
      setState(() => expenses.add(employerModel));
    }, onError: (a) {
      setState(() {
        loading=false;
      });
      print(a);
    }, onDone: () {
      setState(() {
        loading=false;

        if(expenses.isNotEmpty){
          expenseModel=expenses[0];
        }
      });
    });
  }
  void addExpense(Map map) {
    setState(() {
      loading = true;
    });
    add_expense(map).then((value) async {
      if (value != null) {

        print(value.toJson());
        setState(() {
          loading = false;
        });
        Navigator.pop(scaffoldKey.currentContext!,"Expense added");

      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(scaffoldKey.currentContext!, "Something went wrong.Try again");
      }
    });
  }
  void updateExpense(Map map) {
    setState(() {
      loading = true;
    });
    update_expense(map).then((value) async {
      if (value != null) {

        print(value.toJson());
        setState(() {
          loading = false;
        });

        Navigator.pop(scaffoldKey.currentContext!,"Expense updated");
      } else {
        setState(() {
          loading = false;
        });
        CustomMessageHandler().showErrorSnakeBar(scaffoldKey.currentContext!, "Something went wrong.Try again");
      }
    });
  }
}