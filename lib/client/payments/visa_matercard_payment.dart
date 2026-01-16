import 'package:flutter/material.dart';
import 'package:smacredit/src/credit/models/PaymentResponse.dart';
import 'package:smat_pay_payment_plugin/common/api_config.dart';
import 'package:smat_pay_payment_plugin/views/payment_form.dart';

class VisMasterCardPayment extends StatefulWidget {
  final String paymentCode;
  const VisMasterCardPayment({super.key, required this.paymentCode});

  @override
  State<VisMasterCardPayment> createState() => _VisMasterCardPaymentState();
}

class _VisMasterCardPaymentState extends State<VisMasterCardPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
            // Navigator.pop(context);
          },
        ),
        title: const Text("Payment", style: TextStyle(color: Colors.black)),
      ),
      body: PaymentForm(
        paymentCode: widget.paymentCode,
        baseUrl: 'https://dev.smatpay.africa:8443',
        endpointMode: EndpointMode.test,
      ),
    );
  }
}
