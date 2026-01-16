import 'package:flutter/material.dart';
import 'package:smacredit/src/content-creator/widgets/channels_widget.dart';
import 'package:smacredit/src/home/widgets/dashboard.dart';
import 'package:smacredit/src/payments/widgets/payments_widget.dart';
import 'package:smacredit/src/profile/widgets/profile.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

class TeseDrawer extends StatelessWidget {
  const TeseDrawer({super.key});

  // Tese Africa Branding Colors
  static const Color teseGreen = Color(0xFF52B681);
  static const Color teseGold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // 1. Drawer Header (User Profile Summary)
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : teseGreen.withOpacity(0.1),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: teseGreen,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            accountName: Text(
              "${currentuser.value.user?.fullname}",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              "${currentuser.value.user?.email}",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),

          // 2. Menu Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerSection(context, "Content creator Profile"),

                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => Dashboard(
                          onProfileTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.video_library_outlined,
                  title: "VOD Management",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ChannelListScreen(
                          onPop: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.money,
                  title: "Payment Links",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => PaymentsScreen(
                          onPop: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),

                // _buildDrawerItem(
                //   context,
                //   icon: Icons.money,
                //   title: "Payment Links",
                //   onTap: () {},
                // ),
                const Divider(),
                _buildDrawerSection(context, "Account"),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: "Personal Details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ProfileScreen(
                          onPop: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );

                    // Navigate to PersonalDetailsScreen
                  },
                ),
                // _buildDrawerItem(
                //   context,
                //   icon: Icons.settings_outlined,
                //   title: "Account Settings",
                //   onTap: () {
                //     // Navigate to AccountSettingsScreen
                //   },
                // ),
                // _buildDrawerItem(
                //   context,
                //   icon: Icons.account_balance_wallet_outlined,
                //   title: "Subscription & VOD",
                //   onTap: () {},
                // ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),
              ],
            ),
          ),

          // 3. Logout Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: "Sign Out",
              iconColor: Colors.redAccent,
              titleColor: Colors.redAccent,
              onTap: () {
                // Handle Sign Out
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildDrawerSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isDark ? Colors.white70 : Colors.black87),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? (isDark ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }
}
