import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/employment/EmploymentHistoryWidget.dart';
import 'package:smacredit/src/employment/controllers/EmploymentController.dart';

import '../helpers/Validator.dart';
import '../models/constants.dart';

class SelectCompanyWidget extends StatefulWidget {
  const SelectCompanyWidget({Key? key}) : super(key: key);

  @override
  _SelectCompanyWidgetState createState() => _SelectCompanyWidgetState();
}

class _SelectCompanyWidgetState extends StateMVC<SelectCompanyWidget> {
  late EmploymentController _con;

  _SelectCompanyWidgetState() : super(EmploymentController()) {
    _con = controller as EmploymentController;
  }

  String searchValue = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.listenForEmployerList();
  }

  getList() {
    if (searchValue.isNotEmpty) {
      return _con.employers
          .where(
            (element) => (element.tradingName ?? "").toLowerCase().contains(
              searchValue.toLowerCase(),
            ),
          )
          .toList();
    }
    return _con.employers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Add employment",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Center(
                child: Text(
                  "Search for your company",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "To continue please search and select the company you work for",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                onSaved: (value) {
                  searchValue = value!;
                },
                onChanged: (v) {
                  setState(() {
                    searchValue = v;
                  });
                },
                validator: (value) {
                  return Validator.validateRequired(value);
                },
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),

                    borderSide: BorderSide(
                      color: Constants.greyColor.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),

                    borderSide: BorderSide(
                      color: Constants.greyColor.withValues(alpha: 0.2),
                    ),
                  ),
                  filled: true,
                  hintStyle: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: "Search companies",
                  fillColor: Constants.textFieldColor,
                ),
              ),
              const SizedBox(height: 12),
              ...getList().map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/AddEmployer',
                        arguments: e,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            // Container(
                            //   height: 50,
                            //   width: 80,

                            //   decoration: BoxDecoration(
                            //     image: DecorationImage(
                            //       image: NetworkImage(
                            //         e.accountMerchantLogo ?? "",
                            //       ),
                            //       fit: BoxFit.contain,
                            //     ),
                            //   ),
                            // ),
                            SafeNetworkImage(
                              imageUrl: e.accountMerchantLogo ?? "",
                              height: 50,
                              width: 80,
                            ),
                            SizedBox(width: 3),
                            Container(
                              width: 1,
                              height: 50,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    //                   <--- left side
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.tradingName ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "7928 Zimre drive, Zimre park Harare",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
