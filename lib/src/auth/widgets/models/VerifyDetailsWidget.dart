import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/models/ExtractIDModel.dart';
import 'package:smacredit/src/auth/models/RegDetailsModel.dart';
import 'package:smacredit/src/auth/widgets/models/RegisterDetailsWidget.dart';
import 'package:smacredit/src/auth/widgets/models/id_details.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../../../helpers/Message.dart';
import '../../../helpers/Validator.dart';
import '../../../models/constants.dart';
import '../../../widgets/CustomButtons.dart';
import '../../controller/LoginController.dart';
import '../../models/RegistrationDocumentsModel.dart';

class VerifyDetailsWidget extends StatefulWidget {
  RegistrationDocumentsModel registrationDocumentsModel;
  VerifyDetailsWidget({Key? key, required this.registrationDocumentsModel})
    : super(key: key);

  @override
  _VerifyDetailsWidgetState createState() => _VerifyDetailsWidgetState();
}

class _VerifyDetailsWidgetState extends StateMVC<VerifyDetailsWidget> {
  late LoginController _con;

  _VerifyDetailsWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  final _formKey = GlobalKey<FormState>();

  String view = 'first_screen'; //second_screen
  DateTime? selectedDate;
  String firstName = '';
  String lastName = '';
  String nationality = '';
  String idNumber = '';
  String gender = 'Male';
  String dob = '';
  String title = 'Mr';

  String province = '';
  String tradingName = '';
  String businessDescription = '';
  String telephoneNumber = '';
  String tradingAddress = '';

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  TextEditingController nationalityController = TextEditingController();

  TextEditingController idNumberController = TextEditingController();

  TextEditingController genderController = TextEditingController();

  TextEditingController dobController = TextEditingController();

  TextEditingController provinceController = TextEditingController(
    text: 'Harare',
  );
  TextEditingController tradingNameController = TextEditingController();
  TextEditingController businessDescriptionController = TextEditingController();
  TextEditingController telephoneNumberController = TextEditingController();
  TextEditingController tradingAddressController = TextEditingController();

  buttons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButtons.filledButton(
              text: 'Next',
              callback: () {
                if (_con.loading) {
                  return;
                }
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  if (1 == 2 && view == 'first_screen') {
                    setState(() {
                      view = 'second_screen';
                    });
                    return;
                  }

                  if (widget.registrationDocumentsModel.country != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterDetailsWidget(
                          registrationDocumentsModel:
                              widget.registrationDocumentsModel,
                          regDetailsModel: RegDetailsModel(
                            firstName: firstName,
                            lastName: lastName,
                            gender: gender,
                            nationality: nationality,
                            title: title,
                            dob: dob,
                            nationalIdentification: idNumber,
                            country: widget.registrationDocumentsModel.country,
                            province: 'Harare',
                            tradingAddress: tradingAddress,
                            tradingName: '${firstName}${lastName}',
                            telephoneNumber: '',
                            businessDescription: '${firstName}${lastName}',
                          ),
                        ),
                      ),
                    );
                  } else {
                    CustomMessageHandler().showErrorSnakeBar(
                      _con.scaffoldKey.currentContext!,
                      "Nationality is required",
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    extract();
  }

  extract() async {
    IdDetails? extractIdModel = id_details.value;
    if (extractIdModel != null) {
      firstNameController = TextEditingController(text: '');

      try {
        if (extractIdModel.dob != null) {
          DateTime? birthDate = DateFormat(
            'dd/MM/yyyy',
          ).parse(extractIdModel.dob!);
          dobController.text = DateFormat("yyyy-MM-dd").format(birthDate);
        }
      } catch (e) {
        print(e);
      }

      lastNameController = TextEditingController(text: '');

      nationalityController = TextEditingController(text: '');

      idNumberController = TextEditingController(text: extractIdModel.idNumber);

      genderController = TextEditingController(text: '');

      setState(() {});
    } else {
      if (kDebugMode) {
        print("null value");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Colors.black,
        bottomNavigationBar: buttons(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Constants.greyColor),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Verify details",
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(color: Constants.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Register",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Please check if the following information is correct and proceed to complete registration",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (view == 'first_screen') ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Title",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                        ),
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
                            child: DropdownButton<String>(
                              hint: Text(
                                "Title",
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: Colors.black),
                              ),
                              value: title,
                              items: ["Mr", "Mrs", "Ms", "Dr"].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? val) {
                                setState(() {
                                  title = val!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      onSaved: (value) {
                        firstName = value!;
                      },
                      controller: firstNameController,
                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "First name",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      onSaved: (value) {
                        lastName = value!;
                      },
                      controller: lastNameController,

                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "Last name",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: idNumberController,
                      // readOnly: id_details.value?.idNumber != null,
                      onSaved: (value) {
                        idNumber = value!;
                      },
                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "ID number",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gender",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                        ),
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
                            child: DropdownButton<String>(
                              hint: Text(
                                "Gender",
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: Colors.black),
                              ),
                              value: gender,
                              items: ["Male", "Female"].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? val) {
                                setState(() {
                                  gender = val!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      onSaved: (value) {
                        tradingAddress = value!;
                      },
                      controller: tradingAddressController,
                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "Residential address",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      child: Container(
                        child: TextFormField(
                          controller: dobController,
                          onTap: () {
                            // if (id_details.value?.dob != null) {
                            //   return;
                            // }
                            DatePicker.showDatePicker(
                              context,
                              showTitleActions: true,
                              minTime: DateTime.now().subtract(
                                Duration(days: 36500),
                              ),

                              maxTime: DateTime.now().subtract(
                                Duration(days: 6570),
                              ),
                              onChanged: (date) {
                                if (kDebugMode) {
                                  print('change $date');
                                }
                              },
                              onConfirm: (date) {
                                dobController.text = DateFormat(
                                  "yyyy-MM-dd",
                                ).format(date);
                                setState(() {
                                  selectedDate = date;
                                });
                                if (kDebugMode) {
                                  print('confirm $date');
                                }
                              },
                              currentTime: DateTime.now().add(
                                Duration(hours: 2),
                              ),
                              locale: LocaleType.en,
                            );
                          },
                          onSaved: (value) {
                            dob = value!;
                          },

                          readOnly: true,
                          validator: (value) {
                            return Validator.validateRequired(value);
                          },
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),

                              borderSide: const BorderSide(
                                color: Constants.greyColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),

                              borderSide: const BorderSide(
                                color: Constants.greyColor,
                              ),
                            ),
                            filled: true,
                            hintStyle: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: "Date of birth",
                            fillColor: Constants.textFieldColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      onSaved: (value) {
                        tradingName = value!;
                      },
                      controller: tradingNameController,
                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "Trading name",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      onSaved: (value) {
                        businessDescription = value!;
                      },
                      controller: businessDescriptionController,
                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "Business description",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      onSaved: (value) {
                        telephoneNumber = value!;
                      },
                      controller: telephoneNumberController,
                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "Telephone number",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      onSaved: (value) {
                        province = value!;
                      },
                      controller: provinceController,
                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "Province",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      onSaved: (value) {
                        tradingAddress = value!;
                      },
                      controller: tradingAddressController,
                      validator: (value) {
                        return Validator.validateRequired(value);
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),

                          borderSide: const BorderSide(
                            color: Constants.greyColor,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "Trading address",
                        fillColor: Constants.textFieldColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
