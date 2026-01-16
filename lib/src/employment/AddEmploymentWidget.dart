import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:smacredit/src/employment/models/EmploymentTypeModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../helpers/Validator.dart';
import '../models/constants.dart';
import '../widgets/CustomButtons.dart';
import 'controllers/EmploymentController.dart';

class AddEmploymentWidget extends StatefulWidget {
  EmployerModel employerModel;
  AddEmploymentWidget({Key? key, required this.employerModel})
    : super(key: key);

  @override
  _AddEmploymentWidgetState createState() => _AddEmploymentWidgetState();
}

class _AddEmploymentWidgetState extends StateMVC<AddEmploymentWidget> {
  final _formKey = GlobalKey<FormState>();

  late EmploymentController _con;

  _AddEmploymentWidgetState() : super(EmploymentController()) {
    _con = controller as EmploymentController;
  }

  String employer_name = "";
  String current_position = "";
  String gross_income = "";
  String net_incmome = "";
  String other_income = "";

  EmploymentTypeModel? employmentTypeModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.listenForEmploymentTypes();
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButtons.filledButton(
                  text: 'Save information',
                  callback: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (employmentTypeModel != null) {
                        _con.addEmployment({
                          "id": null,
                          "userId": currentuser.value.user?.id,
                          "employerName": widget.employerModel.tradingName,
                          "employerMerchantId":
                              widget.employerModel.accountMerchantId,
                          "employmentType":
                              employmentTypeModel?.employmentTypeName,
                          "employerCurrentPosition": current_position,
                          "employerGrossMonthlyIncome": gross_income,
                          "employerNetMonthlyIncome": net_incmome,
                          "employerOtherIncome": other_income,
                          "employerLogo":
                              widget.employerModel.accountMerchantLogo,
                        });

                        print(map);
                      } else {}
                    }
                  },
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        key: _con.scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black),
          title: Text(
            widget.employerModel.tradingName ?? "",
            style: TextStyle(color: Colors.black),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 70,
                        width: 80,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.employerModel.accountMerchantLogo ?? "",
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
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
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.employerModel.tradingName ?? "",
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 5),

                            // Text("7928 Zimre drive, Zimre park Harare",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Enter employment details",
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 5),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 5),
                          Text(
                            "Since you have selected ${widget.employerModel.tradingName} please enter employment details to proceed",
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  1 == 1
                      ? DropdownButtonFormField<EmploymentTypeModel>(
                          initialValue: employmentTypeModel,
                          hint: const Text(
                            'Employment type',
                            style: TextStyle(
                              color: Colors.black, // Match the dark text color
                              fontSize: 16,
                            ),
                          ),
                          decoration: InputDecoration(
                            // 1. Styling the Border
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Rounded corners
                              borderSide: BorderSide(
                                color: Colors
                                    .grey
                                    .shade400, // Light grey border color
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color:
                                    Colors.black, // Darker border when focused
                                width: 1.5,
                              ),
                            ),
                            // 2. Hide the default label floating above the field
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            // 3. Optional: Set background color if desired
                            fillColor: Colors.white,
                            filled: true,
                          ),

                          // 4. Customizing the Dropdown Icon
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black, // Dark icon color
                            size: 28,
                          ),

                          // 5. Build the list of items
                          items: _con.employmentTypes.map((
                            EmploymentTypeModel value,
                          ) {
                            return DropdownMenuItem<EmploymentTypeModel>(
                              value: value,
                              child: Text(value.employmentTypeName ?? ''),
                            );
                          }).toList(),

                          onChanged: (EmploymentTypeModel? newValue) {
                            setState(() {
                              employmentTypeModel = newValue;
                              print('Selected: $employmentTypeModel');
                            });
                          },
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Employment type",
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: Colors.black),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 70,
                              width: double.infinity,
                              // height: ScreenUtil().setHeight(48),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton<EmploymentTypeModel>(
                                  hint: Text(
                                    "Employment type",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: Colors.black),
                                  ),
                                  value: employmentTypeModel,
                                  items: _con.employmentTypes.map((
                                    EmploymentTypeModel value,
                                  ) {
                                    return DropdownMenuItem<
                                      EmploymentTypeModel
                                    >(
                                      value: value,
                                      child: Text(
                                        value.employmentTypeName ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (EmploymentTypeModel? val) {
                                    setState(() {
                                      employmentTypeModel = val!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                  // const SizedBox(height: 12,),

                  // TextFormField(
                  //   onSaved: (value){
                  //
                  //     employer_name=value!;
                  //   },
                  //   validator: (value){
                  //     return Validator.validateRequired(value);
                  //   },
                  //   style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10.0),
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10.0),
                  //
                  //       borderSide: const BorderSide(
                  //         color: Constants.greyColor,
                  //       ),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10.0),
                  //
                  //       borderSide: const BorderSide(
                  //         color: Constants.greyColor,
                  //       ),
                  //     ),
                  //     filled: true,
                  //     hintStyle: TextStyle(color: Colors.grey[800],fontWeight: FontWeight.w500),
                  //     hintText: "Employer name",
                  //     fillColor: Constants.textFieldColor,
                  //   ),
                  // ),
                  const SizedBox(height: 12),

                  TextFormField(
                    onSaved: (value) {
                      current_position = value!;
                    },
                    validator: (value) {
                      return Validator.validateRequired(value);
                    },
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "Current position",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onSaved: (value) {
                      gross_income = value!;
                    },
                    validator: (value) {
                      return Validator.validateNum(value);
                    },
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "Gross income",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onSaved: (value) {
                      net_incmome = value!;
                    },
                    validator: (value) {
                      return Validator.validateNum(value);
                    },
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "Net income",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    onSaved: (value) {
                      other_income = value!;
                    },
                    validator: (value) {
                      return Validator.validateNum(value);
                    },
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),

                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: "Other income",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
