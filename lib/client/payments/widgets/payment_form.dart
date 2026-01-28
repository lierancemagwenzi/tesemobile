import 'package:flutter/material.dart';
import 'package:smacredit/client/payments/models/payment.dart';

class PaymentModal extends StatefulWidget {
  const PaymentModal({super.key});

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  String? _selectedMethod;
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'Ecocash',
      'label': 'EcoCash',
      'icon': Icons.account_balance_wallet,
      'image': 'assets/images/ecocash.png',
    },
    // {'id': 'ZIMSWITCH', 'label': 'Zimswitch', 'icon': Icons.swap_horiz},
    {
      'id': 'Visa',
      'label': 'Visa',
      'icon': Icons.credit_card,
      'image': 'assets/images/visa.png',
    },
    {
      'id': 'Mastercard',
      'label': 'Mastercard',
      'icon': Icons.payment,
      'image': 'assets/images/mastercard.png',
    },
    {
      'id': 'ZimSwitch',
      'label': 'ZimSwitch',
      'icon': Icons.payment,
      'image': 'assets/images/zimswitch.png',
    },
    {
      'id': 'InnBucks',
      'label': 'InnBucks',
      'icon': Icons.payment,
      'image': 'assets/images/innbucks.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Payment Method", style: theme.textTheme.titleLarge),
            const SizedBox(height: 15),

            // Payment Method List
            ..._methods.map(
              (method) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RadioListTile<String>(
                  title: Text(method['label']),
                  secondary: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        method['image'],
                        height: 40,
                        width: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  value: method['id'],
                  groupValue: _selectedMethod,
                  onChanged: (val) => setState(() => _selectedMethod = val),
                ),
              ),
            ),

            // Conditional EcoCash TextField
            if (_selectedMethod?.toLowerCase() == 'ecocash') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Econet Phone Number",
                  hintText: "0771234567",
                  prefixIcon: const Icon(Icons.phone_iphone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  // Regex for Econet Zimbabwe (077 or 078)
                  String pattern = r'^(077|078|26377|26378)\d{7}$';
                  if (value == null ||
                      !RegExp(pattern).hasMatch(value.replaceAll(' ', ''))) {
                    return 'Enter a valid Econet number (e.g., 0771234567)';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 20),

            // Purchase Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: _selectedMethod == null
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(
                            context,
                            PaymentSelection(
                              method: _selectedMethod!,
                              ecoCashNumber:
                                  _selectedMethod?.toLowerCase() == 'ecocash'
                                  ? _phoneController.text
                                  : null,
                            ),
                          );
                        }
                      },
                child: const Text("PROCEED TO PAYMENT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
