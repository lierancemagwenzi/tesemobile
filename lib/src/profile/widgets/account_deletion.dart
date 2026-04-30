// import 'package:flutter/material.dart';

// class AccountDeletionSheet extends StatefulWidget {
//   // Define the callback to pass the selected reason back to the parent
//   final Function(String reason) onProceed;

//   const AccountDeletionSheet({super.key, required this.onProceed});

//   @override
//   State<AccountDeletionSheet> createState() => _AccountDeletionSheetState();
// }

// class _AccountDeletionSheetState extends State<AccountDeletionSheet> {
//   final Color brandGreen = const Color(0xFF00D285);
//   final Color primaryText = const Color(0xFF1A0B2E);
//   final Color surfaceWhite = Colors.white;

//   String? _selectedReason;

//   final List<String> _deletionReasons = [
//     "I no longer use this app",
//     "Privacy concerns",
//     "Technical issues/Bugs",
//     "I found a better alternative",
//     "Too many notifications",
//     "Other",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: surfaceWhite,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 40,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             "Delete Account",
//             style: TextStyle(
//               color: primaryText,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Please select a reason for leaving. This action is permanent.",
//             style: TextStyle(color: Colors.black54, fontSize: 14),
//           ),
//           const SizedBox(height: 20),

//           // Reasons List
//           Flexible(
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: _deletionReasons.length,
//               itemBuilder: (context, index) {
//                 final reason = _deletionReasons[index];
//                 final isSelected = _selectedReason == reason;
//                 return ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   title: Text(reason, style: TextStyle(color: primaryText)),
//                   trailing: Icon(
//                     isSelected
//                         ? Icons.radio_button_checked
//                         : Icons.radio_button_off,
//                     color: isSelected ? brandGreen : Colors.grey,
//                   ),
//                   onTap: () => setState(() => _selectedReason = reason),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 32),

//           // PROCEED BUTTON
//           ElevatedButton(
//             onPressed: _selectedReason != null
//                 ? () {
//                     // Close the bottom sheet
//                     Navigator.pop(context);
//                     // Trigger the callback with the selected reason
//                     widget.onProceed(_selectedReason!);
//                   }
//                 : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFF4D4D), // Warning Red
//               disabledBackgroundColor: Colors.grey.shade300,
//               minimumSize: const Size(double.infinity, 55),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text(
//               "PROCEED TO DELETE",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class AccountDeletionSheet extends StatefulWidget {
  final Function(String reason) onProceed;

  const AccountDeletionSheet({super.key, required this.onProceed});

  @override
  State<AccountDeletionSheet> createState() => _AccountDeletionSheetState();
}

class _AccountDeletionSheetState extends State<AccountDeletionSheet> {
  // Using your established brand green for the radio buttons
  final Color brandGreen = const Color(0xFF679E4F);
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
    // THEME CONSTANTS
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : const Color(0xFF1A0B2E);
    final secondaryText = isDark ? Colors.white70 : Colors.black54;
    final sheetBg = isDark ? const Color(0xFF121212) : Colors.white;
    final handleCol = isDark ? Colors.white24 : Colors.grey[300];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: handleCol,
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
          Text(
            "Please select a reason for leaving. This action is permanent and cannot be undone.",
            style: TextStyle(color: secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Reasons List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _deletionReasons.length,
              itemBuilder: (context, index) {
                final reason = _deletionReasons[index];
                final isSelected = _selectedReason == reason;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    reason,
                    style: TextStyle(
                      color: isSelected ? brandGreen : primaryText,
                    ),
                  ),
                  trailing: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? brandGreen : handleCol,
                  ),
                  onTap: () => setState(() => _selectedReason = reason),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // PROCEED BUTTON (Red for Warning)
          ElevatedButton(
            onPressed: _selectedReason != null
                ? () {
                    Navigator.pop(context);
                    widget.onProceed(_selectedReason!);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D), // Stay Red for Danger
              disabledBackgroundColor: isDark
                  ? Colors.white10
                  : Colors.grey.shade300,
              minimumSize: const Size(double.infinity, 55),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "PROCEED TO DELETE",
              style: TextStyle(
                color: _selectedReason != null ? Colors.white : secondaryText,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
