// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/payments/controller/payment_controller.dart';
// import 'package:smacredit/src/payments/models/bank_account.dart';
// import 'package:smacredit/src/payments/models/currencyModel.dart';
// import 'package:smacredit/src/profile/models/account_info.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';

// class UpdatePaymentProfileScreen extends StatefulWidget {
//   final AccountInfo accountInfo;
//   const UpdatePaymentProfileScreen({super.key, required this.accountInfo});

//   @override
//   _UpdatePaymentProfileScreenState createState() =>
//       _UpdatePaymentProfileScreenState();
// }

// class _UpdatePaymentProfileScreenState
//     extends StateMVC<UpdatePaymentProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   late PaymentController _con;

//   _UpdatePaymentProfileScreenState() : super(PaymentController()) {
//     _con = controller as PaymentController;
//   }
//   BankAccount? _selectedBank;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     _con.listenForBanks();
//     // _con.loadCustomEmployers();
//   }

//   // --- Controllers for all text fields ---
//   final TextEditingController _bankNameController = TextEditingController(
//     text: '',
//   );
//   final TextEditingController _bankBranchController = TextEditingController(
//     text: '',
//   );
//   final TextEditingController _bankAccountController = TextEditingController(
//     text: '',
//   );
//   final TextEditingController _tradingNameController = TextEditingController(
//     text: '',
//   );
//   final TextEditingController _bankAccountNamesController =
//       TextEditingController(text: '');
//   final TextEditingController _bankBICCodeController = TextEditingController(
//     text: '',
//   );
//   final TextEditingController _bankSwiftCodeController = TextEditingController(
//     text: '',
//   );

//   // --- Variables for dropdowns/date ---
//   String? _selectedTitle = 'Mr';
//   String? _selectedGender = 'Male';
//   String? _selectedProvince = 'Harare'; // Matches your data
//   String? _selectedCountry = 'Zimbabwe';
//   String? _selectedSector; // Assuming this is the 'Individual Business Sector'
//   DateTime? _dateOfBirth = DateTime.parse('1995-06-15');

//   // Mock Data for Dropdowns
//   final List<String> _titles = ['Mr', 'Ms', 'Mrs', 'Dr'];
//   final List<String> _genders = ['Male', 'Female', 'Other'];
//   final List<String> _provinces = [
//     'Harare',
//     'Bulawayo',
//     'Midlands',
//     'Manicaland',
//   ]; // Mock list
//   final List<String> _countries = [
//     'Zimbabwe',
//     'South Africa',
//     'Zambia',
//     'United Kingdom',
//   ]; // Mock list
//   final List<String> _sectors = [
//     'Videography',
//     'Marketing',
//     'Education',
//     'Technology',
//   ]; // Mock list

//   @override
//   void dispose() {
//     _bankNameController.dispose();
//     _bankBranchController.dispose();
//     _bankAccountController.dispose();
//     _tradingNameController.dispose();
//     _bankAccountNamesController.dispose();
//     _bankBICCodeController.dispose();
//     _bankSwiftCodeController.dispose();

//     super.dispose();
//   }

//   // --- Date Picker Helper ---
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _dateOfBirth ?? DateTime.now(),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != _dateOfBirth) {
//       setState(() {
//         _dateOfBirth = picked;
//       });
//     }
//   }

//   // --- Form Submission Logic (Placeholder) ---
//   void _submitForm() {
//     // Navigator.pop(context);
//     // return;
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       final formData = {
//         'paymentProfileBankId': _selectedBank?.id,
//         'paymentProfileId': widget.accountInfo.paymentProfile?.id,
//         // "individualMobile": _mobileNumberController.text,
//         // "contentCreatorID": int.tryParse(_creatorIdController.text),
//       };

//       _con.updateProfileBank(formData);

//       // _con.createBankAccount(formData);
//       if (kDebugMode) {
//         print('Updated Profile Data: $formData');
//       }
//       // Here, you'd send this data to your backend API
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomOverlay(
//       loading: _con.loading,
//       child: Scaffold(
//         key: _con.scaffoldKey,
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             children: [
//               _buildAppBar(),
//               widget.accountInfo.hasBank == false
//                   ? Expanded(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Form(
//                           key: _formKey,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Header Text
//                               _buildHeaderText(),
//                               const SizedBox(height: 30),

//                               if (_con.banks.isNotEmpty) ...[
//                                 _buildBanksDropdown(),
//                                 const SizedBox(height: 16),

//                                 if (_selectedBank != null) ...[
//                                   _buildTextField(
//                                     controller: _bankNameController,
//                                     label: 'Bank Name',
//                                     enabled: false,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   _buildTextField(
//                                     controller: _bankBranchController,
//                                     label: 'Bank Branch',
//                                     enabled: false,
//                                   ),

//                                   const SizedBox(height: 16),

//                                   // 3. Email (Matches Screenshot)
//                                   _buildTextField(
//                                     controller: _bankAccountController,
//                                     label: 'Account Number',
//                                     enabled: false,
//                                   ), // Disabled/pre-filled email
//                                   const SizedBox(height: 16),

//                                   // 4. Contact/Address Info
//                                   _buildTextField(
//                                     controller: _bankBICCodeController,
//                                     label: 'Bank BIC Code',
//                                     keyboardType: TextInputType.phone,
//                                     enabled: false,
//                                   ),

//                                   const SizedBox(height: 16),
//                                   _buildTextField(
//                                     controller: _bankSwiftCodeController,
//                                     label: 'Swift Code',
//                                     enabled: false,
//                                   ),
//                                   const SizedBox(height: 16),

//                                   // 7. Business Description (Matches Screenshot)
//                                   _buildTextField(
//                                     controller: _bankAccountNamesController,
//                                     label: 'Account Name',
//                                     enabled: false,
//                                   ),
//                                   const SizedBox(height: 16),
//                                 ],
//                                 // 9. Creator ID
//                                 const SizedBox(height: 30),

//                                 // 10. Next Button
//                                 _buildNextButton(),
//                                 const SizedBox(height: 30),
//                               ] else ...[
//                                 _buildAddButtonButton(),
//                               ],
//                               // 8. Sector (Matches Screenshot)
//                             ],
//                           ),
//                         ),
//                       ),
//                     )
//                   : Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             _buildHeaderText(),
//                             const SizedBox(height: 30),

//                             _buildInfoCard(
//                               title: 'Bank Name',
//                               content: widget.accountInfo.bank?.bankName ?? '',
//                             ),

//                             _buildInfoCard(
//                               title: 'Bank Branch',
//                               content:
//                                   widget.accountInfo.bank?.bankBranch ?? '',
//                             ),

//                             _buildInfoCard(
//                               title: 'Bank Currency',
//                               content:
//                                   widget.accountInfo.bank?.bankCurrency ?? '',
//                             ),

//                             _buildInfoCard(
//                               title: 'Bank Account Number',
//                               content:
//                                   widget.accountInfo.bank?.bankAccount ?? '',
//                             ),

//                             _buildInfoCard(
//                               title: 'Bank Account holder',
//                               content:
//                                   widget.accountInfo.bank?.bankAccountNames ??
//                                   '',
//                             ),

//                             _buildInfoCard(
//                               title: 'Bank Swift Code',
//                               content:
//                                   widget.accountInfo.bank?.bankSwiftCode ?? '',
//                             ),

//                             _buildInfoCard(
//                               title: 'Bank BIC Code',
//                               content:
//                                   widget.accountInfo.bank?.bankBICCode ?? '',
//                             ),

//                             _buildUpdateButton(widget.accountInfo.bank!),
//                           ],
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- Custom Widget Builders ---
//   Widget _buildInfoCard({
//     required String title,
//     required String content,
//     bool hideTitle = false,
//     VoidCallback? onTap,
//   }) {
//     return InkWell(
//       onTap: () {
//         if (onTap != null) {
//           onTap();
//         }
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (!hideTitle)
//               Text(
//                 title,
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//             if (!hideTitle) const SizedBox(height: 4),
//             Text(
//               content,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_new,
//                 size: 20,
//                 color: Colors.black,
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBanksDropdown() {
//     return DropdownButtonFormField<BankAccount>(
//       initialValue: _selectedBank,
//       decoration: InputDecoration(
//         labelText: 'Bank account Currency',
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//       items: _con.banks.map((BankAccount currency) {
//         return DropdownMenuItem<BankAccount>(
//           value: currency,
//           child: Text(currency.bankName ?? ''),
//         );
//       }).toList(),
//       onChanged: (BankAccount? newValue) {
//         _bankNameController.text = newValue?.bankName ?? '';
//         _bankBranchController.text = newValue?.bankBranch ?? '';
//         _bankAccountController.text = newValue?.bankAccount ?? '';
//         _bankAccountNamesController.text = newValue?.bankAccountNames ?? '';
//         _bankBICCodeController.text = newValue?.bankBICCode ?? '';
//         _bankSwiftCodeController.text = newValue?.bankSwiftCode ?? '';
//         setState(() {
//           _selectedBank = newValue;
//         });
//       },

//       validator: (value) => value == null ? 'Please select a currency' : null,
//     );
//   }

//   Widget _buildHeaderText() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(
//           widget.accountInfo.hasBank ? 'View bank info' : 'Update banking info',
//           style: TextStyle(
//             fontSize: 30,
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           widget.accountInfo.hasBank
//               ? 'This account will be used for your withdrawals.'
//               : 'Select a bank account to use for your payouts.Please not that you won\'t be able to make withdrawals without an active bank account',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     TextInputType keyboardType = TextInputType.text,
//     bool enabled = true,
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       enabled: enabled,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: enabled
//             ? label
//             : null, // Hide label if disabled and relying on controller text
//         hintText: enabled ? null : label,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         fillColor: enabled ? Colors.white : Colors.grey.shade50,
//         filled: true,
//       ),
//       validator: (value) {
//         if (enabled && (value == null || value.isEmpty)) {
//           return 'Please enter the $label';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildTitleDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedTitle,
//       decoration: _buildDropdownInputDecoration('Title'),
//       items: _titles.map((String title) {
//         return DropdownMenuItem<String>(value: title, child: Text(title));
//       }).toList(),
//       onChanged: (String? newValue) =>
//           setState(() => _selectedTitle = newValue),
//       validator: (value) => value == null ? 'Please select a title' : null,
//     );
//   }

//   Widget _buildGenderDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedGender,
//       decoration: _buildDropdownInputDecoration('Select Gender'),
//       items: _genders.map((String gender) {
//         return DropdownMenuItem<String>(value: gender, child: Text(gender));
//       }).toList(),
//       onChanged: (String? newValue) =>
//           setState(() => _selectedGender = newValue),
//       validator: (value) => value == null ? 'Please select a gender' : null,
//     );
//   }

//   Widget _buildProvinceDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedProvince,
//       decoration: _buildDropdownInputDecoration('Select Province'),
//       items: _provinces.map((String province) {
//         return DropdownMenuItem<String>(value: province, child: Text(province));
//       }).toList(),
//       onChanged: (String? newValue) =>
//           setState(() => _selectedProvince = newValue),
//       validator: (value) => value == null ? 'Please select a province' : null,
//     );
//   }

//   Widget _buildCountryDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedCountry,
//       decoration: _buildDropdownInputDecoration('Select Country'),
//       items: _countries.map((String country) {
//         return DropdownMenuItem<String>(value: country, child: Text(country));
//       }).toList(),
//       onChanged: (String? newValue) =>
//           setState(() => _selectedCountry = newValue),
//       validator: (value) => value == null ? 'Please select a country' : null,
//     );
//   }

//   Widget _buildSectorDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedSector,
//       decoration: _buildDropdownInputDecoration(
//         'Select Individual Business Sector',
//       ),
//       items: _sectors.map((String sector) {
//         return DropdownMenuItem<String>(value: sector, child: Text(sector));
//       }).toList(),
//       onChanged: (String? newValue) =>
//           setState(() => _selectedSector = newValue),
//       validator: (value) => value == null ? 'Please select a sector' : null,
//     );
//   }

//   InputDecoration _buildDropdownInputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//     );
//   }

//   Widget _buildDateField(
//     BuildContext context, {
//     required DateTime? date,
//     required String label,
//   }) {
//     return GestureDetector(
//       onTap: () => _selectDate(context),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               date == null ? label : DateFormat('dd MMM yyyy').format(date),
//               style: TextStyle(
//                 color: date == null ? Colors.grey.shade600 : Colors.black,
//                 fontSize: 16,
//               ),
//             ),
//             Icon(Icons.calendar_today, color: Colors.grey.shade500),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUpdateButton(BankAccount bankAccount) {
//     return Container(
//       width: double.infinity,
//       height: 55,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         gradient: LinearGradient(
//           colors: [Colors.green.shade700, Colors.yellow.shade700],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.withOpacity(0.4),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: TextButton(
//         onPressed: () {
//           Navigator.pushReplacementNamed(
//             context,
//             '/UpdateBank',
//             arguments: bankAccount,
//           );
//         },
//         child: const Text(
//           'Update bank account',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNextButton() {
//     return Container(
//       width: double.infinity,
//       height: 55,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         gradient: LinearGradient(
//           colors: [Colors.green.shade700, Colors.yellow.shade700],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.withOpacity(0.4),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: TextButton(
//         onPressed: _submitForm,
//         child: const Text(
//           'Use bank account',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAddButtonButton() {
//     return Container(
//       width: double.infinity,
//       height: 55,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         gradient: LinearGradient(
//           colors: [Colors.green.shade700, Colors.yellow.shade700],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.green.withOpacity(0.4),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: TextButton(
//         onPressed: () {
//           Navigator.pushNamed(
//             context,
//             '/UpdateBankingDetails',
//             arguments: widget.accountInfo,
//           ).then((value) => _con.listenForBanks());
//         },
//         child: const Text(
//           'Add bank account',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/bank_account.dart';
import 'package:smacredit/src/profile/models/account_info.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class UpdatePaymentProfileScreen extends StatefulWidget {
  final AccountInfo accountInfo;
  const UpdatePaymentProfileScreen({super.key, required this.accountInfo});

  @override
  _UpdatePaymentProfileScreenState createState() =>
      _UpdatePaymentProfileScreenState();
}

class _UpdatePaymentProfileScreenState
    extends StateMVC<UpdatePaymentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late PaymentController _con;

  _UpdatePaymentProfileScreenState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }

  BankAccount? _selectedBank;

  // Controllers for text fields
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankBranchController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankAccountNamesController =
      TextEditingController();
  final TextEditingController _bankBICCodeController = TextEditingController();
  final TextEditingController _bankSwiftCodeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _con.listenForBanks();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _bankAccountController.dispose();
    _bankAccountNamesController.dispose();
    _bankBICCodeController.dispose();
    _bankSwiftCodeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final formData = {
        'paymentProfileBankId': _selectedBank?.id,
        'paymentProfileId': widget.accountInfo.paymentProfile?.id,
      };
      _con.updateProfileBank(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    // THEME CONSTANTS
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.white70 : Colors.grey.shade600;
    final bgColor = isDark ? Colors.black : Colors.white;
    final cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final borderCol = isDark ? Colors.white24 : Colors.grey.shade300;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(primaryText, borderCol),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: widget.accountInfo.hasBank == false
                      ? _buildEditMode(
                          primaryText,
                          secondaryText,
                          cardBg,
                          borderCol,
                          isDark,
                        )
                      : _buildViewMode(
                          primaryText,
                          secondaryText,
                          cardBg,
                          borderCol,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- View Mode (When Bank exists) ---
  Widget _buildViewMode(Color text, Color subText, Color cardBg, Color border) {
    final b = widget.accountInfo.bank;
    return Column(
      children: [
        _buildHeaderText(text, subText),
        const SizedBox(height: 30),
        _buildInfoCard(
          title: 'Bank Name',
          content: b?.bankName ?? '',
          text: text,
          sub: subText,
          bg: cardBg,
          border: border,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Bank Branch',
          content: b?.bankBranch ?? '',
          text: text,
          sub: subText,
          bg: cardBg,
          border: border,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Currency',
          content: b?.bankCurrency ?? '',
          text: text,
          sub: subText,
          bg: cardBg,
          border: border,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Account Number',
          content: b?.bankAccount ?? '',
          text: text,
          sub: subText,
          bg: cardBg,
          border: border,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Account Holder',
          content: b?.bankAccountNames ?? '',
          text: text,
          sub: subText,
          bg: cardBg,
          border: border,
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          label: 'Update bank account',
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            '/UpdateBank',
            arguments: b,
          ),
        ),
      ],
    );
  }

  // --- Edit Mode (Selection) ---
  Widget _buildEditMode(
    Color text,
    Color subText,
    Color cardBg,
    Color border,
    bool isDark,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderText(text, subText),
          const SizedBox(height: 30),
          if (_con.banks.isNotEmpty) ...[
            _buildBanksDropdown(text, cardBg, border, isDark),
            const SizedBox(height: 16),
            if (_selectedBank != null) ...[
              _buildTextField(
                controller: _bankNameController,
                label: 'Bank Name',
                text: text,
                bg: cardBg,
                border: border,
                enabled: false,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bankAccountController,
                label: 'Account Number',
                text: text,
                bg: cardBg,
                border: border,
                enabled: false,
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 30),
            _buildActionButton(
              label: 'Use bank account',
              onPressed: _submitForm,
            ),
          ] else ...[
            const SizedBox(height: 50),
            _buildActionButton(
              label: 'Add bank account',
              onPressed: () => Navigator.pushNamed(
                context,
                '/UpdateBankingDetails',
                arguments: widget.accountInfo,
              ).then((_) => _con.listenForBanks()),
            ),
          ],
        ],
      ),
    );
  }

  // --- Sub-widgets ---

  Widget _buildAppBar(Color color, Color border) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: border),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 20, color: color),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(Color text, Color sub) {
    return Column(
      children: [
        Text(
          widget.accountInfo.hasBank ? 'View bank info' : 'Update banking info',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.accountInfo.hasBank
              ? 'This account will be used for your withdrawals.'
              : 'Select a bank account to use for your payouts.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: sub),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required Color text,
    required Color sub,
    required Color bg,
    required Color border,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: sub,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color text,
    required Color bg,
    required Color border,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: text.withOpacity(0.5)),
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
      ),
    );
  }

  Widget _buildBanksDropdown(Color text, Color bg, Color border, bool isDark) {
    return DropdownButtonFormField<BankAccount>(
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        labelText: 'Select Bank Account',
        labelStyle: TextStyle(color: text.withOpacity(0.5)),
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
      ),
      items: _con.banks
          .map(
            (bank) =>
                DropdownMenuItem(value: bank, child: Text(bank.bankName ?? '')),
          )
          .toList(),
      onChanged: (val) {
        _bankNameController.text = val?.bankName ?? '';
        _bankAccountController.text = val?.bankAccount ?? '';
        setState(() => _selectedBank = val);
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [const Color(0xFF679E4F), Colors.yellow.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
