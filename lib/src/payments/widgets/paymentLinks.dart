import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'package:smacredit/src/payments/models/transaction.dart';
import 'package:smacredit/src/payments/widgets/payouts.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/data.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

// --- Transaction Data Model ---

// --- Reusable Transaction List Item Widget ---
class PaymentLinkListItem extends StatelessWidget {
  final PaymentLinkModel transaction;

  PaymentLinkListItem({Key? key, required this.transaction}) : super(key: key);

  final Random _random = Random();

  /// Picks a random color from a predefined list of primary colors.
  Color pickRandomPrimaryColor() {
    // 1. Define the list of possible colors
    const List<Color> colors = [Colors.red, Colors.green, Colors.blue];

    // 2. Generate a random index between 0 (inclusive) and the list length (exclusive)
    int randomIndex = _random.nextInt(colors.length);

    // 3. Return the color at the random index
    return colors[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/PaymentLinkDetails',
            arguments: {'link': transaction, 'isNew': false},
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Logo Container
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: pickRandomPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(transaction.paymentLinkImageUrl ?? ''),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: Image.network(
                transaction.paymentLinkImageUrl ?? '',
                height: 24,
                width: 24,
                fit: BoxFit.cover,
                // Note: In a real app, you would use a network image or a proper asset loading setup.
                // For this example, we rely on the placeholder image in the asset list.
                errorBuilder: (context, error, stackTrace) => Text(
                  transaction.paymentProfileName[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Constants.greenColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Center: Details (Name, Type, Date, Time)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${transaction.paymentProfileName}, ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDateString(transaction.paymentLinkStartDate),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right: Amount and Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${transaction.paymentLinkAmount?.toStringAsFixed(2) ?? '-'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatDateString(transaction.paymentLinkEndDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDateString(DateTime dateTime) {
    // 1. Convert the ISO 8601 string to a DateTime object
    // DateTime.parse handles the T and timezone offset automatically.

    // 2. Define the desired format
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    // 3. Format the DateTime object
    String formattedDate = formatter.format(dateTime);
    // Output: 2025-11-18

    return formattedDate;
  }
}

// --- Payments Screen Widget ---

class PaymentLinksWidget extends StatefulWidget {
  const PaymentLinksWidget({super.key});

  @override
  _PaymentLinksWidgetState createState() => _PaymentLinksWidgetState();
}

class _PaymentLinksWidgetState extends StateMVC<PaymentLinksWidget> {
  late PaymentController _con;

  _PaymentLinksWidgetState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForPaymentLinks();
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 3. Create Payment Link Button
              if (currentuser.value.user?.status == 'active') ...[
                _buildCreatePaymentLinkButton(context),
                const SizedBox(height: 10),
              ],

              // 4. Transaction List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _con.paymentLinks.length,
                  itemBuilder: (context, index) {
                    // Add a Divider except after the last item
                    return Column(
                      children: [
                        PaymentLinkListItem(
                          transaction: _con.paymentLinks[index],
                        ),
                        if (index < _con.paymentLinks.length - 1)
                          Divider(
                            indent: 75,
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey.shade200,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePaymentLinkButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // Gradient color similar to the screenshot
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
          onPressed: () {
            print("button+pessed");
            Navigator.pushNamed(
              context,
              '/CreatePaymentLink',
            ).then((v) => _con.listenForPaymentLinks());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Create Payment Link',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
