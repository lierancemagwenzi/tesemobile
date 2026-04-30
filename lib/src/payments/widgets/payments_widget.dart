// import 'package:flutter/material.dart';
// import 'package:smacredit/src/payments/widgets/paymentLinks.dart';
// import 'package:smacredit/src/payments/widgets/payouts.dart';
// import 'package:smacredit/src/payments/widgets/transactions.dart';

// // --- Payments Screen Widget ---

// class PaymentsScreen extends StatefulWidget {
//   final VoidCallback onPop;
//   const PaymentsScreen({super.key, required this.onPop});

//   @override
//   State<PaymentsScreen> createState() => _PaymentsScreenState();
// }

// class _PaymentsScreenState extends State<PaymentsScreen> {
//   int currentIndex = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // 1. Custom AppBar (Back, Title, Filter)
//             _buildCustomAppBar(),
//             const SizedBox(height: 10),

//             // 2. Tab Selector
//             _buildTabSelector(),
//             const SizedBox(height: 20),
//             Expanded(child: body),
//             // 3. Create Payment Link Button
//           ],
//         ),
//       ),
//     );
//   }

//   Widget get body {
//     if (currentIndex == 0) {
//       return PaymentLinksWidget();
//     } else if (currentIndex == 1) {
//       return WalletScreen();
//     } else if (currentIndex == 2) {
//       return TransactionsWidgets();
//     } else {
//       return Container();
//     }
//   }

//   Widget _buildCustomAppBar() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Back Button
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_new,
//                 size: 20,
//                 color: Colors.black,
//               ),
//               onPressed: widget.onPop, // Placeholder action
//             ),
//           ),

//           // Title
//           const Text(
//             'Payments',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),

//           // Filter Button
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: const IconButton(
//               icon: Icon(Icons.tune, size: 24, color: Colors.red),
//               onPressed: null, // Placeholder action
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabSelector() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _TabItem(
//             title: 'Payment Link',
//             isSelected: currentIndex == 0,
//             onTap: () => _setTabIndex(0),
//           ),
//           _TabItem(
//             title: 'Payouts',
//             isSelected: currentIndex == 1,
//             onTap: () => _setTabIndex(1),
//           ),
//           _TabItem(
//             title: 'Transactions',
//             isSelected: currentIndex == 2,
//             onTap: () => _setTabIndex(2),
//           ),
//         ],
//       ),
//     );
//   }

//   void _setTabIndex(int index) {
//     if (!mounted) {
//       return;
//     }
//     setState(() {
//       currentIndex = index;
//     });
//   }
// }

// // --- Helper Widget for Tab Items ---
// class _TabItem extends StatelessWidget {
//   final String title;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _TabItem({
//     required this.title,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.green : Colors.transparent,
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(
//             color: isSelected ? Colors.transparent : Colors.grey.shade300,
//           ),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Colors.grey.shade700,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:smacredit/src/payments/widgets/paymentLinks.dart';
import 'package:smacredit/src/payments/widgets/payouts.dart';
import 'package:smacredit/src/payments/widgets/transactions.dart';

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Premium Custom AppBar
            _buildCustomAppBar(isDark),
            const SizedBox(height: 15),

            // 2. Modern Pill Tab Selector
            _buildTabSelector(isDark),
            const SizedBox(height: 10),

            // 3. Dynamic Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (currentIndex) {
      case 0:
        return const PaymentLinksWidget();
      case 1:
        return const WalletScreen();
      case 2:
        return const TransactionsWidgets();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: widget.onPop,
            isDark: isDark,
          ),
          Text(
            'Payments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          _CircleButton(
            icon: Icons.tune,
            onTap: () {}, // Filter logic
            isDark: isDark,
            iconColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _ExpandedTab(
            title: 'Links',
            isSelected: currentIndex == 0,
            onTap: () => setState(() => currentIndex = 0),
            isDark: isDark,
          ),
          _ExpandedTab(
            title: 'Payouts',
            isSelected: currentIndex == 1,
            onTap: () => setState(() => currentIndex = 1),
            isDark: isDark,
          ),
          _ExpandedTab(
            title: 'History',
            isSelected: currentIndex == 2,
            onTap: () => setState(() => currentIndex = 2),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// --- Internal Helper Widgets ---

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? (isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class _ExpandedTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ExpandedTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : Colors.green)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? Colors.white38 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}
