import 'package:flutter/material.dart';

class AccountDeletionSheet extends StatefulWidget {
  // Define the callback to pass the selected reason back to the parent
  final Function(String reason) onProceed;

  const AccountDeletionSheet({super.key, required this.onProceed});

  @override
  State<AccountDeletionSheet> createState() => _AccountDeletionSheetState();
}

class _AccountDeletionSheetState extends State<AccountDeletionSheet> {
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryText = const Color(0xFF1A0B2E);
  final Color surfaceWhite = Colors.white;

  String? _selectedReason;

  final List<String> _deletionReasons = [
    "I no longer use this app",
    "Privacy concerns",
    "Technical issues/Bugs",
    "I found a better alternative",
    "Too many notifications",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Delete Account",
            style: TextStyle(
              color: primaryText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please select a reason for leaving. This action is permanent.",
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Reasons List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _deletionReasons.length,
              itemBuilder: (context, index) {
                final reason = _deletionReasons[index];
                final isSelected = _selectedReason == reason;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(reason, style: TextStyle(color: primaryText)),
                  trailing: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? brandGreen : Colors.grey,
                  ),
                  onTap: () => setState(() => _selectedReason = reason),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // PROCEED BUTTON
          ElevatedButton(
            onPressed: _selectedReason != null
                ? () {
                    // Close the bottom sheet
                    Navigator.pop(context);
                    // Trigger the callback with the selected reason
                    widget.onProceed(_selectedReason!);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D), // Warning Red
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "PROCEED TO DELETE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
