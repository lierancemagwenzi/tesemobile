// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/payments/controller/payment_controller.dart';
// import 'package:smacredit/src/payments/models/payout_model.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';

// // --- Data Model for a Single Transaction ---
// class WithdrawalTransaction {
//   final String status;
//   final String method;
//   final String date;
//   final String time;
//   final double amount;

//   const WithdrawalTransaction({
//     required this.status,
//     required this.method,
//     required this.date,
//     required this.time,
//     required this.amount,
//   });
// }

// // --- Reusable Transaction List Item Widget ---
// class WithdrawalListItem extends StatelessWidget {
//   final PayoutModel transaction;

//   const WithdrawalListItem({Key? key, required this.transaction})
//     : super(key: key);

//   // Helper function to determine color based on status
//   Color _getStatusColor(String status, {bool background = true}) {
//     switch (status.toLowerCase()) {
//       case 'paid':
//         return background ? Colors.green.shade50 : Colors.green.shade700;
//       case 'pending':
//         return background ? Colors.grey.shade200 : Colors.grey.shade700;
//       case 'in progress':
//         return background ? Colors.orange.shade50 : Colors.orange.shade700;
//       case 'failed':
//         return background ? Colors.red.shade50 : Colors.red.shade700;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Color textColor = _getStatusColor(
//       transaction.payoutMerchantStatus ?? "",
//       background: false,
//     );
//     final Color backgroundColor = _getStatusColor(
//       transaction.payoutMerchantStatus ?? '',
//       background: true,
//     );

//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(context, '/PayoutDetail', arguments: transaction);
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Left Side: Status Tag and Details
//             Row(
//               children: [
//                 // Status Tag
//                 Container(
//                   width: 80,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: backgroundColor,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(
//                     transaction.payoutMerchantStatus ?? '',
//                     style: TextStyle(
//                       color: textColor,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 15),

//                 // Transaction Details (Method and Date)
//                 SizedBox(
//                   width: 200,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         transaction.payoutMerchantRef ?? "",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                           color: Colors.black87,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_month,
//                             size: 14,
//                             color: Colors.grey.shade500,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             formatDateString(
//                               transaction.updatedAt ?? DateTime.now(),
//                             ),
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 13,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             // Right Side: Amount and Time
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '\$${transaction.payoutMerchantAmount?.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.access_time,
//                       size: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       formatTimeString(transaction.updatedAt ?? DateTime.now()),
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// String formatTimeString(DateTime dateTime) {
//   // 1. Convert the ISO 8601 string to a DateTime object
//   // DateTime.parse handles the T and timezone offset automatically.

//   // 2. Define the desired format
//   DateFormat formatter = DateFormat('HH:mm');

//   // 3. Format the DateTime object
//   String formattedDate = formatter.format(dateTime);
//   // Output: 2025-11-18

//   return formattedDate;
// }

// String formatDateString(DateTime dateTime) {
//   // 1. Convert the ISO 8601 string to a DateTime object
//   // DateTime.parse handles the T and timezone offset automatically.

//   // 2. Define the desired format
//   DateFormat formatter = DateFormat('yyyy-MM-dd');

//   // 3. Format the DateTime object
//   String formattedDate = formatter.format(dateTime);
//   // Output: 2025-11-18

//   return formattedDate;
// }
// // --- Main Wallet Screen Widget ---

// class WalletScreen extends StatefulWidget {
//   const WalletScreen({super.key});

//   @override
//   StateMVC<WalletScreen> createState() => _WalletScreenState();
// }

// class _WalletScreenState extends StateMVC<WalletScreen> {
//   late PaymentController _con;

//   _WalletScreenState() : super(PaymentController()) {
//     _con = controller as PaymentController;
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     _con.listenForPayouts();
//   }

//   // Mock Transaction Data
//   static final List<WithdrawalTransaction> mockHistory = [
//     const WithdrawalTransaction(
//       status: 'Completed',
//       method: 'Bank Transfer',
//       date: 'Wednesday 20 March',
//       time: '12:00:00',
//       amount: 100.00,
//     ),
//     const WithdrawalTransaction(
//       status: 'Pending',
//       method: 'Bank Transfer',
//       date: 'Thursday 21 March',
//       time: '14:30:00',
//       amount: 200.00,
//     ),
//     const WithdrawalTransaction(
//       status: 'In Progress',
//       method: 'Ecocash',
//       date: 'Friday 22 March',
//       time: '09:15:00',
//       amount: 150.00,
//     ),
//     const WithdrawalTransaction(
//       status: 'Failed',
//       method: 'One Money',
//       date: 'Saturday 23 March',
//       time: '16:45:00',
//       amount: 75.00,
//     ),
//     const WithdrawalTransaction(
//       status: 'Completed',
//       method: 'One Money',
//       date: 'Sunday 24 March',
//       time: '11:00:00',
//       amount: 300.00,
//     ),
//     const WithdrawalTransaction(
//       status: 'Pending',
//       method: 'One Money',
//       date: 'Monday 25 March',
//       time: '10:30:00',
//       amount: 50.00,
//     ),
//     const WithdrawalTransaction(
//       status: 'Completed',
//       method: 'Paypal Transfer',
//       date: 'Tuesday 26 March',
//       time: '15:00:00',
//       amount: 225.00,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return CustomOverlay(
//       loading: _con.loading,
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: AppBar(
//           automaticallyImplyLeading:
//               false, // Assuming this is not the root screen
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           toolbarHeight: 0,
//         ),
//         body: _con.payouts.isEmpty
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [Center(child: Text("No payouts on this account"))],
//               )
//             : Column(
//                 children: [
//                   // 1. Balance Header Section
//                   // _buildBalanceHeader(context),

//                   // // 2. Withdraw Button
//                   // _buildWithdrawButton(),

//                   // 3. Transaction List
//                   Expanded(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.only(
//                         top: 10,
//                         left: 20,
//                         right: 20,
//                       ),
//                       itemCount: _con.payouts.length,
//                       itemBuilder: (context, index) {
//                         return WithdrawalListItem(
//                           transaction: _con.payouts[index],
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildBalanceHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: const [
//               // Available Balance
//               _BalanceItem(
//                 label: 'Available Balance',
//                 amount: '\$1,700.00',
//                 icon: Icons.calendar_today,
//                 iconColor: Colors.red, // Placeholder icon and color
//               ),
//               // Monthly Earnings
//               _BalanceItem(
//                 label: 'Monthly Earnings',
//                 amount: '\$400.00',
//                 icon: Icons.calendar_month,
//                 iconColor: Colors.red,
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           // Red Divider Line
//           Container(
//             height: 2,
//             width: double.infinity,
//             color: Colors.red.shade400,
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildWithdrawButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
//       child: Container(
//         width: double.infinity,
//         height: 55,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           // Gradient color similar to the screenshot
//           gradient: LinearGradient(
//             colors: [Colors.green.shade700, Colors.lightGreen.shade400],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.green.withOpacity(0.4),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: TextButton(
//           onPressed: () {
//             // Handle withdrawal action
//           },
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Icon(Icons.send, color: Colors.white, size: 22),
//               SizedBox(width: 10),
//               Text(
//                 'Withdraw',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- Helper Widget for Balance/Earnings Header Items ---
// class _BalanceItem extends StatelessWidget {
//   final String label;
//   final String amount;
//   final IconData icon;
//   final Color iconColor;

//   const _BalanceItem({
//     required this.label,
//     required this.amount,
//     required this.icon,
//     required this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
//           const SizedBox(height: 4),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 amount,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Icon(icon, color: iconColor, size: 24),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/payout_model.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

// --- Reusable Transaction List Item Widget ---
class WithdrawalListItem extends StatelessWidget {
  final PayoutModel transaction;

  const WithdrawalListItem({super.key, required this.transaction});

  // Adaptive status colors for Dark/Light mode
  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'paid':
        return isDark ? Colors.greenAccent : Colors.green.shade700;
      case 'pending':
        return isDark ? Colors.orangeAccent : Colors.orange.shade700;
      case 'failed':
        return isDark ? Colors.redAccent : Colors.red.shade700;
      default:
        return isDark ? Colors.white38 : Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color statusColor = _getStatusColor(
      transaction.payoutMerchantStatus ?? "",
      isDark,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context,
          '/PayoutDetail',
          arguments: transaction,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.payoutMerchantStatus?.toLowerCase() == 'paid'
                ? Icons.account_balance_wallet
                : Icons.pending_actions,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          transaction.payoutMerchantRef ?? "No Reference",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                formatDateString(transaction.updatedAt ?? DateTime.now()),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              const Text("•", style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              Text(
                formatTimeString(transaction.updatedAt ?? DateTime.now()),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${transaction.payoutMerchantAmount?.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (transaction.payoutMerchantStatus ?? '').toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Formatting helpers kept as per original logic
String formatTimeString(DateTime dateTime) =>
    DateFormat('HH:mm').format(dateTime);
String formatDateString(DateTime dateTime) =>
    DateFormat('yyyy-MM-dd').format(dateTime);

// --- Main Wallet Screen Widget ---

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  StateMVC<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends StateMVC<WalletScreen> {
  late PaymentController _con;

  _WalletScreenState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForPayouts();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Payout History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
        ),
        body: _con.payouts.isEmpty
            ? _buildEmptyState(isDark)
            : Column(
                children: [
                  // Optional: Re-enabled Balance Header if needed
                  // _buildBalanceHeader(context, isDark),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _con.payouts.length,
                      itemBuilder: (context, index) {
                        return WithdrawalListItem(
                          transaction: _con.payouts[index],
                        );
                      },
                    ),
                  ),
                ],
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
            Icons.history_toggle_off,
            size: 80,
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            "No payouts on this account",
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
