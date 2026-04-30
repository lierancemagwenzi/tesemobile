// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:smacredit/src/payments/models/transaction_model.dart';
// import 'package:smacredit/src/payments/widgets/paymentLinks.dart';
// import 'package:smacredit/src/utils/data.dart';

// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/models/constants.dart';
// import 'package:smacredit/src/payments/controller/payment_controller.dart';
// import 'package:smacredit/src/payments/models/payment_link_model.dart';
// import 'package:smacredit/src/payments/models/transaction.dart';
// import 'package:smacredit/src/payments/widgets/payouts.dart';
// import 'package:smacredit/src/utils/data.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';

// class TransactionsWidgets extends StatefulWidget {
//   const TransactionsWidgets({super.key});

//   @override
//   StateMVC<TransactionsWidgets> createState() => _TransactionsWidgetsState();
// }

// class _TransactionsWidgetsState extends StateMVC<TransactionsWidgets> {
//   late PaymentController _con;

//   _TransactionsWidgetsState() : super(PaymentController()) {
//     _con = controller as PaymentController;
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     _con.listenForTransactions();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomOverlay(
//       loading: _con.loading,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             children: [
//               // 4. Transaction List
//               Expanded(
//                 child: ListView.builder(
//                   padding: EdgeInsets.zero,
//                   itemCount: _con.transactions.length,
//                   itemBuilder: (context, index) {
//                     // Add a Divider except after the last item
//                     return Column(
//                       children: [
//                         TransactionListItem(
//                           transaction: _con.transactions[index],
//                         ),
//                         if (index < _con.transactions.length - 1)
//                           Divider(
//                             indent: 75,
//                             height: 1,
//                             thickness: 0.5,
//                             color: Colors.grey.shade200,
//                           ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- Transaction Data Model ---

// // --- Reusable Transaction List Item Widget ---
// class TransactionListItem extends StatelessWidget {
//   final TransactionModel transaction;

//   TransactionListItem({Key? key, required this.transaction}) : super(key: key);

//   final Random _random = Random();

//   /// Picks a random color from a predefined list of primary colors.
//   Color pickRandomPrimaryColor() {
//     // 1. Define the list of possible colors
//     const List<Color> colors = [Colors.red, Colors.green, Colors.blue];

//     // 2. Generate a random index between 0 (inclusive) and the list length (exclusive)
//     int randomIndex = _random.nextInt(colors.length);

//     // 3. Return the color at the random index
//     return colors[randomIndex];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: InkWell(
//         onTap: () {
//           Navigator.pushNamed(
//             context,
//             '/TransactionDetails',
//             arguments: transaction,
//           );
//         },
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Left: Logo Container
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: pickRandomPrimaryColor().withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),

//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               alignment: Alignment.center,
//               child: transaction.paymentStatus?.toLowerCase() == 'paid'
//                   ? Icon(Icons.done, color: Constants.greenColor)
//                   : Icon(Icons.cancel, color: Colors.red),
//             ),
//             const SizedBox(width: 15),

//             // Center: Details (Name, Type, Date, Time)
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${transaction.payerName}, ',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     transaction.payerReference ?? "-",
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.calendar_month,
//                         size: 14,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         formatDateString(transaction.createdAt),
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Right: Amount and Time
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '${transaction.paymentCurrency}${transaction.amount.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 // Row(
//                 //   children: [
//                 //     Icon(
//                 //       Icons.access_time,
//                 //       size: 14,
//                 //       color: Colors.grey.shade400,
//                 //     ),
//                 //     const SizedBox(width: 4),
//                 //     Text(
//                 //       formatDateString(transaction.createdAt),
//                 //       style: TextStyle(
//                 //         color: Colors.grey.shade600,
//                 //         fontSize: 13,
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String formatDateString(DateTime dateTime) {
//     // 1. Convert the ISO 8601 string to a DateTime object
//     // DateTime.parse handles the T and timezone offset automatically.

//     // 2. Define the desired format
//     DateFormat formatter = DateFormat('yyyy-MM-dd');

//     // 3. Format the DateTime object
//     String formattedDate = formatter.format(dateTime);
//     // Output: 2025-11-18

//     return formattedDate;
//   }
// }

// // --- Payments Screen Widget ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/transaction_model.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class TransactionsWidgets extends StatefulWidget {
  const TransactionsWidgets({super.key});

  @override
  StateMVC<TransactionsWidgets> createState() => _TransactionsWidgetsState();
}

class _TransactionsWidgetsState extends StateMVC<TransactionsWidgets> {
  late PaymentController _con;

  _TransactionsWidgetsState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: SafeArea(
          child: _con.transactions.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _con.transactions.length,
                  separatorBuilder: (context, index) => Divider(
                    indent: 75,
                    height: 1,
                    thickness: 0.5,
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                  ),
                  itemBuilder: (context, index) {
                    return TransactionListItem(
                      transaction: _con.transactions[index],
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horizontal_circle_outlined,
            size: 60,
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            "No transactions found",
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionListItem({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isPaid = transaction.paymentStatus?.toLowerCase() == 'paid';
    final Color statusColor = isPaid ? Constants.greenColor : Colors.redAccent;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/TransactionDetails',
          arguments: transaction,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            // Left: Status Icon with subtle background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isPaid
                    ? Icons.arrow_downward_rounded
                    : Icons.priority_high_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Center: Payer & Reference
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.payerName ?? "Unknown Payer",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.payerReference ?? "No Reference",
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black54,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right: Amount & Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.paymentCurrency}${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRelativeDate(transaction.createdAt),
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today, ${DateFormat('HH:mm').format(date)}";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
