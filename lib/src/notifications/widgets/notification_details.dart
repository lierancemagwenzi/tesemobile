// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/notifications/controllers/notification_controller.dart';
// import 'package:smacredit/src/notifications/models/notification_model.dart';
// // Import your NotificationModel (assuming it's in a separate file)

// class NotificationDetailScreen extends StatefulWidget {
//   final NotificationModel notification;

//   const NotificationDetailScreen({super.key, required this.notification});

//   @override
//   StateMVC<NotificationDetailScreen> createState() =>
//       _NotificationDetailScreenState();
// }

// class _NotificationDetailScreenState
//     extends StateMVC<NotificationDetailScreen> {
//   late NotificationController _con;

//   _NotificationDetailScreenState() : super(NotificationController()) {
//     _con = controller as NotificationController;
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     _con.MarkAsRead(widget.notification.id!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Determine the color based on the 'opened' status
//     final statusColor = widget.notification.opened == true
//         ? Colors.green.shade700
//         : Colors.red.shade700;
//     final statusText = widget.notification.opened == true ? 'Read' : 'Unread';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.notification.title ?? 'Notification Details'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//             widget.notification.opened = true;
//           },

//           child: Icon(Icons.arrow_back_ios_sharp),
//         ),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- Notification Status and Date ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     statusText,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 // Display formatted date (using your custom formatter)
//                 Text(
//                   widget.notification.createdAt != null
//                       ? formatRelativeTime(
//                           widget.notification.createdAt!,
//                         ) // Use your custom formatter
//                       : 'Unknown Date',
//                   style: const TextStyle(color: Colors.grey, fontSize: 13),
//                 ),
//               ],
//             ),
//             const Divider(height: 30),

//             // --- Title ---
//             Text(
//               widget.notification.title ?? 'No Title',
//               style: Theme.of(
//                 context,
//               ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             // --- Body/Content ---
//             Text(
//               widget.notification.body ??
//                   'No specific details provided for this notification.',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),

//             const SizedBox(height: 40),

//             // --- Metadata (Optional) ---
//             // Text(
//             //   'User ID: ${notification.userId ?? 'N/A'}',
//             //   style: const TextStyle(color: Colors.grey),
//             // ),
//             // Text(
//             //   'Record ID: ${notification.id ?? 'N/A'}',
//             //   style: const TextStyle(color: Colors.grey),
//             // ),

//             // TODO: If this is an 'Amount received' notification, you could conditionally
//             // display a button here to view the associated transaction details.
//           ],
//         ),
//       ),
//     );
//   }

//   String formatRelativeTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

//     // 1. Determine if the date is Today, Yesterday, or another day
//     String dayString;
//     if (dateToCheck.isAtSameMomentAs(today)) {
//       dayString = 'Today';
//     } else if (dateToCheck.isAtSameMomentAs(yesterday)) {
//       dayString = 'Yesterday';
//     } else {
//       // If not today or yesterday, show the full date (e.g., Nov 25)
//       dayString = DateFormat('MMM d').format(dateTime);
//     }

//     // 2. Format the time part (e.g., 08:30 AM)
//     // Use 'jm' for locale-aware time (e.g., '8:30 AM' in en_US)
//     final timeString = DateFormat('jm').format(dateTime);

//     // 3. Combine them
//     return '$dayString $timeString';
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/notifications/controllers/notification_controller.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  StateMVC<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends StateMVC<NotificationDetailScreen> {
  late NotificationController _con;

  _NotificationDetailScreenState() : super(NotificationController()) {
    _con = controller as NotificationController;
  }

  @override
  void initState() {
    super.initState();
    // Logic kept intact: mark as read on open
    _con.MarkAsRead(widget.notification.id!);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine the color based on the 'opened' status
    // Adaptive colors for better contrast in dark mode
    final statusColor = widget.notification.opened == true
        ? (isDark ? Colors.greenAccent : Colors.green.shade700)
        : (isDark ? Colors.redAccent : Colors.red.shade700);

    final statusText = widget.notification.opened == true ? 'Read' : 'Unread';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.notification.title ?? 'Notification Details',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: InkWell(
          onTap: () {
            widget.notification.opened = true;
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_sharp),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Notification Status and Date ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  widget.notification.createdAt != null
                      ? formatRelativeTime(widget.notification.createdAt!)
                      : 'Unknown Date',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- Title ---
            Text(
              widget.notification.title ?? 'No Title',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // --- Body/Content ---
            Text(
              widget.notification.body ??
                  'No specific details provided for this notification.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),

            const SizedBox(height: 40),

            // Subtle Branding Element
            Center(
              child: Opacity(
                opacity: 0.5,
                child: Icon(
                  Icons.notifications_none_outlined,
                  size: 100,
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (dateToCheck.isAtSameMomentAs(today)) {
      dayString = 'Today';
    } else if (dateToCheck.isAtSameMomentAs(yesterday)) {
      dayString = 'Yesterday';
    } else {
      dayString = DateFormat('MMM d').format(dateTime);
    }

    final timeString = DateFormat('jm').format(dateTime);
    return '$dayString $timeString';
  }
}
