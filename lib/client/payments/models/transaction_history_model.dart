class TransactionHistoryModel {
  final String title;
  final double amount;
  final String status;
  final String date;
  final String paymentMethod;
  final String type;

  TransactionHistoryModel({
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
    required this.paymentMethod,
    required this.type,
  });

  // Factory to convert JSON map to our Model object
  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      title: json['title'] ?? '',
      // Handle both int and double from JSON safely
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
