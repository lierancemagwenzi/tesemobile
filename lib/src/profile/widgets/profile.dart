import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/controller/LoginController.dart';
import 'package:smacredit/src/auth/widgets/models/terms_widget.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/profile/widgets/Update_Password_dialog.dart';
import 'package:smacredit/src/profile/widgets/account_deletion.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onPop});

  final VoidCallback onPop;
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends StateMVC<ProfileScreen> {
  late LoginController _con;

  _ProfileScreenState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  @override
  void initState() {
    super.initState();

    _con.getAccountInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. App Bar and Title
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Profile Image
                    _buildProfileAvatar(),
                    const SizedBox(height: 30),

                    // 3. Information Header (Personal Information)
                    _buildInfoHeader(context),
                    const SizedBox(height: 16),

                    // 4. Bio Card
                    _buildInfoCard(
                      title: 'name',
                      content:
                          '${currentuser.value.user?.name ?? ''} ${currentuser.value.user?.lastname ?? ''}',
                    ),
                    const SizedBox(height: 16),

                    // 5. Social Links Card
                    _buildInfoCard(
                      title: 'Email address',
                      content: currentuser.value.user?.email ?? '',
                    ),
                    const SizedBox(height: 16),

                    // 6. Creator ID Card
                    _buildInfoCard(
                      title: 'Creator ID',
                      content:
                          '@${currentuser.value.user?.name?.toLowerCase().trim() ?? ""}${currentuser.value.user?.lastname?.toLowerCase() ?? ""}_${currentuser.value.user?.id ?? ""}',
                      hideTitle: true, // Only content displayed for this card
                    ),
                    const SizedBox(height: 40),
                    if (_con.accountInfo != null)
                      _buildInfoCard(
                        title: 'Banking info',
                        showDone: _con.accountInfo?.hasBank == true,
                        content: _con.accountInfo?.hasBank == true
                            ? 'View and update your banking info'
                            : 'Update your banking info',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/UpdatePaymentProfile',
                            arguments: _con.accountInfo,
                          ).then((value) => _con.getAccountInfo());
                        },
                      ),
                    const SizedBox(height: 16),

                    if (_con.accountInfo != null)
                      _buildInfoCard(
                        title: 'Proof of residence',
                        showDone: _con.accountInfo?.proofOfResidence != null,
                        content: _con.accountInfo?.proofOfResidence == null
                            ? 'Upload your proof of residence'
                            : 'Update your proof of residence',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/UploadDocument',
                            arguments: _con.accountInfo,
                          ).then((value) => _con.getAccountInfo());
                        },
                      ),
                    const SizedBox(height: 24),

                    Text(
                      "Terms and Policy",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      title: 'Terms and Conditions',
                      showDone: false,
                      content: 'View our terms and conditions',
                      onTap: () {
                        _navigateToTerms();
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      title: 'Privacy Policy',
                      showDone: false,
                      content: 'View our privacy policy',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/Policy',
                          arguments: _con.accountInfo,
                        ).then((value) => _con.getAccountInfo());
                      },
                    ),
                    const SizedBox(height: 16),

                    Text(
                      "Account Deletion",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    _buildInfoCard(
                      title: 'Delete Account',
                      showDone: false,
                      content: 'delete your account and clear your data',
                      onTap: () {
                        _handleDeleteAccount(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 8),
                    // 7. Update Button
                    // _buildUpdateButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TermsAndConditionsScreen(
          shouldAccept: false,
          onAcceptanceChanged: (bool value) {
            // This code runs when the user clicks "Accept and Continue"
            setState(() {
              // _isTermsAccepted = value;
            });

            // OPTIONAL: Call your backend API here to update Sequelize

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Terms accepted successfully!")),
            );
          },
        ),
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccountDeletionSheet(
        onProceed: (String reason) {
          // This is where your onClicked logic lives
          print("User wants to delete because: $reason");

          // Example: Show a final confirmation dialog
          _showFinalConfirmationDialog(reason);
        },
      ),
    );
  }

  void _showFinalConfirmationDialog(String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Final Confirmation"),
        content: const Text(
          "Are you absolutely sure? All your data will be permanently removed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _con.deleteAccount(reason);
              // CALL YOUR SEQUELIZE BACKEND HERE
              // User.destroy({ where: { id: userId } })
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: Row(
        children: [
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
              onPressed: widget.onPop, // Placeholder back action
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    // This uses a Stack to potentially add a border or overlay, matching the screenshot's depth.
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Gradient ring for the border, similar to the colors used in other buttons
            border: Border.all(color: Colors.green.shade700, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              currentuser.value.user?.selfie ?? '', // Placeholder image URL
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
          ),
        ),

        SizedBox(height: 10),

        InkWell(
          onTap: () {
            showUpdatePasswordDialog(context);
          },

          child: Text(
            "Update Password",
            style: TextStyle(
              fontSize: 14,

              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey.shade300, thickness: 1, height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              InkWell(
                onTap: () {
                  // Handle edit action
                  Navigator.pushNamed(context, '/UpdateProfile');
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300, thickness: 1, height: 2),
      ],
    );
  }

  void handlePasswordSubmission(String current, String newPassword) async {
    print('Callback received! Current: $current, New: $newPassword');

    bool? update = await _con.updatePassword({'password': newPassword});

    if (update == true) {
      // CustomMessageHandler().showErrorSnakeBar(
      //   context,
      //   "Password updated successfully",
      // );
      Navigator.pushNamed(
        context,
        '/Login',
        arguments: 'Password changed successfully',
      );
      // Navigator.pop(context);
    } else {
      CustomMessageHandler().showErrorSnakeBar(
        context,
        "Something went wrong.Try again",
      );
    }
  }
  // ---------------------------------------------

  void showUpdatePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 2. Pass the submission function to the dialog's onSubmit parameter
        return UpdatePasswordDialog(onSubmit: handlePasswordSubmission);
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    bool hideTitle = false,

    bool showDone = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hideTitle)
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (showDone) ...[
                    Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade200),
                      ),

                      child: Icon(Icons.done, color: Colors.white),
                    ),
                  ],
                ],
              ),
            if (!hideTitle) const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        // Gradient color matching the screenshot
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.yellow.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/Login');
        },
        child: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
