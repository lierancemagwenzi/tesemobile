// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/auth/models/RegDetailsModel.dart';
// import 'package:smacredit/src/auth/models/RegistrationDocumentsModel.dart';
// import 'package:smacredit/src/repositories/user_repository.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';

// import '../../../helpers/Validator.dart';
// import '../../../models/constants.dart';
// import '../../../widgets/CustomButtons.dart';
// import '../../controller/LoginController.dart';

// class RegisterDetailsWidget extends StatefulWidget {
//   RegDetailsModel regDetailsModel;
//   RegistrationDocumentsModel registrationDocumentsModel;

//   RegisterDetailsWidget({
//     super.key,
//     required this.registrationDocumentsModel,
//     required this.regDetailsModel,
//   });

//   @override
//   _RegisterDetailsWidgetState createState() => _RegisterDetailsWidgetState();
// }

// class _RegisterDetailsWidgetState extends StateMVC<RegisterDetailsWidget> {
//   final _formKey = GlobalKey<FormState>();

//   String password = '';
//   String phone = '';
//   String email = '';

//   String password2 = '';
//   bool checkedValue = true;
//   bool hidePassword = true;

//   late LoginController _con;

//   _RegisterDetailsWidgetState() : super(LoginController()) {
//     _con = controller as LoginController;
//   }

//   @override
//   initState() {
//     super.initState();
//     email = current_registration_email.value;
//   }

//   buttons() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomButtons.filledButton(
//               text: 'Next',
//               callback: () {
//                 if (_formKey.currentState!.validate()) {
//                   _formKey.currentState!.save();
//                   if (checkedValue == true) {
//                     // Navigator.pushNamed(context, '/OTP');
//                     Map map = {
//                       "name": widget.regDetailsModel.firstName,
//                       "lastname": widget.regDetailsModel.lastName,
//                       "email": email,
//                       "phone": phone,
//                       "gender": widget.regDetailsModel.gender,
//                       "nationality": widget
//                           .registrationDocumentsModel
//                           .country
//                           ?.displayName,
//                       "national_identification_type_id":
//                           widget.registrationDocumentsModel.type == "idcard"
//                           ? 1
//                           : 2,
//                       "national_identification_type":
//                           widget.registrationDocumentsModel.type == "idcard"
//                           ? "National ID"
//                           : "Passport",
//                       "national_identification":
//                           widget.regDetailsModel.nationalIdentification,
//                       "password": password,
//                       "title": widget.regDetailsModel.title,
//                       "selfie":
//                           widget.registrationDocumentsModel.selfie.fileLink,
//                       "national_id_front":
//                           widget.registrationDocumentsModel.idFront?.fileLink,
//                       "national_id_back":
//                           widget.registrationDocumentsModel.idBack?.fileLink,

//                       "dateOfBirth": widget.regDetailsModel.dob,
//                       "province": widget.regDetailsModel.province,
//                       "tradingName": widget.regDetailsModel.tradingName,
//                       "businessDescription":
//                           widget.regDetailsModel.businessDescription,
//                       "telephoneNumber": phone,
//                       "tradingAddress": widget.regDetailsModel.tradingAddress,
//                     };
//                     if (_con.loading) {
//                       return;
//                     }
//                     _con.registerTheUser(map);
//                   }
//                 }
//               },
//             ),
//             const SizedBox(height: 16),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomOverlay(
//       loading: _con.loading,
//       child: Scaffold(
//         key: _con.scaffoldKey,
//         backgroundColor: Colors.white,
//         bottomNavigationBar: buttons(),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: const BackButton(color: Constants.greyColor),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Center(
//                     child: Text(
//                       "Almost there!",
//                       style: Theme.of(context).textTheme.headlineLarge!
//                           .copyWith(color: Constants.primaryColor),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Center(
//                     child: Text(
//                       "Register",
//                       style: Theme.of(
//                         context,
//                       ).textTheme.titleLarge!.copyWith(color: Colors.black),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Center(
//                     child: Text(
//                       "Enter your email address, phone number and create a strong password. We will use this information to keep your account secure",
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodyMedium!.copyWith(color: Colors.black),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   const SizedBox(height: 48),

//                   TextFormField(
//                     onSaved: (value) {
//                       email = value!;
//                     },
//                     validator: (value) {
//                       return Validator.validateEmail(value);
//                     },
//                     readOnly: true,
//                     initialValue: email,
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodyMedium!.copyWith(color: Colors.black),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),

//                         borderSide: const BorderSide(
//                           color: Constants.greyColor,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),

//                         borderSide: const BorderSide(
//                           color: Constants.greyColor,
//                         ),
//                       ),
//                       filled: true,
//                       hintStyle: TextStyle(
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w500,
//                       ),
//                       hintText: "Email",
//                       fillColor: Constants.textFieldColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     onSaved: (value) {
//                       phone = value!;
//                     },
//                     validator: (value) {
//                       return Validator.validatePhone(value);
//                     },
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodyMedium!.copyWith(color: Colors.black),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),

//                         borderSide: const BorderSide(
//                           color: Constants.greyColor,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),

//                         borderSide: const BorderSide(
//                           color: Constants.greyColor,
//                         ),
//                       ),
//                       filled: true,
//                       hintStyle: TextStyle(
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w500,
//                       ),
//                       hintText: "Phone number",
//                       fillColor: Constants.textFieldColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     onSaved: (value) {
//                       password = value!;
//                     },
//                     validator: (value) {
//                       return Validator.validatePassword(value);
//                     },
//                     obscureText: hidePassword,
//                     onChanged: (v) {
//                       setState(() {
//                         password = v;
//                       });
//                     },
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodyMedium!.copyWith(color: Colors.black),
//                     decoration: InputDecoration(
//                       suffixIcon: InkWell(
//                         onTap: () {
//                           setState(() {
//                             hidePassword = !hidePassword;
//                           });
//                         },

//                         child: Icon(
//                           hidePassword
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: Colors.grey,
//                         ),
//                       ),

//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),

//                         borderSide: const BorderSide(
//                           color: Constants.greyColor,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),

//                         borderSide: const BorderSide(
//                           color: Constants.greyColor,
//                         ),
//                       ),
//                       filled: true,
//                       hintStyle: TextStyle(
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w500,
//                       ),
//                       hintText: "Password",
//                       fillColor: Constants.textFieldColor,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     onSaved: (value) {
//                       password2 = value!;
//                     },
//                     validator: (value) {
//                       return Validator.validateConfirmPassword(password, value);
//                     },
//                     obscureText: hidePassword,
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodyMedium!.copyWith(color: Colors.black),
//                     decoration: InputDecoration(
//                       suffixIcon: InkWell(
//                         onTap: () {
//                           setState(() {
//                             hidePassword = !hidePassword;
//                           });
//                         },

//                         child: Icon(
//                           hidePassword
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: Colors.grey,
//                         ),
//                       ),

//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),

//                         borderSide: const BorderSide(
//                           color: Constants.greyColor,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),

//                         borderSide: const BorderSide(
//                           color: Constants.greyColor,
//                         ),
//                       ),
//                       filled: true,
//                       hintStyle: TextStyle(
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w500,
//                       ),
//                       hintText: "Verify password",
//                       fillColor: Constants.textFieldColor,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // CheckboxListTile(
//                   //   title: Text(
//                   //     "I agree to SmatPay terms and conditions",
//                   //     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                   //       color: Constants.greyColor,
//                   //     ),
//                   //   ),
//                   //   value: checkedValue,

//                   //   onChanged: (newValue) {
//                   //     setState(() {
//                   //       checkedValue = newValue!;
//                   //     });
//                   //   },
//                   //   controlAffinity: ListTileControlAffinity
//                   //       .leading, //  <-- leading Checkbox
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/models/RegDetailsModel.dart';
import 'package:smacredit/src/auth/models/RegistrationDocumentsModel.dart';
import 'package:smacredit/src/repositories/settings_repository.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import '../../../helpers/Validator.dart';
import '../../../widgets/CustomButtons.dart';
import '../../controller/LoginController.dart';

class RegisterDetailsWidget extends StatefulWidget {
  final RegDetailsModel regDetailsModel;
  final RegistrationDocumentsModel registrationDocumentsModel;

  const RegisterDetailsWidget({
    super.key,
    required this.registrationDocumentsModel,
    required this.regDetailsModel,
  });

  @override
  _RegisterDetailsWidgetState createState() => _RegisterDetailsWidgetState();
}

class _RegisterDetailsWidgetState extends StateMVC<RegisterDetailsWidget> {
  final _formKey = GlobalKey<FormState>();

  // Brand Colors
  final Color brandGreen = const Color(0xFF679E4F);
  final Color primaryDark = const Color(0xFF1A0B2E);

  String password = '';
  String phone = '';
  String email = '';
  String password2 = '';
  bool checkedValue = true;
  bool hidePassword = true;

  late LoginController _con;

  _RegisterDetailsWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  @override
  void initState() {
    super.initState();
    email = current_registration_email.value;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildGlassForm(isDark),
                      ),
                    ),
                    _buildNextButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned(
      top: -50,
      right: -50,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: brandGreen.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildGlassForm(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.05 : 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),

                // Email (Read Only)
                _buildTextField(
                  hint: "Email",
                  icon: Icons.email_outlined,
                  initialValue: email,
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                // Phone
                _buildTextField(
                  hint: "Phone Number",
                  icon: Icons.phone_android_outlined,
                  onSaved: (v) => phone = v!,
                  validator: (v) => Validator.validatePhone(v),
                ),
                const SizedBox(height: 16),

                // Password
                _buildTextField(
                  hint: "Create Password",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  onChanged: (v) => password = v,
                  onSaved: (v) => password = v!,
                  validator: (v) => Validator.validatePassword(v),
                ),
                const SizedBox(height: 16),

                // Verify Password
                _buildTextField(
                  hint: "Confirm Password",
                  icon: Icons.verified_user_outlined,
                  isPassword: true,
                  onSaved: (v) => password2 = v!,
                  validator: (v) =>
                      Validator.validateConfirmPassword(password, v),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "ALMOST THERE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Set up your secure credentials to finish creating your Tese Africa account.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool readOnly = false,
    String? initialValue,
    bool isPassword = false,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      readOnly: readOnly,
      initialValue: initialValue,
      obscureText: isPassword && hidePassword,
      onSaved: onSaved,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: readOnly ? Colors.white38 : Colors.white),
      cursorColor: brandGreen,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white30, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  hidePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white30,
                  size: 20,
                ),
                onPressed: () => setState(() => hidePassword = !hidePassword),
              )
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: brandGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CustomButtons.filledButton(
        text: waiting_period.value?.status == true
            ? 'JOIN WAITING LIST'
            : 'COMPLETE REGISTRATION',
        callback: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            Map<String, dynamic> registrationMap = {
              "name": widget.regDetailsModel.firstName,
              "lastname": widget.regDetailsModel.lastName,
              "email": email,
              "country_id": widget.regDetailsModel.country?.id,
              "phone": phone,
              "accept_terms": true,
              "gender": widget.regDetailsModel.gender,
              "nationality": widget.registrationDocumentsModel.country?.name,
              "national_identification_type_id":
                  widget.registrationDocumentsModel.type == "idcard" ? 1 : 2,
              "national_identification_type":
                  widget.registrationDocumentsModel.type == "idcard"
                  ? "National ID"
                  : "Passport",
              "national_identification":
                  widget.regDetailsModel.nationalIdentification,
              "password": password,
              "title": widget.regDetailsModel.title,
              "selfie": widget.registrationDocumentsModel.selfie.fileLink,
              "national_id_front":
                  widget.registrationDocumentsModel.idFront?.fileLink,
              "national_id_back":
                  widget.registrationDocumentsModel.idBack?.fileLink,
              "dateOfBirth": widget.regDetailsModel.dob,
              "province": widget.regDetailsModel.province,
              "tradingName": widget.regDetailsModel.tradingName,
              "businessDescription": widget.regDetailsModel.businessDescription,
              "telephoneNumber": phone,
              "tradingAddress": widget.regDetailsModel.tradingAddress,
            };

            if (!_con.loading) {
              _con.registerTheUser(registrationMap);
            }
          }
        },
      ),
    );
  }
}
