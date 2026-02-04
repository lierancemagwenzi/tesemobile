import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Optional: for making links clickable

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  final Color brandGreen = const Color(0xFF00D285);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Contact Us"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Hero Image or Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: brandGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.headset_mic_rounded,
                size: 80,
                color: brandGreen,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "How can we help you?",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Our team is available to assist you with any questions regarding Tese Africa.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            // 2. Contact Cards
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "support@teseafrica.com",
              isDark: isDark,
              onTap: () => _launchURL("mailto:support@teseafrica.com"),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              context,
              icon: Icons.chat_bubble_outline_rounded,
              title: "WhatsApp",
              subtitle: "+263 77 000 0000",
              isDark: isDark,
              onTap: () => _launchURL("https://wa.me/263770000000"),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              context,
              icon: Icons.location_on,
              title: "Office Address",
              subtitle: "123 Harare St, CBD, Zimbabwe",
              isDark: isDark,
              onTap: () {}, // Logic for opening maps
            ),

            const SizedBox(height: 40),

            // 3. Social Media Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.facebook, "Facebook"),
                _buildSocialIcon(Icons.camera_alt_outlined, "Instagram"),
                _buildSocialIcon(Icons.alternate_email, "Twitter/X"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: brandGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: brandGreen),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Icon(icon, color: brandGreen, size: 28),
    );
  }

  // Helper to handle external links
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
}
