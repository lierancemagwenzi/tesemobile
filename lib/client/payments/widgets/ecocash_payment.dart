import 'package:flutter/material.dart';

class PaymentWaitingScreen extends StatelessWidget {
  final String phoneNumber;
  final String paymentMethod;

  // Custom Tese Colors
  static const Color teseGreen = Color(0xFF1B5E20);
  static const Color teseGold = Color(0xFFFFD700);

  const PaymentWaitingScreen({
    super.key,
    required this.phoneNumber,
    this.paymentMethod = "Ecocash",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Inherits from your global theme
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Payment Processing",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Tese Themed Loader
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      // Gold in dark mode, Green in light mode
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? teseGold : teseGreen,
                      ),
                      backgroundColor: (isDark ? teseGold : teseGreen)
                          .withOpacity(0.1),
                    ),
                  ),
                  Icon(
                    Icons.payments_outlined,
                    size: 60,
                    color: isDark ? teseGold : teseGreen,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Dynamic Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Waiting for $paymentMethod Payment sent to $phoneNumber",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                "Please enter your PIN on your mobile device to complete the transaction.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const Spacer(),

            // Tese Primary Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Deep Green background for Tese Branding
                    backgroundColor: teseGreen,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // _verifyPaymentStatus(context);

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "CONFIRM PAYMENT DONE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ),

            // Secondary help button
            // TextButton(
            //   onPressed: () {
            //     // Implement resend logic
            //   },
            //   child: Text(
            //     "Didn't receive the prompt?",
            //     style: TextStyle(
            //       color: isDark ? teseGold : teseGreen,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _verifyPaymentStatus(BuildContext context) {
    // Show a modern themed dialog or bottom sheet for the actual check
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: teseGold)),
    );

    // Mock verification delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close dialog
      // Handle success or failure logic here
    });
  }
}
