import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  StateMVC<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends StateMVC<UpdateProfileScreen> {
  late PaymentController _con;

  _UpdateProfileScreenState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }

  final _formKey = GlobalKey<FormState>();

  // --- Controllers for all text fields ---
  TextEditingController _firstNameController = TextEditingController(
    text: 'John',
  );
  TextEditingController _lastNameController = TextEditingController(
    text: 'Doe',
  );
  TextEditingController _emailController = TextEditingController(
    text: 'lierance100@gmail.com',
  );
  TextEditingController _tradingNameController = TextEditingController(
    text: '',
  );
  TextEditingController _businessDescController = TextEditingController(
    text: 'Content creator specializing in videography and marketing',
  );
  TextEditingController _telNumberController = TextEditingController(
    text: '0782801353',
  );
  TextEditingController _tradingAddressController = TextEditingController(
    text: '123 Harare Street',
  );
  TextEditingController _mobileNumberController = TextEditingController(
    text: '0779876543',
  );
  TextEditingController _creatorIdController = TextEditingController(
    text: '10004',
  );

  // --- Variables for dropdowns/date ---
  String? _selectedTitle = 'Mr';
  String? _selectedGender = 'Male';
  String? _selectedProvince = 'Harare'; // Matches your data
  String? _selectedCountry = 'Zimbabwe';
  String? _selectedSector; // Assuming this is the 'Individual Business Sector'
  DateTime? _dateOfBirth;

  // Mock Data for Dropdowns
  final List<String> _titles = ['Mr', 'Ms', 'Mrs', 'Dr'];
  final List<String> _genders = ['Male', 'Female'];
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
  void initState() {
    // TODO: implement initState
    super.initState();

    _firstNameController = TextEditingController(
      text: currentuser.value.user?.name,
    );
    _lastNameController = TextEditingController(
      text: currentuser.value.user?.lastname,
    );
    _emailController = TextEditingController(
      text: currentuser.value.user?.email,
    );
    _selectedGender = currentuser.value.user?.gender ?? _genders[0];
    _selectedTitle = currentuser.value.user?.title ?? _titles[0];
    _telNumberController = TextEditingController(
      text: currentuser.value.user?.phone,
    );
    _tradingAddressController = TextEditingController(text: '');
    _mobileNumberController = TextEditingController(
      text: currentuser.value.user?.phone,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _tradingNameController.dispose();
    _businessDescController.dispose();
    _telNumberController.dispose();
    _tradingAddressController.dispose();
    _mobileNumberController.dispose();
    _creatorIdController.dispose();
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formData = {
        "name": _firstNameController.text,
        "lastname": _lastNameController.text,
        "email": _emailController.text,
        "title": _selectedTitle,
        "phone": _telNumberController.text,
        "gender": _selectedGender,
        "dateOfBirth": _dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
            : null,
      };

      _con.updateAccount(formData);

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
                          controller: _emailController,
                          label: 'Email',
                          enabled: false,
                        ), // Disabled/pre-filled email
                        const SizedBox(height: 16),
                        // 1. Basic Personal Info (Title, Name, Date of Birth)
                        _buildTitleDropdown(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                        ),

                        const SizedBox(height: 16),

                        // 2. Gender (Matches Screenshot)
                        _buildGenderDropdown(),
                        const SizedBox(height: 16),

                        // 3. Email (Matches Screenshot)

                        // 4. Contact/Address Info
                        _buildTextField(
                          controller: _telNumberController,
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                        ),

                        // const SizedBox(height: 16),
                        // _buildTextField(
                        //   controller: _tradingAddressController,
                        //   label: 'Residential Address',
                        // ),
                        const SizedBox(height: 16),

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

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Update Profile',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please proceed and finish updating your\nprofile so we can move forward with the next\nsteps.',
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
          'Update',
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
