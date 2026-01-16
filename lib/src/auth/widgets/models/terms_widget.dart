import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  final Function(bool) onAcceptanceChanged;
  final bool shouldAccept;
  const TermsAndConditionsScreen({
    super.key,
    required this.shouldAccept,
    required this.onAcceptanceChanged, // Make it required
  });
  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  // Theme Colors
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryText = const Color(0xFF1A0B2E);
  final Color brandBackground = const Color(0xFFF4F7F6);
  final Color surfaceWhite = Colors.white;

  bool _hasAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER
            _buildAppBar(),

            // 2. SCROLLABLE CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  const Text(
                    "Version 2.0 | Effective Date: 09/12/2025",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle("1. Welcome to Tese Africa"),
                  _buildBodyText(
                    "This agreement sets forth the terms and conditions governing your access to and use of Tese Africa, "
                    "a secure content creator platform owned and operated by Propsmart Technologies (Private) Limited (\"Propsmart\").",
                  ),

                  _buildSectionTitle("2. Definitions"),
                  _buildBulletPoint(
                    "Platform: Tese Africa website, applications, APIs, and services.",
                  ),
                  _buildBulletPoint(
                    "Creator: A User who publishes content and receives payments.",
                  ),
                  _buildBulletPoint(
                    "Supporter: A User who makes payments to a Creator.",
                  ),
                  _buildBulletPoint(
                    "Content: Digital material uploaded or shared by a Creator.",
                  ),

                  _buildSectionTitle("3. Using Tese Africa Legally"),
                  _buildBodyText(
                    "Your use of Tese Africa must at all times comply with all applicable laws and regulations in the Zimbabwean jurisdiction. "
                    "This includes financial regulations and anti-money laundering (AML) requirements.",
                  ),

                  _buildSectionTitle("4. Payouts and Fees"),
                  _buildBodyText(
                    "The following platform fee structure applies:",
                  ),
                  _buildFeeCard(
                    "USD Transactions",
                    "9.5% + \$0.50 per transaction",
                  ),
                  _buildFeeCard(
                    "ZWG Transactions",
                    "9.5% + ZWG15 per transaction",
                  ),
                  _buildBodyText(
                    "Initial payouts for new merchants may take up to 5 business days to process. "
                    "Subsequent payouts are processed within 24-48 hours of a valid request.",
                  ),

                  _buildSectionTitle("5. Mandatory Branding"),
                  _buildBodyText(
                    "All creators are required to display the \"Powered by Tese Africa\" branding on every payment interface "
                    "where the system is implemented. Removal or modification is strictly prohibited.",
                  ),

                  _buildSectionTitle("6. Termination"),
                  _buildBodyText(
                    "Tese Africa reserves the right to terminate access for inactivity, policy violations, or suspected fraudulent activity.",
                  ),

                  const SizedBox(height: 30),

                  if (widget.shouldAccept) _buildAcceptanceCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 3. STICKY FOOTER ACTION
            if (widget.shouldAccept) _buildStickyFooter(),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: brandGreen,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Terms of Service",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balancing spacer
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: primaryText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: primaryText.withOpacity(0.8),
        fontSize: 15,
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: brandGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(child: _buildBodyText(text)),
        ],
      ),
    );
  }

  Widget _buildFeeCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Spacer(),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceCard() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasAccepted ? brandGreen : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: CheckboxListTile(
        value: _hasAccepted,
        activeColor: brandGreen,
        title: Text(
          "I have read and explicitly agree to the Terms of Service and Acceptable Use Policy.",
          style: TextStyle(fontSize: 13, color: primaryText),
        ),
        onChanged: (val) {
          setState(() {
            _hasAccepted = val ?? false;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _hasAccepted
            ? () {
                widget.onAcceptanceChanged(_hasAccepted);
                // 2. Close the screen
                Navigator.pop(context);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          disabledBackgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "ACCEPT AND CONTINUE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
