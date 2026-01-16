import 'package:flutter/material.dart';
// ... (rest of your imports)

// Define the required function signature for clarity
typedef PasswordUpdateCallback =
    void Function(String current, String newPassword);

class UpdatePasswordDialog extends StatefulWidget {
  // 1. Define the callback function as a required parameter
  final PasswordUpdateCallback onSubmit;

  const UpdatePasswordDialog({super.key, required this.onSubmit});

  @override
  State<UpdatePasswordDialog> createState() => _UpdatePasswordDialogState();
}

class _UpdatePasswordDialogState extends State<UpdatePasswordDialog> {
  // ... (controllers and form key remain the same) ...
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  // ... (obscure state variables) ...
  final _confirmPasswordController = TextEditingController();

  // State to toggle password visibility
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      // 2. Call the passed-in callback function
      widget.onSubmit(currentPassword, newPassword);

      // 3. Dismiss the dialog after successful validation
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Password'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              Text(
                'You will be forced to log out after updating your password',
              ),
              SizedBox(height: 15),
              // --- Current Password Field ---
              // TextFormField(
              //   controller: _currentPasswordController,
              //   obscureText: _obscureCurrent,
              //   decoration: InputDecoration(
              //     labelText: 'Current Password',
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         _obscureCurrent ? Icons.visibility : Icons.visibility_off,
              //       ),
              //       onPressed: () {
              //         setState(() {
              //           _obscureCurrent = !_obscureCurrent;
              //         });
              //       },
              //     ),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your current password.';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 16),

              // --- New Password Field ---
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 8 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Confirm New Password Field (Match Field) ---
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password.';
                  }
                  // **MATCH VALIDATION**
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(onPressed: _submitUpdate, child: const Text('Update')),
      ],
    );
  }
}
