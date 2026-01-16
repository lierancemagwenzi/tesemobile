import 'package:flutter/material.dart';

class TesePrivacyPolicyScreen extends StatelessWidget {
  const TesePrivacyPolicyScreen({super.key});

  // Tese Africa Brand Colors
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryText = const Color(0xFF1A0B2E);
  final Color secondaryText = const Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
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
            _buildMainTitle("Privacy Policy"),
            _buildSubtitle("Last Updated: 1/01/26"),
            const Divider(height: 40),

            _buildSectionTitle("1. Introduction"),
            _buildBodyText(
              "Welcome to Tese Africa. Tese Africa (\"we,\" \"us,\" or \"our\") respects your privacy and is committed to protecting your personal data in accordance with Zimbabwe's Cyber and Data Protection Act [Chapter 12:07] and Statutory Instrument 155 of 2024. This Privacy Policy explains what data we collect, how we use it, and your legal rights. By using our services, you consent to this policy.",
            ),

            _buildSectionTitle("2. Information We Collect"),
            _buildSubHeader("A. Personal Data (Provided by You)"),
            _buildBodyText(
              "• Identity & Contact: Name, email, phone, physical address, and government-issued ID for verification.",
            ),
            _buildBodyText(
              "• Financial Data: Payment and bank account details processed via Smatpay.",
            ),

            _buildSubHeader("B. Automated Data"),
            _buildBodyText(
              "• Technical & Usage: IP address, browser type, device info, and clickstream data collected via cookies.",
            ),

            _buildSubHeader("C. Third-Party Data"),
            _buildBodyText(
              "• Social Media: Info from linked accounts like Google or Facebook. Also includes publicly available records for due diligence.",
            ),

            _buildSectionTitle("3. How We Collect Information"),
            _buildBulletPoint(
              "Direct Collection",
              "When you register, fill out forms, or communicate with us.",
            ),
            _buildBulletPoint(
              "Automated Technologies",
              "Through cookies and tracking technologies when you use our platform.",
            ),

            _buildSectionTitle("4. Legal Basis for Processing"),
            _buildBodyText("We process data based on:"),
            _buildBulletPoint(
              "Consent",
              "Explicit permission for marketing, which you can withdraw anytime.",
            ),
            _buildBulletPoint(
              "Contractual Necessity",
              "To perform our agreement with you.",
            ),
            _buildBulletPoint(
              "Legal Obligation",
              "Compliance with anti-fraud, tax, and Zimbabwean law.",
            ),
            _buildBulletPoint(
              "Legitimate Interests",
              "To improve services and ensure security.",
            ),

            _buildSectionTitle("5. How We Use Your Information"),
            _buildBodyText(
              "We use your data to provide services, process transactions, verify identity, and comply with legal obligations under the Data Protection Act.",
            ),
            _buildUsageTable(),

            _buildSectionTitle("6. Data Sharing & Disclosure"),
            _buildBodyText(
              "We may share data with service providers (payment processors, hosting), legal authorities if required by law, or business partners with your consent. We never sell your data to third-party advertisers.",
            ),

            _buildSectionTitle("7. Data Security"),
            _buildBodyText(
              "We implement technical safeguards (SSL/TLS encryption, firewalls), administrative controls (staff training), and physical protections (secure server locations). No system is 100% secure; please use strong passwords.",
            ),

            _buildSectionTitle("8. Your Rights (Under Zimbabwean Law)"),
            _buildBodyText(
              "You have the right to access, rectify, or erase your data. You may also object to processing or withdraw consent. Contact info@smatechgroup.com to exercise these rights; we respond within 30 days.",
            ),

            _buildSectionTitle("9. Data Retention"),
            _buildBulletPoint(
              "Active Users",
              "Until an account deletion request is made.",
            ),
            _buildBulletPoint(
              "Legal Records",
              "Tax records (5+ years) and transaction history (7+ years).",
            ),
            _buildBulletPoint(
              "Marketing Data",
              "Until consent withdrawal or 2 years of inactivity.",
            ),

            _buildSectionTitle("10. Cookies & Tracking"),
            _buildBodyText(
              "We use Essential cookies for site functionality, Analytics cookies (Google Analytics) for improvements, and Marketing cookies only with your consent.",
            ),

            _buildSectionTitle("11. International Data Transfers"),
            _buildBodyText(
              "If data crosses borders, we ensure recipient countries have comparable protection laws or utilize Standard Contractual Clauses (SCCs).",
            ),

            _buildSectionTitle("12. Contact Us"),
            _buildBodyText("For privacy inquiries, contact us at:"),
            _buildBodyText("Email: legal@smatechgroup.com"),
            _buildBodyText("Address: 13 Brentwood Avenue, Groombridge, Harare"),

            const SizedBox(height: 40),
            _buildFinalNote(),
            const SizedBox(height: 40),
          ],
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
        ),
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
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

  Widget _buildUsageTable() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildTableRow("Purpose", "Legal Basis", isHeader: true),
          _buildTableRow("Providing Services", "Contractual Necessity"),
          _buildTableRow("Identity (KYC)", "Legal Obligation"),
          _buildTableRow("Prevent Fraud", "Legitimate Interest"),
          _buildTableRow("Service Updates", "Consent"),
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
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalNote() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brandGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "BY USING OUR SERVICES, YOU ACKNOWLEDGE THAT YOU HAVE READ AND CONSENT TO THIS PRIVACY POLICY.",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
