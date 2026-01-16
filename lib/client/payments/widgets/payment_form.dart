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
    {'id': 'ECOCASH', 'label': 'EcoCash', 'icon': Icons.account_balance_wallet},
    // {'id': 'ZIMSWITCH', 'label': 'Zimswitch', 'icon': Icons.swap_horiz},
    {'id': 'VISA', 'label': 'Visa', 'icon': Icons.credit_card},
    {'id': 'MASTERCARD', 'label': 'Mastercard', 'icon': Icons.payment},
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
              (method) => RadioListTile<String>(
                title: Text(method['label']),
                secondary: Icon(
                  method['icon'],
                  color: theme.colorScheme.primary,
                ),
                value: method['id'],
                groupValue: _selectedMethod,
                onChanged: (val) => setState(() => _selectedMethod = val),
              ),
            ),

            // Conditional EcoCash TextField
            if (_selectedMethod == 'ECOCASH') ...[
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
                              ecoCashNumber: _selectedMethod == 'ECOCASH'
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
