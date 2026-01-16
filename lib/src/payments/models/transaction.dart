import 'dart:ui';

class Transaction {
  final String logoUrl;
  final String companyName;
  final String type;
  final String date;
  final String time;
  final double amount;
  final Color logoColor; // Added for different logo backgrounds

  const Transaction({
    required this.logoUrl,
    required this.companyName,
    required this.type,
    required this.date,
    required this.time,
    required this.amount,
    required this.logoColor,
  });
}
