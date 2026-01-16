import 'package:flutter/material.dart';

class TeseTermsScreen extends StatefulWidget {
  final Function(bool) onAcceptanceChanged;
  final bool shouldAccept;
  const TeseTermsScreen({
    super.key,
    required this.shouldAccept,
    required this.onAcceptanceChanged, // Make it required
  });

  @override
  State<TeseTermsScreen> createState() => _TeseTermsScreenState();
}

class _TeseTermsScreenState extends State<TeseTermsScreen> {
  // Tese Africa Brand Colors
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryText = const Color(0xFF1A0B2E);
  final Color secondaryText = const Color(0xFF6B7280);
  final Color surfaceWhite = Colors.white;

  bool _hasAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Terms and Conditions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: brandGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainTitle("Terms and Conditions"),
            _buildSubtitle("Version 2.0 | Effective Date: 09/12/2025"),
            const Divider(height: 40),

            _buildSectionTitle("1. Welcome to Tese Africa"),
            _buildBodyText(
              "This agreement sets forth the terms and conditions governing your access to and use of Tese Africa, a secure content creator platform owned and operated by Propsmart Technologies (Private) Limited (\"Propsmart,\" \"we,\" or \"us\")[cite: 3]. These Terms of Service (\"Terms\") are applicable to you in your capacity as a buyer, seller, sender, or receiver of electronic funds (collectively, \"Users\") utilizing Tese Africa[cite: 4]. Your use or access of the Service is contingent upon your acceptance of these Terms[cite: 5]. IF YOU DO NOT AGREE TO THESE LEGAL TERMS, THEN YOU ARE EXPRESSLY PROHIBITED FROM USING THE SERVICES AND YOU MUST DISCONTINUE USE IMMEDIATELY[cite: 6].",
            ),

            _buildSectionTitle("Definitions"),
            _buildBulletPoint(
              "Platform",
              "The Tese Africa website, applications, APIs, and services[cite: 8].",
            ),
            _buildBulletPoint(
              "User",
              "Any individual or entity accessing or using the Platform[cite: 9].",
            ),
            _buildBulletPoint(
              "Creator",
              "A User who publishes content and receives payments through Tese Africa[cite: 10].",
            ),
            _buildBulletPoint(
              "Supporter",
              "A User who makes payments to a Creator[cite: 11].",
            ),
            _buildBulletPoint(
              "Content",
              "Any text, audio, video, images, or digital material uploaded or shared by a Creator[cite: 12].",
            ),
            _buildBulletPoint(
              "Payment Services",
              "Payment processing services provided through third-party processors, including Smatpay[cite: 13].",
            ),

            _buildSectionTitle("2. Agreement and Language"),
            _buildBodyText(
              "By registering for or otherwise utilizing the Tese Africa service, you signify your acknowledgment of having read, understood, and agreed to be bound by the terms and conditions set forth in this Agreement[cite: 15]. For your convenience, it is advisable to review, save, or print a copy of this Agreement for your records[cite: 16]. Your acceptance will be confirmed electronically during the registration process through actions such as ticking a checkbox or clicking a button[cite: 17]. Please note that this Agreement is provided exclusively in English[cite: 18].",
            ),

            _buildSectionTitle("3. Using Tese Africa Legally"),
            _buildBodyText(
              "Your use of Tese Africa must at-all-times comply with all applicable laws and regulations in the Zimbabwean jurisdiction, regardless of your purpose for using the service[cite: 20]. This includes, but is not limited to, financial regulations, consumer protection laws, and anti-money laundering (AML) requirements[cite: 21]. By using Tese Africa, you acknowledge and agree to be bound by the terms and conditions set forth in our Acceptable Use Policy (AUP)[cite: 24].",
            ),

            _buildSectionTitle("4. Registration Requirements"),
            _buildBodyText(
              "To register for a Tese Africa account and access the Service, you must:",
            ),
            _buildBulletPoint(
              "Banked Entity",
              "Be a banked individual or company with a financial institution in Zimbabwe that participates in the Tese Africa network[cite: 29].",
            ),
            _buildBulletPoint(
              "Legal Capacity",
              "Possess the legal capacity to enter into binding contracts (typically 18 years of age or older)[cite: 30].",
            ),
            _buildBulletPoint(
              "Content Creator",
              "A Content Creator, who develops and produces their own content with social media presence[cite: 31].",
            ),

            _buildSubHeader("Required Information (Individual):"),
            _buildBodyText(
              "• National ID [cite: 35]\n• Proof of residence [cite: 36]\n• Zimbabwean bank statement (last 3 months) [cite: 37]\n• Valid payment instrument details [cite: 38]",
            ),

            _buildSectionTitle("5. Payout Clause"),
            _buildBodyText(
              "Payouts to merchants will be processed upon receipt of a valid payout request[cite: 56]. The initial payout for new merchants may take up to 5 business days to process[cite: 57]. Subsequent payouts will be processed within 24-48 hours[cite: 58].",
            ),
            _buildSubHeader("Fee Structure:"),
            _buildFeeTable(),
            _buildBodyText(
              "All transfer charges including VAT shall be borne solely by the merchant[cite: 60]. These fees are subject to change and will be communicated to clients in advance[cite: 73].",
            ),

            _buildSectionTitle("6. Mandatory Branding"),
            _buildBodyText(
              "All creators are required to display the \"Powered by Tese Africa\" branding on every payment interface where the Tese Africa system is implemented[cite: 76]. Non-compliance shall be deemed a material breach and may result in suspension[cite: 79].",
            ),

            _buildSectionTitle("8. Limitation of Liability"),
            _buildBodyText(
              "TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE SERVICES[cite: 219]. Propsmart is not liable for any loss or damage caused by viruses, distributed denial-of-service attacks, or other harmful materials[cite: 132].",
            ),

            _buildSectionTitle("13. Governing Law"),
            _buildBodyText(
              "These Legal Terms shall be governed by and defined following the laws of Zimbabwe[cite: 193]. Propsmart technologies Pvt Ltd and yourself irrevocably consent that the courts of Zimbabwe shall have exclusive jurisdiction to resolve any dispute[cite: 194].",
            ),

            const SizedBox(height: 40),
            _buildFinalAgreement(),
            const SizedBox(height: 40),
            if (widget.shouldAccept) _buildAcceptanceCard(),
            const SizedBox(height: 20),
            if (widget.shouldAccept) _buildStickyFooter(),
          ],
        ),
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
  // --- Helper Widgets for Styling ---

  Widget _buildMainTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: primaryText,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: TextStyle(color: secondaryText, fontSize: 14)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
    );
  }

  Widget _buildBulletPoint(String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeTable() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildTableRow("Currency", "Fee Structure", isHeader: true),
          _buildTableRow("USD", "9.5% + \$0.50 per transaction"),
          _buildTableRow("ZWG", "9.5% + ZWG15 per transaction"),
        ],
      ),
    );
  }

  Widget _buildTableRow(String left, String right, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: isHeader ? Colors.grey[100] : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              right,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalAgreement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brandGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "BY USING TESE AFRICA, YOU ACKNOWLEDGE THAT YOU HAVE READ, UNDERSTOOD, AND AGREE TO BE BOUND BY THESE TERMS[cite: 238].",
        style: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
