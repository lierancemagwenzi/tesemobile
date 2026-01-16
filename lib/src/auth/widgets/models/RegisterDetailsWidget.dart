import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/models/RegDetailsModel.dart';
import 'package:smacredit/src/auth/models/RegistrationDocumentsModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../../../helpers/Validator.dart';
import '../../../models/constants.dart';
import '../../../widgets/CustomButtons.dart';
import '../../controller/LoginController.dart';

class RegisterDetailsWidget extends StatefulWidget {
  RegDetailsModel regDetailsModel;
  RegistrationDocumentsModel registrationDocumentsModel;

  RegisterDetailsWidget({
    Key? key,
    required this.registrationDocumentsModel,
    required this.regDetailsModel,
  }) : super(key: key);

  @override
  _RegisterDetailsWidgetState createState() => _RegisterDetailsWidgetState();
}

class _RegisterDetailsWidgetState extends StateMVC<RegisterDetailsWidget> {
  final _formKey = GlobalKey<FormState>();

  String password = '';
  String phone = '';
  String email = '';

  String password2 = '';
  bool checkedValue = false;
  bool hidePassword = true;

  late LoginController _con;

  _RegisterDetailsWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  @override
  initState() {
    super.initState();
    email = current_registration_email.value;
  }

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
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (checkedValue == true) {
                    // Navigator.pushNamed(context, '/OTP');
                    Map map = {
                      "name": widget.regDetailsModel.firstName,
                      "lastname": widget.regDetailsModel.lastName,
                      "email": email,
                      "phone": phone,
                      "gender": widget.regDetailsModel.gender,
                      "nationality": widget
                          .registrationDocumentsModel
                          .country
                          ?.displayName,
                      "national_identification_type_id":
                          widget.registrationDocumentsModel.type == "idcard"
                          ? 1
                          : 2,
                      "national_identification_type":
                          widget.registrationDocumentsModel.type == "idcard"
                          ? "National ID"
                          : "Passport",
                      "national_identification":
                          widget.regDetailsModel.nationalIdentification,
                      "password": password,
                      "title": widget.regDetailsModel.title,
                      "selfie":
                          widget.registrationDocumentsModel.selfie.fileLink,
                      "national_id_front":
                          widget.registrationDocumentsModel.idFront?.fileLink,
                      "national_id_back":
                          widget.registrationDocumentsModel.idBack?.fileLink,

                      "dateOfBirth": widget.regDetailsModel.dob,
                      "province": widget.regDetailsModel.province,
                      "tradingName": widget.regDetailsModel.tradingName,
                      "businessDescription":
                          widget.regDetailsModel.businessDescription,
                      "telephoneNumber": phone,
                      "tradingAddress": widget.regDetailsModel.tradingAddress,
                    };
                    if (_con.loading) {
                      return;
                    }
                    _con.registerTheUser(map);
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
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Colors.white,
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
                      "Almost there!",
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
                      "Enter your email address, phone number and create a strong password. We will use this information to keep your account secure",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),

                  TextFormField(
                    onSaved: (value) {
                      email = value!;
                    },
                    validator: (value) {
                      return Validator.validateEmail(value);
                    },
                    readOnly: true,
                    initialValue: email,
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
                      hintText: "Email",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onSaved: (value) {
                      phone = value!;
                    },
                    validator: (value) {
                      return Validator.validatePhone(value);
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
                      hintText: "Phone number",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onSaved: (value) {
                      password = value!;
                    },
                    validator: (value) {
                      return Validator.validatePassword(value);
                    },
                    obscureText: hidePassword,
                    onChanged: (v) {
                      setState(() {
                        password = v;
                      });
                    },
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },

                        child: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),

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
                      hintText: "Password",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onSaved: (value) {
                      password2 = value!;
                    },
                    validator: (value) {
                      return Validator.validateConfirmPassword(password, value);
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
                      hintText: "Verify password",
                      fillColor: Constants.textFieldColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text(
                      "I agree to SmatPay terms and conditions",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Constants.greyColor,
                      ),
                    ),
                    value: checkedValue,

                    onChanged: (newValue) {
                      setState(() {
                        checkedValue = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, //  <-- leading Checkbox
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
