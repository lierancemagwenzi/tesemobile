import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/currencyModel.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart'; // Used for date formatting

class CreatePaymentLinkScreen extends StatefulWidget {
  const CreatePaymentLinkScreen({super.key});

  @override
  _CreatePaymentLinkScreenState createState() =>
      _CreatePaymentLinkScreenState();
}

class _CreatePaymentLinkScreenState extends StateMVC<CreatePaymentLinkScreen> {
  late PaymentController _con;

  _CreatePaymentLinkScreenState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }
  CurrencyModel? _selectedCurrency;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForCurrencies();
    // _con.loadCustomEmployers();
  }

  final _formKey = GlobalKey<FormState>();

  // Form Field Controllers and Variables
  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _descriptionController = TextEditingController(
    text: '',
  );
  final TextEditingController _referenceController = TextEditingController(
    text: '123456123456',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '1.00',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'admin@smatechgroup.com',
  );
  final TextEditingController _successUrlController = TextEditingController(
    text: 'https://www.google.com',
  );
  final TextEditingController _failUrlController = TextEditingController(
    text: 'https://www.google.com',
  );
  final TextEditingController _payerNameController = TextEditingController(
    text: 'Udean Mbano',
  );
  final TextEditingController _payerEmailController = TextEditingController(
    text: 'lierance@smatechgoup.com',
  );
  final TextEditingController _payerAddressController = TextEditingController(
    text: '1 estelle road paulshof',
  );
  final TextEditingController _payerMobileController = TextEditingController(
    text: '0782801353',
  );
  final TextEditingController _profileIdController = TextEditingController(
    text: '5531106',
  );
  final ImagePicker picker = ImagePicker();

  // Dropdown/Selection Variables
  String? _selectedType = 'ONCE_OFF_FIXED';
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now().add(Duration(days: 61));
  bool _allowOtherCurrencies = true;
  File? _imageFile;
  // Mock Dropdown Lists
  final List<String> _currencyOptions = ['USD', 'ZWL', 'EUR', 'ZAR'];
  final List<Map<String, String>> _typeOptions = [
    {'label': 'Once Off', 'value': 'ONCE_OFF_FIXED'},
    {'label': 'Multiple', 'value': 'OPEN_FIXED_AMOUNT'},
    {'label': 'Dynamic', 'value': 'OPEN_DYNAMIC_AMOUNT'},

    // {'label': 'Donation', 'value': 'DONATION'},
  ];

  Future<void> _pickImage(ImageSource source) async {
    // Dismiss the modal before opening the camera/gallery
    Navigator.pop(context);

    try {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle permission errors or other errors during picking
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                title: Text(
                  'Choose Image Source',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              // Option 1: Camera
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              // Option 2: Gallery
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              // Option 3: Cancel
              ListTile(
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    _successUrlController.dispose();
    _failUrlController.dispose();
    _payerNameController.dispose();
    _payerEmailController.dispose();
    _payerAddressController.dispose();
    _payerMobileController.dispose();
    _profileIdController.dispose();
    super.dispose();
  }

  // --- Date Picker Helper ---
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: (365 * 100))),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // --- Form Submission Logic (Placeholder) ---
  void _submitForm() async {
    // Navigator.pushNamed(context, '/PaymentLinkDetails');
    // return;

    if (_con.loading) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Collect all data into a Map matching the API request structure
      final formData = {
        'paymentLinkName': _nameController.text,
        'paymentLinkDescription': _descriptionController.text,
        // 'paymentLinkReference': _referenceController.text,
        'paymentLinkAmount': _amountController.text,
        'paymentLinkType': _selectedType,
        // Assuming NEW is static for this form, or needs an option
        'paymentLinkImageType': 'NEW',
        // 'paymentLinkProfileId': _profileIdController.text,
        'paymentLinkStartDate': _startDate != null
            ? DateFormat('yyyy-MM-dd').format(_startDate!)
            : null,
        'paymentLinkEndDate': _endDate != null
            ? DateFormat('yyyy-MM-dd').format(_endDate!)
            : null,
        'paymentLinkCurrency': _selectedCurrency?.currencyCode,
        'paymentLinkCurrencyId':
            _selectedCurrency?.id, // Static ID, needs actual logic
        'paymentLinkOtherCurrencies': _allowOtherCurrencies.toString(),
        // 'paymentLinkCustomerRedirectUrl': _successUrlController.text,
        // 'paymentCustomerFailRedirectUrl': _failUrlController.text,
        // 'paymentLinkEmail': _emailController.text,
        // 'paymentPayerFullNames': _payerNameController.text,
        // 'paymentPayerEmailAddress': _payerEmailController.text,
        // 'paymentPayerAddress': _payerAddressController.text,
        // 'paymentPayerMobile': _payerMobileController.text,
      };

      if (kDebugMode) {
        print('Form Data Submitted: $formData');
      }

      bool? result = await showConfirmationDialog(context);

      if (result == true) {
        submit(formData);
      }
      return;

      // Here you would typically send the data to your API
    }
  }

  submit(Map map) async {
    PaymentLinkModel? model = await _con.createPaymentLinkWithFile(
      map,
      _imageFile,
    );

    if (model != null) {
      showSuccessDialog(_con.scaffoldKey.currentContext!, model);
    } else {
      CustomMessageHandler().showErrorSnakeBar(
        _con.scaffoldKey.currentContext!,
        'Failed to create the payment link. Try again',
      );
    }
  }

  Future<bool?> showConfirmationDialog(BuildContext context) async {
    // Use a final variable for readability
    final screenWidth = MediaQuery.of(context).size.width;

    return showDialog<bool>(
      context: context,
      barrierDismissible:
          true, // Allows dismissal by tapping outside (default is true)
      builder: (BuildContext context) {
        return Dialog(
          elevation: 10, // Adds depth and shadow (not flat)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          // The key to full-width:
          // Use ConstrainedBox to force the width to be equal to the screen width,
          // minus any standard dialog padding the system might enforce.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth, // Maximize width
              minWidth: screenWidth, // Ensure minimum width is also max width
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Keep the dialog size compact vertically
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- Title ---
                  Text(
                    'Confirm',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // --- Content ---
                  Text(' Are you sure you want to create the payment link?'),
                  const SizedBox(height: 20),

                  // --- Action Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pop(false); // Return false on cancel
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .green, // <-- Sets the button's background color to green
                          foregroundColor: Colors
                              .white, // Optional: Sets the text/icon color to white for contrast
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ), // Optional styling
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Optional: Rounded corners
                          ),
                        ),
                        child: const Text('Confirm'),
                        onPressed: () {
                          Navigator.of(context).pop(true);

                          // Return true on confirm
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSuccessDialog(
    BuildContext dialogContext,
    PaymentLinkModel paymentLink,
  ) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          elevation: 10, // Adds depth and shadow (not flat)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Success!'),
            ],
          ),
          content: PopScope(
            canPop: false,

            child: const Text('Payment link created successfully.'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Dismiss the dialog
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(
                  context,
                  '/PaymentLinkDetails',
                  arguments: {'link': paymentLink, 'isNew': true},
                );
                // Optional: Navigate to another screen or refresh data here
                // Example: Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: CustomOverlay(
        loading: _con.loading,
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _con.scaffoldKey,
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
                          SizedBox(height: 10),
                          // 1. Payment Link Details (Matches screenshot)
                          _buildTextField(
                            controller: _nameController,
                            label: 'Payment Link Name',
                          ),
                          const SizedBox(height: 16),
                          _buildCurrencyDropdown(),

                          // const SizedBox(height: 16),
                          // _buildTextField(
                          //   controller: _referenceController,
                          //   label: 'Payment Link Reference',
                          // ),
                          const SizedBox(height: 16),
                          _buildTypeDropdown(),
                          const SizedBox(height: 16),

                          if (_selectedType != 'OPEN_DYNAMIC_AMOUNT')
                          // 2. Additional Fields from Request (Amount, Type, Profile ID)
                          ...[
                            _buildTextField(
                              controller: _amountController,
                              label: 'Payment Link Amount',
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 16),
                          ],

                          // const SizedBox(height: 16),
                          // _buildTextField(
                          //   controller: _profileIdController,
                          //   label: 'Profile ID',
                          //   keyboardType: TextInputType.number,
                          // ),

                          // 3. Date Fields (Matches screenshot)
                          Row(
                            children: [
                              _buildDateField(
                                context,
                                isStart: true,
                                date: _startDate,
                                label: 'Start Date',
                              ),
                              const SizedBox(width: 16),
                              _buildDateField(
                                context,
                                isStart: false,
                                date: _endDate,
                                label: 'End Date',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 4. Description (Matches screenshot)
                          _buildDescriptionField(),
                          const SizedBox(height: 16),

                          // 5. Logo Upload (Matches screenshot)
                          _buildLogoUpload(),
                          const SizedBox(height: 16),

                          // 6. Redirect URLs (Matches screenshot)
                          // _buildTextField(
                          //   controller: _successUrlController,
                          //   label: 'Customer Redirect Url (Success)',
                          // ),
                          // const SizedBox(height: 16),
                          // _buildTextField(
                          //   controller: _failUrlController,
                          //   label: 'Customer Fail Redirect Url',
                          // ),
                          const SizedBox(height: 16),

                          // 7. Other Currencies Checkbox
                          _buildOtherCurrenciesSwitch(),
                          const SizedBox(height: 24),

                          // 8. Payer Details (New Section from Request)
                          // const Text(
                          //   'Payer Details',
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.black87,
                          //   ),
                          // ),
                          // SizedBox(height: 10),
                          // const Divider(color: Colors.grey),
                          // SizedBox(height: 10),
                          // _buildTextField(
                          //   controller: _payerNameController,
                          //   label: 'Payer Full Names',
                          // ),
                          // const SizedBox(height: 16),
                          // _buildTextField(
                          //   controller: _payerEmailController,
                          //   label: 'Payer Email Address',
                          //   keyboardType: TextInputType.emailAddress,
                          // ),
                          // const SizedBox(height: 16),
                          // _buildTextField(
                          //   controller: _payerAddressController,
                          //   label: 'Payer Address',
                          // ),
                          // const SizedBox(height: 16),
                          // _buildTextField(
                          //   controller: _payerMobileController,
                          //   label: 'Payer Mobile',
                          //   keyboardType: TextInputType.phone,
                          // ),
                          const SizedBox(height: 24),

                          // 9. Next/Submit Button
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
      ),
    );
  }

  // --- Custom Widget Builders ---

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (_con.loading) {
                return;
              }
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Create A New\nPayment Link',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the $label';
        }
        return null;
      },
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<CurrencyModel>(
      initialValue: _selectedCurrency,
      decoration: InputDecoration(
        labelText: 'Payment Currency',
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

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Payment Type',
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
      items: _typeOptions.map((Map<String, String> type) {
        return DropdownMenuItem<String>(
          value: type['value'],
          child: Text(type['label']!),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedType = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a type' : null,
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required bool isStart,
    required DateTime? date,
    required String label,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectDate(context, isStart),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      onEditingComplete: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        } else {
          return null;
        }
      },
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        labelText: 'Description',
        alignLabelWithHint: true,
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
    );
  }

  Widget _buildLogoUpload() {
    // *** Using the Custom Painter Widget here ***
    return Column(
      children: [
        if (_imageFile != null) ...[
          DashedRectContainer(
            color: Colors.grey.shade400,
            child: Container(
              height: 200,
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Image.file(_imageFile!, fit: BoxFit.contain),
            ),
          ),
        ],
        DashedRectContainer(
          color: Colors.grey.shade400,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 30,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload a clear image of your Logo',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                InkWell(
                  onTap: () {
                    _showImageSourceModal();
                  },
                  child: const Text(
                    'Browse',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherCurrenciesSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Allow Other Currencies',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        Switch(
          value: _allowOtherCurrencies,
          onChanged: (bool value) {
            setState(() {
              _allowOtherCurrencies = value;
            });
          },
          activeColor: Colors.green,
        ),
      ],
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

// --- Custom Dotted Border Container Widget (To match screenshot) ---

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 8.0,
    this.dashSpace = 4.0,
    this.radius = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Define the paint style
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // 2. Define the rounded rectangle path
    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    // 3. Get the total length of the path (perimeter)
    final path = Path()..addRRect(rRect);
    final pathMetrics = path.computeMetrics();

    // We only have one contour (the rectangle)
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      // Loop until we cover the entire path length
      while (distance < pathMetric.length) {
        // Draw the dash segment
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        // Move to the next start point (dash + gap)
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    // Repaint only if any properties change
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.radius != radius;
  }
}

// --- 2. The Custom Widget using the Painter ---
class DashedRectContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;

  const DashedRectContainer({
    super.key,
    required this.child,
    this.radius = 10.0,
    this.color = const Color(0xFFC7C7C7), // Default grey color
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedRectPainter(color: color, radius: radius),
      child: child,
    );
  }
}
