import 'package:flutter/material.dart';
import 'package:smacredit/src/payments/widgets/paymentLinks.dart';
import 'package:smacredit/src/payments/widgets/payouts.dart';
import 'package:smacredit/src/payments/widgets/transactions.dart';

// --- Payments Screen Widget ---

class PaymentsScreen extends StatefulWidget {
  final VoidCallback onPop;
  const PaymentsScreen({super.key, required this.onPop});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom AppBar (Back, Title, Filter)
            _buildCustomAppBar(),
            const SizedBox(height: 10),

            // 2. Tab Selector
            _buildTabSelector(),
            const SizedBox(height: 20),
            Expanded(child: body),
            // 3. Create Payment Link Button
          ],
        ),
      ),
    );
  }

  Widget get body {
    if (currentIndex == 0) {
      return PaymentLinksWidget();
    } else if (currentIndex == 1) {
      return WalletScreen();
    } else if (currentIndex == 2) {
      return TransactionsWidgets();
    } else {
      return Container();
    }
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black,
              ),
              onPressed: widget.onPop, // Placeholder action
            ),
          ),

          // Title
          const Text(
            'Payments',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // Filter Button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const IconButton(
              icon: Icon(Icons.tune, size: 24, color: Colors.red),
              onPressed: null, // Placeholder action
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TabItem(
            title: 'Payment Link',
            isSelected: currentIndex == 0,
            onTap: () => _setTabIndex(0),
          ),
          _TabItem(
            title: 'Payouts',
            isSelected: currentIndex == 1,
            onTap: () => _setTabIndex(1),
          ),
          _TabItem(
            title: 'Transactions',
            isSelected: currentIndex == 2,
            onTap: () => _setTabIndex(2),
          ),
        ],
      ),
    );
  }

  void _setTabIndex(int index) {
    if (!mounted) {
      return;
    }
    setState(() {
      currentIndex = index;
    });
  }
}

// --- Helper Widget for Tab Items ---
class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
