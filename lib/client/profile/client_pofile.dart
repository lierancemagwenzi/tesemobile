import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smacredit/client/profile/update_clint_profile.dart';
import 'package:smacredit/src/auth/controller/LoginController.dart';
import 'package:smacredit/src/auth/widgets/models/terms_widget2.dart';
import 'package:smacredit/src/repositories/settings_repository.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/theme/app_theme.dart';
import 'package:smacredit/src/theme/theme_service.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
// import 'package:smacredit/src/home/controller/client_controller.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends StateMVC<ClientProfileScreen> {
  bool isNotificationsEnabled = true;

  late LoginController _con;

  _ClientProfileScreenState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  @override
  void initState() {
    super.initState();

    _con.getClientAccountInfo();
  }

  Future<void> _pickFile(bool isLogo) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    final Color brandGreen = const Color(0xFF00D285);
    if (result != null) {
      File file = File(result.files.single.path!);
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: brandGreen,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: brandGreen,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',

            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        _con.uploadProfile(File(croppedFile.path), isLogo);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    bool loggedIn =
        currentuser.value.user?.email != null && _con.userInfo != null;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          actions: _con.userInfo == null
              ? null
              : [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              UpdateProfileScreen(user: _con.userInfo!),
                        ),
                      ).then((v) {
                        _con.getClientAccountInfo();
                      });
                    },

                    child: Icon(Icons.edit),
                  ),
                ],
          title: Text(
            "Profile",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (loggedIn) ...[
                _buildProfileHeader(isDark),
                const SizedBox(height: 15),
              ],

              if (loggedIn) ...[
                _buildStatisticsRow(isDark, textColor, subTextColor),
                const SizedBox(height: 25),
              ],
              _buildSettingsList(isDark, textColor, loggedIn),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "App Version: 1.0.3(2)",
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    // Define fallback colors based on the theme
    final Color fallbackBg = isDark
        ? const Color(0xFF1C1C1E)
        : Colors.grey.shade200;
    final Color borderColor = isDark ? const Color(0xFF0D1117) : Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomLeft,
      children: [
        // 1. COVER IMAGE WITH PLACEHOLDER
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(color: fallbackBg),
          child: Image.network(
            _con.userInfo?.banner ?? "", // Your model's cover field
            fit: BoxFit.cover,
            // Placeholder while loading
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: brandGreen,
                  strokeWidth: 2,
                ),
              );
            },
            // Fallback if image fails or URL is empty
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: fallbackBg,
                child: Icon(
                  Icons.panorama_outlined,
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                  size: 40,
                ),
              );
            },
          ),
        ),

        // Camera button for cover image
        Positioned(
          top: 10,
          right: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black38,
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                _pickFile(false);
              },
            ),
          ),
        ),

        // 2. PROFILE PICTURE WITH PLACEHOLDER
        Positioned(
          bottom: -40,
          left: 20,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 4),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    _pickFile(true);
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: fallbackBg,
                    child: ClipOval(
                      child: Image.network(
                        _con.userInfo?.selfie ??
                            "", // Your model's profile image field
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          // Initial of the user name as a placeholder
                          return Center(
                            child: Text(
                              currentuser.value.user?.name?[0].toUpperCase() ??
                                  "T",
                              style: TextStyle(
                                color: brandGreen,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Green Edit Badge
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: brandGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Edit Profile Button
        // Positioned(
        //   bottom: -40,
        //   right: 20,
        //   child: ElevatedButton(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute<void>(
        //           builder: (context) =>
        //               UpdateProfileScreen(user: _con.userInfo!),
        //         ),
        //       );
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: const Color(0xFF1A1F2B),
        //       foregroundColor: Colors.white,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //       elevation: 0,
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: const Text("Edit Profile"),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  // 1. HEADER: Cover Image & Profile Pic
  Widget _buildProfileHeader1(bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomLeft,
      children: [
        // Cover Image
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://via.placeholder.com/800x400?text=THINK+BIG+DIFFERENT",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
        // Profile Picture with Edit Badge
        Positioned(
          bottom: -40,
          left: 20,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF0D1117) : Colors.white,
                    width: 4,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage("_"),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: brandGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Edit Profile Button
        Positioned(
          bottom: -40,
          right: 20,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1F2B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Edit Profile"),
          ),
        ),
      ],
    );
  }

  void _navigateToTerms() {
    // Navigates to the TeseTermsScreen you built earlier
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeseTermsScreen(
          shouldAccept: false,
          onAcceptanceChanged: (bool p1) {},
          // Pass any arguments needed for your terms screen
          // e.g., onAccept: () => setState(() => _isTermsAccepted = true)
        ),
      ),
    );
  }

  // 2. NAME & STATS
  Widget _buildStatisticsRow(bool isDark, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_con.userInfo?.fullname}",
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${_con.userInfo?.email}",
            style: TextStyle(color: subTextColor, fontSize: 14),
          ),
          const SizedBox(height: 5),
          // Text(
          //   "Video enthusiast • Content lover 🎥",
          //   style: TextStyle(color: textColor, fontSize: 13),
          // ),
          const SizedBox(height: 20),
          // Row(
          //   children: [
          //     _statItem("24", "Following", isDark, textColor, subTextColor),
          //     _statItem("156", "Liked Videos", isDark, textColor, subTextColor),
          //     _statItem("32", "Purchases", isDark, textColor, subTextColor),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _statItem(
    String value,
    String label,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: TextStyle(color: subTextColor, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // 3. SETTINGS LIST
  Widget _buildSettingsList(bool isDark, Color textColor, bool loggedIn) {
    return Column(
      children: [
        if (loggedIn)
          _menuItem(
            Icons.person_outline,
            "Personal Details",
            voidCallback: () {
              Navigator.pushNamed(
                context,
                '/PersonalDetails',
                arguments: _con.userInfo,
              );
            },
          ),
        if (loggedIn)
          _menuItem(
            Icons.file_download_outlined,
            "Downloads",
            voidCallback: () {
              Navigator.pushNamed(context, '/Downloads');
            },
          ),
        // if (loggedIn)
        //   _menuItem(
        //     Icons.notifications_none_outlined,
        //     "Notifications",
        //     trailing: Switch(
        //       value: isNotificationsEnabled,
        //       activeColor: brandGreen,
        //       onChanged: (v) => setState(() => isNotificationsEnabled = v),
        //     ),
        //   ),
        _menuItem(
          Icons.wb_sunny_outlined,
          "Dark Mode",
          trailing: Switch(
            value: isDark,
            activeColor: brandGreen,
            onChanged: (v) async {
              if (v == true) {
                themeNotifier.value = ThemeMode.dark;
              } else {
                themeNotifier.value = ThemeMode.dark;

                // themeNotifier.value = ThemeMode.light;
              }
              setState(() {});
              await ThemeService().saveThemeMode(v);

              // Add your theme toggle logic here
            },
          ),
        ),
        // if (loggedIn)
        //   _menuItem(
        //     Icons.settings_outlined,
        //     "Accounts Settings",
        //     voidCallback: () {
        //       Navigator.pushNamed(context, '/AccountSettings');
        //     },
        //   ),
        if (loggedIn)
          _menuItem(
            Icons.receipt_long_outlined,
            "Transaction History",
            voidCallback: () {
              Navigator.pushNamed(context, '/TransactionHistory', arguments: 2);
            },
          ),
        if (loggedIn)
          _menuItem(
            Icons.access_time,
            "Recently Played Media",
            voidCallback: () {
              Navigator.pushNamed(context, '/Dashboard', arguments: 2);
            },
          ),
        if (loggedIn)
          _menuItem(
            Icons.shopping_bag_outlined,
            "Purchased Media",
            voidCallback: () {
              Navigator.pushNamed(context, '/Dashboard', arguments: 2);
            },
          ),

        _menuItem(
          Icons.share_outlined,
          "Share App",
          voidCallback: () {
            shareTeseAfrica(context);
          },
        ),

        _menuItem(
          Icons.delete,
          "Clear Cache",
          voidCallback: () async {
            await clearTeseAudioCache();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cache cleared successfully!")),
            );
          },
        ),
        _menuItem(
          Icons.shield_outlined,
          "Privacy Policy",
          voidCallback: () {
            Navigator.pushNamed(context, '/Policy', arguments: 2);
          },
        ),
        _menuItem(
          Icons.description_outlined,
          "Terms of Service",
          voidCallback: () {
            _navigateToTerms();
          },
        ),
        _menuItem(
          Icons.chat_bubble_outline,
          "Contact Us",
          voidCallback: () {
            Navigator.pushNamed(context, '/ContactUs', arguments: 2);
          },
        ),
        _menuItem(
          !loggedIn ? Icons.login : Icons.logout,
          loggedIn ? "Logout" : "Sign In",
          showDivider: false,
          voidCallback: () async {
            _con.logout(context);
          },
        ),
      ],
    );
  }

  Future<void> clearTeseAudioCache() async {
    try {
      // 1. Get the temporary directory where just_audio stores cached files
      final tempDir = await getTemporaryDirectory();

      // 2. just_audio_cache usually creates a subfolder or prefixes files
      // You can delete the entire temp directory contents or target specific files
      if (tempDir.existsSync()) {
        tempDir.listSync().forEach((file) {
          if (file is File && file.path.contains('just_audio_cache')) {
            file.deleteSync();
          }
        });
        debugPrint("Tese Audio Cache Cleared");
      }
    } catch (e) {
      debugPrint("Error clearing cache: $e");
    }
  }

  void shareTeseAfrica(BuildContext context) async {
    // Replace these with your actual store links once published
    const String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.propsmart.tese';
    const String appleStoreUrl =
        'https://apps.apple.com/app/tese-africa/id000000000';

    // Determine which link to send based on the user's device
    final String appLink = Platform.isAndroid ? playStoreUrl : appleStoreUrl;

    final String message =
        'Check out Tese Africa! 🌍 The secure platform for African content creators. '
        'Download it here: $appLink';

    // Position the share sheet for iPads (required to prevent crashes)
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      message,
      subject: 'Join Tese Africa',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

Widget _menuItem(
    IconData icon,
    String title, {
    Widget? trailing,
    bool showDivider = true,

    VoidCallback? voidCallback,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey, size: 22),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          trailing:
              trailing ??
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          onTap: () {
            if (voidCallback != null) {
              voidCallback();
            }
          },
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 60,
            endIndent: 20,
            color: Colors.black12,
          ),
      ],
    );
  }
}
