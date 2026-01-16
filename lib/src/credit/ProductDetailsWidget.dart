import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/credit/controller/credit_controller.dart';
import 'package:smacredit/src/credit/models/CreditApplication.dart';
import 'package:smacredit/src/credit/models/PaymentResponse.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:smacredit/src/widgets/gradient_button.dart';

class ProductDetailsWidget extends StatefulWidget {
  final CreditApplication application;
  const ProductDetailsWidget({Key? key, required this.application})
    : super(key: key);

  @override
  _ProductDetailsWidgetState createState() => _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends StateMVC<ProductDetailsWidget> {
  late CreditController _con;

  _ProductDetailsWidgetState() : super(CreditController()) {
    _con = controller as CreditController;
  }
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  bool _isProcessing = false;

  // Zimbabwean Econet Prefixes (starting after the '0')
  // Common prefixes include 77, 78, and sometimes others depending on current allocation.
  // We'll use the common ones for demonstration.
  final List<String> _econetPrefixes = ['77', '78'];
  final List<String> paymentOptions = const [
    'Ecocash',
    'Visa',
    'MasterCard',
    // 'Omari',
    // 'InnBucks',
    // 'ZimSwitch',
  ];
  String? _validateEconet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty.';
    }

    final String cleanValue = value.replaceAll(RegExp(r'\s+'), '');

    // 1. Check if it is 10 digits long
    if (cleanValue.length != 10) {
      return 'Number must be exactly 10 digits.';
    }

    // 2. Check if it starts with '0'
    if (!cleanValue.startsWith('0')) {
      return 'Number must start with a zero (0).';
    }

    // 3. Check for valid Econet prefix (digits 1 and 2 after the initial '0')
    final String prefix = cleanValue.substring(1, 3);
    if (!_econetPrefixes.contains(prefix)) {
      // NOTE: This is a strict check. You might relax it depending on your needs.
      return 'This does not appear to be a valid Econet number.';
    }

    return null; // Validation passed
  }

  void _submitForm(InstallmentSchedule schedule) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Navigator.of(context, rootNavigator: true).pop();

      // setState(() {
      //   _isProcessing = true;
      // });

      // // Simulate network delay or processing
      // await Future.delayed(const Duration(seconds: 2));

      // setState(() {
      //   _isProcessing = false;
      // });

      // Close the dialog and display success
      // if (mounted) {
      //   Navigator.pop(context);
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Processing number: $_phoneNumber')),
      //   );
      // }

      ecocashPayment(schedule);
    }
  }

  bool isExpended = false;

  String merchantId = "311722504951049";
  String merchantApiKey = "V8S5M2C3L0nYPz8ZDVRhq";
  String merchantKey = "959d936d-c79a-4711-9528-2d0dc4399142";

  ecocashPayment(InstallmentSchedule schedule) async {
    Map map = {
      "merchantId": merchantId,
      "merchantApiKey": merchantApiKey,
      "merchantKey": merchantKey,
      "walletName": "Visa",
      "amount": schedule.amount,
      "paymentCurrency": "USD",
      "paymentDescription": "Installment payment",
      "payerName":
          "${currentuser.value.user?.name} ${currentuser.value.user?.lastname}",
      "payerReference": schedule.creditReference,
      "payerAccountId": 11,
      "profileId": 4271941,
      "payerMobile": '263${_phoneNumber.substring(1)}',
    };
    PaymentResponse? response = await _con.initialisePayment(map);
    if (response != null) {
      CustomMessageHandler().showSuccessSnakeBar(
        _con.scaffoldKey.currentContext!,
        'Payment prompt sent to  ${_phoneNumber}',
      );
    } else {
      CustomMessageHandler().showErrorSnakeBar(
        _con.scaffoldKey.currentContext!,
        'Failed to inialise payment',
      );
    }
  }

  visaPayment(InstallmentSchedule schedule, String method) async {
    if (method == 'Visa' || method == 'MasterCard') {
      Map map = {
        "merchantId": merchantId,
        "merchantApiKey": merchantApiKey,
        "merchantKey": merchantKey,
        "walletName": method,
        "amount": schedule.amount,
        "paymentCurrency": "USD",
        "paymentDescription": "Installment payment",
        "payerName":
            "${currentuser.value.user?.name} ${currentuser.value.user?.name}",
        "payerReference": schedule.creditReference,
        "payerAccountId": 11,
        "profileId": 4271941,
      };
      PaymentResponse? response = await _con.initialisePayment(map);
      if (response != null) {
        Navigator.pushNamed(context, '/MakePayment', arguments: response);
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          _con.scaffoldKey.currentContext!,
          'Failed to inialise payment',
        );
      }
    } else if (method == 'Ecocash') {
      _showPhoneNumberDialog(context, schedule);
    }
  }

  String formatDateString(String dateString) {
    // 1. Parse the ISO 8601 date string into a DateTime object.

    try {
      final DateTime dateTime = DateTime.parse(dateString);

      // 2. Define the desired format: 'EEEE' for full weekday, 'MMMM' for full month name, 'd' for day, 'yyyy' for year.
      final DateFormat formatter = DateFormat(' MM/d/yyyy');

      // 3. Format the DateTime object.
      final String formattedDate = formatter.format(dateTime);

      return formattedDate;
    } catch (e) {
      return "-";
    }
  }

  void _showPhoneNumberDialog(
    BuildContext context,
    InstallmentSchedule schedule,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return econetDialog(context, schedule);
      },
    );
  }

  Widget econetDialog(BuildContext context, InstallmentSchedule schedule) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          20.0,
        ), // Beautifully rounded corners
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Title and Icon
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_android, color: Color(0xFF5A40A6), size: 30),
                  SizedBox(width: 10),
                  Text(
                    'Enter Mobile Number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),

              // Phone Number Input Field
              TextFormField(
                keyboardType: TextInputType.phone,
                maxLength: 10, // Max length set to 10
                decoration: InputDecoration(
                  labelText: 'Econet Phone Number',
                  hintText: 'e.g., 0771234567',
                  prefixIcon: const Icon(
                    Icons.dialpad,
                    color: Color(0xFF5A40A6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF8B5BE3),
                      width: 2.0,
                    ),
                  ),
                ),
                validator: _validateEconet,
                onSaved: (value) => _phoneNumber = value!,
              ),
              const SizedBox(height: 20),

              // Action Button
              _isProcessing
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF5A40A6),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _submitForm(schedule);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF5A40A6,
                          ), // Deep purple background
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  void _showPaymentSheet(BuildContext context, InstallmentSchedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows content to take up more screen space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 25.0,
            left: 20.0,
            right: 20.0,
            // Adjust padding to avoid button covering keyboard if you add text fields later
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Essential to wrap content height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose a payment method',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Build the 6 gradient buttons
              ...paymentOptions.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GradientButton(
                    text: option,
                    onPressed: () {
                      // Action for tapping a payment option
                      print('$option selected!');
                      Navigator.pop(context);

                      visaPayment(
                        schedule,
                        option,
                      ); // Close the sheet after selection
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8), // Final padding
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: const Color(0xfff7f7f7),
        key: _con.scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Product details",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Product Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _detailRow(
                              Icons.attach_money,
                              widget.application.productName ?? "",
                              iconColor: Colors.black,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isExpended = !isExpended;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: Icon(
                                  isExpended
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        _detailRow(
                          Icons.account_balance_wallet_outlined,
                          "Microfinance: Mukuru",
                        ),

                        _detailRow(
                          Icons.account_balance_wallet_outlined,
                          "Upfront PaymentStatus: ${widget.application.creditApplicationUpfrontPaymentStatus}",
                        ),

                        _detailRow(
                          Icons.account_balance_wallet_outlined,
                          "VerificationStatus: ${widget.application.applicationVerified}",
                        ),
                        _detailRow(Icons.shield_outlined, "Insurer: Sanctuary"),
                        _detailRow(
                          Icons.access_time,
                          "Duration: ${widget.application.repaymentPeriod} months",
                        ),

                        _detailRow(
                          Icons.access_time,
                          "Verified date: ${formatDateString(widget.application.applicationVerifiedDate ?? "")}",
                        ),

                        const SizedBox(height: 6),

                        if (isExpended) ...[
                          _detailRow(
                            Icons.attach_money,
                            "Deposit And Admin Amount:\$${widget.application.depositAndAdminAmount}",
                          ),
                          _detailRow(
                            Icons.attach_money,
                            "Admin Fees:\$${widget.application.adminFees}",
                          ),

                          _detailRow(
                            Icons.attach_money,
                            "Monthly Payment:\$${widget.application.monthlyRepaymentAmount}",
                          ),

                          _detailRow(
                            Icons.attach_money,
                            "insurance Fees:\$${widget.application.insuranceFee}",
                          ),
                          _detailRow(
                            Icons.attach_money,
                            "Platform Fee Percent:\$${widget.application.platformFeePercent}",
                          ),

                          _detailRow(
                            Icons.attach_money,
                            "Platform Fee Fixed:\$${widget.application.platformFeeFixed}",
                          ),
                          _detailRow(
                            Icons.attach_money,
                            "Interest Fee Percent:\$${widget.application.interestFeePercent}",
                          ),

                          _detailRow(
                            Icons.attach_money,
                            "Interest Fee Fixed:\$${widget.application.interestFeeFixed}",
                          ),

                          _detailRow(
                            Icons.attach_money,
                            "Outstanding:\$${widget.application.outstandingBalanceAmount}",
                          ),
                          const SizedBox(height: 6),

                          _detailRow(
                            Icons.attach_money,
                            "Paid: \$${widget.application.paidRepaymentAmount}",
                          ),

                          _detailRow(
                            Icons.attach_money,
                            "Deposit: \$${widget.application.depositAndAdminAmount}",
                          ),
                        ],

                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _detailRow(
                              Icons.attach_money,
                              "Full Amount: \$${widget.application.totalRepaymentAmount}",
                              iconColor: Colors.black,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: getColor(
                                  widget.application.creditApplicationStatus ??
                                      '',
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (widget
                                                .application
                                                .creditApplicationStatus ??
                                            '')
                                        .toLowerCase(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  const Text(
                    "Installments",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  ...(widget.application.installmentSchedule ?? []).map(
                    (element) =>
                        element.creditPaymentStatus?.toLowerCase() == 'paid'
                        ? Container(
                            color: Colors.white,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                // The main Card container
                                child: Card(
                                  elevation: 0,
                                  color: Color(
                                    0xFFF2F2F2,
                                  ), // No shadow for a cleaner, modern look
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    // Column to stack all the detail rows vertically
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Wrap content height
                                      children: [
                                        // 1. Month
                                        _DetailRow(
                                          icon: Icons.calendar_today_outlined,
                                          label:
                                              'Due Date: ${formatDateString(element.dueDate ?? "")}',
                                        ),
                                        SizedBox(height: 12),
                                        // 2. Amount
                                        _DetailRow(
                                          icon: Icons.monetization_on_outlined,
                                          label: 'Amount: \$${element.amount}',
                                        ),
                                        SizedBox(height: 12),
                                        // 3. Interest Rate
                                        _DetailRow(
                                          icon: Icons.percent_outlined,
                                          label:
                                              'Payment number: ${element.paymentNumber}',
                                        ),
                                        // SizedBox(height: 12),
                                        // // 4. Insurance
                                        // _DetailRow(
                                        //   icon: Icons
                                        //       .currency_exchange_outlined, // A symbol for exchange/cycle
                                        //   label: 'Insurance: 3%',
                                        // ),
                                        // SizedBox(height: 12),
                                        // // 5. Platform
                                        // _DetailRow(
                                        //   icon: Icons.layers_outlined,
                                        //   label: 'Platform: 5%',
                                        // ),
                                        SizedBox(height: 12),
                                        // 6. Status
                                        _DetailRow(
                                          icon: Icons
                                              .flash_on, // Represents a paid/completed status
                                          label:
                                              'Status: ${element.creditPaymentStatus}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Card(
                                  elevation: 0, // No shadow
                                  color: const Color(
                                    0xFFFAEBEB,
                                  ), // Light pink background for the card
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Month 3: July with Pay button
                                        _DetailRowWithButton(
                                          icon: Icons.calendar_today_outlined,
                                          label:
                                              'Due date: ${formatDateString(element.dueDate ?? "")}',
                                          showButton:
                                              true, // Show the "Pay" button
                                          onPayPressed: () {
                                            _showPaymentSheet(context, element);
                                            if (kDebugMode) {
                                              print(
                                                'Pay button pressed for Month 3: July',
                                              );
                                            }
                                            // Add navigation or payment logic here
                                          },
                                        ),

                                        SizedBox(height: 12),
                                        // 2. Amount
                                        _DetailRow(
                                          icon: Icons.monetization_on_outlined,
                                          label: 'Amount: \$${element.amount}',
                                        ),
                                        SizedBox(height: 12),
                                        // 3. Interest Rate
                                        _DetailRow(
                                          icon: Icons.percent_outlined,
                                          label:
                                              'Payment number: ${element.paymentNumber}',
                                        ),

                                        SizedBox(height: 12),
                                        // 6. Status
                                        _DetailRow(
                                          icon: Icons
                                              .flash_on, // Represents a paid/completed status
                                          label:
                                              'Status: ${element.creditPaymentStatus}',
                                        ),
                                      ],
                                    ),
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
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String text, {
    Color iconColor = Colors.black,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Color getColor(String status) {
    if (status == 'APPROVED') {
      return const Color(0xFFDFFFE2);
    }

    return Colors.red.withOpacity(0.2);
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The icon
        Icon(
          icon,
          color: Colors.black, // Dark icon color
          size: 24,
        ),
        const SizedBox(width: 15), // Spacing between icon and text
        // The text label
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500, // Medium boldness for the text
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _DetailRowWithButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showButton;
  final VoidCallback? onPayPressed;

  const _DetailRowWithButton({
    required this.icon,
    required this.label,
    this.showButton = false,
    this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.black, size: 24),
        const SizedBox(width: 15),
        Expanded(
          // Use Expanded to push the button to the right
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis, // Handle long text
          ),
        ),
        if (showButton) ...[
          const SizedBox(width: 10), // Spacing before the button
          SizedBox(
            height: 35, // Adjust button height
            child: OutlinedButton(
              onPressed: onPayPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black), // Black border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Pay',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
