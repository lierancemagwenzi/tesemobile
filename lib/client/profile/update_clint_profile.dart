import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/controller/LoginController.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

// Assuming your User model looks something like this:
// class User {
//   final String name;
//   final String lastname;
//   final String phone;
//   User({required this.name, required this.lastname, required this.phone});
// }

class UpdateProfileScreen extends StatefulWidget {
  final User user; // Replace 'dynamic' with your actual User model class name

  const UpdateProfileScreen({super.key, required this.user});

  @override
  StateMVC<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends StateMVC<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  static const Color teseGreen = Color(
    0xFF52B681,
  ); // Matching the button in your image

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  late LoginController _con;

  _UpdateProfileScreenState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  // Tese Africa Brand Green
  final Color brandGreen = const Color(0xFF52B681);

  @override
  void initState() {
    super.initState();
    // Prepopulate fields from the User model
    _firstNameController = TextEditingController(text: widget.user.name);
    _lastNameController = TextEditingController(text: widget.user.lastname);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect theme brightness
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Inherit background from theme (white in light mode, black/grey in dark)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Adaptive icon color
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: CustomOverlay(
        loading: _con.loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel("Personal Details"),
                const SizedBox(height: 24),

                _buildTextField(
                  label: "First Name",
                  controller: _firstNameController,
                  icon: Icons.person_outline,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: "Last Name",
                  controller: _lastNameController,
                  icon: Icons.badge_outlined,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: "Phone Number",
                  controller: _phoneController,
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  isDark: isDark,
                ),

                const SizedBox(height: 48),

                // Tese Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teseGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Unfocus keyboard
                        FocusScope.of(context).unfocus();

                        // Handle update logic
                        print("Name: ${_firstNameController.text}");

                        User? user = await _con.updateClientAccount({
                          "name": _firstNameController.text,
                          "lastname": _lastNameController.text,
                          "phone": _phoneController.text,
                        });

                        if (user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile updated successfully!"),
                            ),
                          );
                        } else {
                          CustomMessageHandler().showErrorSnakeBar(
                            context,
                            "Something went wrong.Try again",
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Update Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: brandGreen,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      cursorColor: brandGreen,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        floatingLabelStyle: TextStyle(color: brandGreen),
        prefixIcon: Icon(icon, color: brandGreen),

        filled: true,
        // Adaptive fill color
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),

        // Borders
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: brandGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter your $label";
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [brandGreen, const Color(0xFF00C9FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Unfocus keyboard
            FocusScope.of(context).unfocus();

            // Handle update logic
            print("Name: ${_firstNameController.text}");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated locally!")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "SAVE CHANGES",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
