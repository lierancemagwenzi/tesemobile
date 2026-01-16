import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/bank_account.dart';
import 'package:smacredit/src/payments/models/currencyModel.dart';
import 'package:smacredit/src/profile/models/account_info.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class UpdateBankWidget extends StatefulWidget {
  final BankAccount accountInfo;
  const UpdateBankWidget({super.key, required this.accountInfo});

  @override
  _UpdateBankWidgetState createState() => _UpdateBankWidgetState();
}

class _UpdateBankWidgetState extends StateMVC<UpdateBankWidget> {
  final _formKey = GlobalKey<FormState>();

  late PaymentController _con;

  _UpdateBankWidgetState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }
  CurrencyModel? _selectedCurrency;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForCurrencies();

    _bankNameController = TextEditingController(
      text: widget.accountInfo.bankName,
    );
    _bankBranchController = TextEditingController(
      text: widget.accountInfo.bankBranch,
    );
    _bankAccountController = TextEditingController(
      text: widget.accountInfo.bankAccount,
    );

    _bankAccountNamesController = TextEditingController(
      text: widget.accountInfo.bankAccountNames,
    );
    _bankBICCodeController = TextEditingController(
      text: widget.accountInfo.bankBICCode,
    );
    _bankSwiftCodeController = TextEditingController(
      text: widget.accountInfo.bankSwiftCode,
    );

    // _con.loadCustomEmployers();
  }

  // --- Controllers for all text fields ---
  TextEditingController _bankNameController = TextEditingController(text: '');
  TextEditingController _bankBranchController = TextEditingController(text: '');
  TextEditingController _bankAccountController = TextEditingController(
    text: '',
  );
  TextEditingController _bankAccountNamesController = TextEditingController(
    text: '',
  );
  TextEditingController _bankBICCodeController = TextEditingController(
    text: '',
  );
  TextEditingController _bankSwiftCodeController = TextEditingController(
    text: '',
  );

  // --- Variables for dropdowns/date ---
  String? _selectedTitle = 'Mr';
  String? _selectedGender = 'Male';
  String? _selectedProvince = 'Harare'; // Matches your data
  String? _selectedCountry = 'Zimbabwe';
  String? _selectedSector; // Assuming this is the 'Individual Business Sector'
  DateTime? _dateOfBirth = DateTime.parse('1995-06-15');

  // Mock Data for Dropdowns
  final List<String> _titles = ['Mr', 'Ms', 'Mrs', 'Dr'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _provinces = [
    'Harare',
    'Bulawayo',
    'Midlands',
    'Manicaland',
  ]; // Mock list
  final List<String> _countries = [
    'Zimbabwe',
    'South Africa',
    'Zambia',
    'United Kingdom',
  ]; // Mock list
  final List<String> _sectors = [
    'Videography',
    'Marketing',
    'Education',
    'Technology',
  ]; // Mock list

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

  // --- Date Picker Helper ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  // --- Form Submission Logic (Placeholder) ---
  void _submitForm() {
    // Navigator.pop(context);
    // return;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formData = {
        "bankName": _bankNameController.text,
        "bankBranch": _bankBranchController.text,
        "bankAccount": _bankAccountController.text,
        "bankAccountNames": _bankAccountNamesController.text,
        "bankBICCode": _bankBICCodeController.text,
        "bankSwiftCode": _bankSwiftCodeController.text,
        'bankCurrency': _selectedCurrency?.currencyCode,
        'bankCurrencyId': _selectedCurrency?.id,
        'id': widget.accountInfo.id,
        // "individualMobile": _mobileNumberController.text,
        // "contentCreatorID": int.tryParse(_creatorIdController.text),
      };

      _con.updateBankAccount(formData);
      print('Updated Profile Data: $formData');
      // Here, you'd send this data to your backend API
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Text
                        _buildHeaderText(),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _bankNameController,
                          label: 'Bank Name',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _bankBranchController,
                          label: 'Bank Branch',
                        ),

                        const SizedBox(height: 16),

                        // 3. Email (Matches Screenshot)
                        _buildTextField(
                          controller: _bankAccountController,
                          label: 'Account Number',
                          enabled: true,
                        ), // Disabled/pre-filled email
                        const SizedBox(height: 16),

                        // 4. Contact/Address Info
                        _buildTextField(
                          controller: _bankBICCodeController,
                          label: 'Bank BIC Code',
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _bankSwiftCodeController,
                          label: 'Swift Code',
                        ),
                        const SizedBox(height: 16),

                        // 7. Business Description (Matches Screenshot)
                        _buildTextField(
                          controller: _bankAccountNamesController,
                          label: 'Account Name',
                        ),
                        const SizedBox(height: 16),

                        // 8. Sector (Matches Screenshot)
                        _buildCurrencyDropdown(),
                        const SizedBox(height: 16),

                        // 9. Creator ID
                        const SizedBox(height: 30),

                        // 10. Next Button
                        _buildNextButton(),
                        const SizedBox(height: 30),
                      ],
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

  // --- Custom Widget Builders ---

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<CurrencyModel>(
      initialValue: _selectedCurrency,
      decoration: InputDecoration(
        labelText: 'Bank account Currency',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: _con.currencies.map((CurrencyModel currency) {
        return DropdownMenuItem<CurrencyModel>(
          value: currency,
          child: Text(currency.currencyName),
        );
      }).toList(),
      onChanged: (CurrencyModel? newValue) {
        setState(() {
          _selectedCurrency = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a currency' : null,
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Update banking info',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update your banking information for easier withdrawals.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: enabled
            ? label
            : null, // Hide label if disabled and relying on controller text
        hintText: enabled ? null : label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        filled: true,
      ),
      validator: (value) {
        if (enabled && (value == null || value.isEmpty)) {
          return 'Please enter the $label';
        }
        return null;
      },
    );
  }

  Widget _buildTitleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedTitle,
      decoration: _buildDropdownInputDecoration('Title'),
      items: _titles.map((String title) {
        return DropdownMenuItem<String>(value: title, child: Text(title));
      }).toList(),
      onChanged: (String? newValue) =>
          setState(() => _selectedTitle = newValue),
      validator: (value) => value == null ? 'Please select a title' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: _buildDropdownInputDecoration('Select Gender'),
      items: _genders.map((String gender) {
        return DropdownMenuItem<String>(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (String? newValue) =>
          setState(() => _selectedGender = newValue),
      validator: (value) => value == null ? 'Please select a gender' : null,
    );
  }

  Widget _buildProvinceDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedProvince,
      decoration: _buildDropdownInputDecoration('Select Province'),
      items: _provinces.map((String province) {
        return DropdownMenuItem<String>(value: province, child: Text(province));
      }).toList(),
      onChanged: (String? newValue) =>
          setState(() => _selectedProvince = newValue),
      validator: (value) => value == null ? 'Please select a province' : null,
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCountry,
      decoration: _buildDropdownInputDecoration('Select Country'),
      items: _countries.map((String country) {
        return DropdownMenuItem<String>(value: country, child: Text(country));
      }).toList(),
      onChanged: (String? newValue) =>
          setState(() => _selectedCountry = newValue),
      validator: (value) => value == null ? 'Please select a country' : null,
    );
  }

  Widget _buildSectorDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSector,
      decoration: _buildDropdownInputDecoration(
        'Select Individual Business Sector',
      ),
      items: _sectors.map((String sector) {
        return DropdownMenuItem<String>(value: sector, child: Text(sector));
      }).toList(),
      onChanged: (String? newValue) =>
          setState(() => _selectedSector = newValue),
      validator: (value) => value == null ? 'Please select a sector' : null,
    );
  }

  InputDecoration _buildDropdownInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required DateTime? date,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : DateFormat('dd MMM yyyy').format(date),
              style: TextStyle(
                color: date == null ? Colors.grey.shade600 : Colors.black,
                fontSize: 16,
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.yellow.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _submitForm,
        child: const Text(
          'Next',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
