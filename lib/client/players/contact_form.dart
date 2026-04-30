import 'package:flutter/material.dart';
import 'package:smacredit/client/models/media_response.dart';

typedef ContactCallback = void Function(Map<String, String> formData);

class ContactAdvertiserForm extends StatefulWidget {
  final AdModel ad;
  final int video_id;
  final ContactCallback onSubmit; // The callback action

  const ContactAdvertiserForm({
    super.key,
    required this.ad,required this.video_id,
    required this.onSubmit,
  });

  @override
  State<ContactAdvertiserForm> createState() => _ContactAdvertiserFormState();
}

class _ContactAdvertiserFormState extends State<ContactAdvertiserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Inquiry for ${widget.ad.brand}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildField(_nameController, "Full Name"),
            const SizedBox(height: 12),
            _buildField(
              _emailController,
              "Email Address",
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildField(
              _phoneController,
              "Phone Number",
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D285),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Package the data and send it back via callback
                  widget.onSubmit({
                    'fullname': _nameController.text,
                    'email_address': _emailController.text,
                    'phone': _phoneController.text,
                    'advertiser_id': widget.ad.advertiserId.toString(),
                    'ad_id': widget.ad.id.toString(),
                    'video_id': widget.video_id.toString(),
                  });
                  Navigator.pop(context); // Close the form
                }
              },
              child: const Text(
                "SUBMIT INQUIRY",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType? inputType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      validator: (val) => val!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
