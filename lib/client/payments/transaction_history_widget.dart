import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/payments/models/transaction_history_model.dart';
import 'package:smacredit/src/home/controller/client_controller.dart';


class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  StateMVC<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends StateMVC<TransactionHistoryScreen> {

  // Current active filter. "All" shows everything.
  String selectedFilter = "All";
  final List<String> filters = ["All", "Video", "Playlist", "Channel"];

  final Color brandGreen = const Color(0xFF00D285);


    late ClientUserController _con;

  _TransactionHistoryScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();

    _con.listenForTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Logic to filter the list based on selection
    final filteredList = _con.transactions.where((tx) {
      if (selectedFilter == "All") return true;
      return tx.type.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Purchase History"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Column(
        children: [
          // 1. Filter Horizontal List
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final bool isActive = selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isActive,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: brandGreen.withOpacity(0.2),
                    checkmarkColor: brandGreen,
                    labelStyle: TextStyle(
                      color: isActive
                          ? brandGreen
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isActive ? brandGreen : Colors.transparent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. The Filtered List
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionItem(
                        context,
                        filteredList[index],
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 60,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No $selectedFilter transactions yet.",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

 Widget _buildTransactionItem(
    BuildContext context,
    TransactionHistoryModel tx,
    bool isDark,
  ) {
    // Format the date string
    String displayDate = "";
    try {
      DateTime dt = DateTime.parse(tx.date);
      displayDate = DateFormat('MMM d, h:mm a').format(dt);
    } catch (e) {
      displayDate = tx.date;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: brandGreen.withOpacity(0.1),
          child: Icon(_getIcon(tx.type), color: brandGreen, size: 20),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "$displayDate • ${tx.paymentMethod}",
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${tx.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tx.status,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_arrow_rounded;
      case 'playlist':
        return Icons.playlist_play_rounded;
      case 'channel':
        return Icons.r_mobiledata_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
