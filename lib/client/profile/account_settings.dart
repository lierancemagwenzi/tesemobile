import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // State for toggles
  bool _isTwoFactorEnabled = false;
  bool _isBiometricEnabled = true;
  bool _isNotificationsEnabled = true;

  // Tese Africa Branding Colors
  static const Color teseGreen = Color(0xFF52B681);
  static const Color teseRed = Color(0xFFE57373);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Account Settings",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // SECURITY SECTION
            _buildSectionHeader(context, "Security"),
            _buildSettingsGroup([
              _buildSettingTile(
                context,
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {},
              ),
              _buildSettingSwitch(
                context,
                icon: Icons.phonelink_lock_outlined,
                title: "Two-Factor Authentication",
                value: _isTwoFactorEnabled,
                onChanged: (val) => setState(() => _isTwoFactorEnabled = val),
              ),
              _buildSettingSwitch(
                context,
                icon: Icons.security_outlined,
                title: "Biometric Login",
                value: _isBiometricEnabled,
                onChanged: (val) => setState(() => _isBiometricEnabled = val),
              ),
            ]),

            const SizedBox(height: 25),

            // PREFERENCES SECTION
            _buildSectionHeader(context, "Preferences"),
            _buildSettingsGroup([
              _buildSettingSwitch(
                context,
                icon: Icons.mail_outline,
                title: "Email Notifications",
                value: _isNotificationsEnabled,
                onChanged: (val) =>
                    setState(() => _isNotificationsEnabled = val),
              ),
              _buildSettingTile(
                context,
                icon: Icons.language_outlined,
                title: "Language",
                trailingText: "English",
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 25),

            // DANGER ZONE
            _buildSectionHeader(context, "Danger Zone"),
            _buildSettingsGroup([
              _buildSettingTile(
                context,
                icon: Icons.delete_outline,
                title: "Delete Account",
                iconColor: teseRed,
                titleColor: teseRed,
                onTap: () {
                  // Show confirmation dialog
                },
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailingText,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? (isDark ? Colors.white70 : Colors.black54),
      ),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: teseGreen,
      ),
    );
  }
}
